#https://stackoverflow.com/questions/50600893/api-gateway-proxy-for-s3-with-subdirectories

resource "aws_api_gateway_resource" "s3proxy" {
  rest_api_id = var.rest_api_id
  parent_id   = var.parent_id
  path_part   = "{proxy+}"
}
resource "aws_api_gateway_method" "s3proxy" {
  rest_api_id = var.rest_api_id
  resource_id   = aws_api_gateway_resource.s3proxy.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
    "method.request.header.Accept" = true
  }
}

resource "aws_api_gateway_integration" "s3proxy" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.s3proxy.id
  http_method = aws_api_gateway_method.s3proxy.http_method

  type="AWS"

  #see https://docs.aws.amazon.com/apigateway/api-reference/resource/integration/
  uri="arn:aws:apigateway:${var.region}:s3:path/${var.bucket_path}/{proxy}"

  credentials=aws_iam_role.frontendReader.arn

  integration_http_method = "GET"
  passthrough_behavior    = "WHEN_NO_MATCH"
  request_parameters = {
      "integration.request.path.proxy" = "method.request.path.proxy"
      "integration.request.header.Accept" = "method.request.header.Accept"
    }
}

resource "aws_api_gateway_method_response" "s3proxy_200" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.s3proxy.id
  http_method = aws_api_gateway_method.s3proxy.http_method
  status_code = "200"

  response_models = {
    #"application/json" = "Empty"
  }

  #this is case sensitive Content-type is allowed but the returned Content-Type is application/json
  #not the bucket object meta data
  response_parameters = {
    "method.response.header.Content-Type" = true
  }
}

resource "aws_api_gateway_integration_response" "s3proxy_response_200" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.s3proxy.id
  http_method = aws_api_gateway_method.s3proxy.http_method
  status_code = aws_api_gateway_method_response.s3proxy_200.status_code

  selection_pattern = "-"
  response_parameters = {
    "method.response.header.Content-Type" = "integration.response.header.Content-Type"
  }


  depends_on = [aws_api_gateway_integration.s3proxy]
}


resource "aws_api_gateway_deployment" "s3proxy_test" {
  depends_on = [
    aws_api_gateway_integration.s3proxy,
    aws_api_gateway_integration_response.s3proxy_response_200
  ]

  rest_api_id = var.rest_api_id
  stage_name  = var.stage_name
}

resource "aws_iam_role" "frontendReader" {
  name = "apigwRO-s3_${var.bucket_path}"
  path = "/"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = var.tags

}
resource "aws_iam_role_policy_attachment" "frontendReader_bucketRoPolicy" {
  role = aws_iam_role.frontendReader.name
  policy_arn = aws_iam_policy.bucketRoPolicy.arn
}

resource "aws_iam_policy" "bucketRoPolicy" {
  name = "apigwRO-s3_${var.bucket_path}"
  description = "can read s3_${var.bucket_path}"
  #TODO: do I need the logging or just use a logging for the api gw?
  policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams",
            "logs:PutLogEvents",
            "logs:GetLogEvents",
            "logs:FilterLogEvents"
        ],
        "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "s3:Get*",
            "s3:List*"
        ],
        "Resource": "arn:aws:s3:::${var.bucket_path}/*"
    }
  ]

}
EOF
}


resource "aws_api_gateway_method_settings" "s3proxy_test_settings" {
  #see https://www.rockedscience.net/articles/api-gateway-logging-with-terraform/
  rest_api_id = var.rest_api_id
  stage_name  = aws_api_gateway_deployment.s3proxy_test.stage_name
  method_path = "*/*"
  settings {
    # Enable CloudWatch logging and metrics
    metrics_enabled        = false
    data_trace_enabled     = true
    logging_level          = "INFO"
    # Limit the rate of calls to prevent abuse and unwanted charges
    throttling_rate_limit  = 100
    throttling_burst_limit = 50
  }
}

#log expiration
resource "aws_cloudwatch_log_group" "api_gateway_s3Proxy_test_logs" {
  name = "API-Gateway-Execution-Logs_${var.rest_api_id}/${aws_api_gateway_deployment.s3proxy_test.stage_name}"

  retention_in_days = "7"
  tags = var.tags
}

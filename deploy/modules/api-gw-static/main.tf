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

  //selection_pattern = "-" this makes tf modify it one very apply
  selection_pattern = "" //tell tf this is the default
  response_parameters = {
    "method.response.header.Content-Type" = "integration.response.header.Content-Type"
  }


  depends_on = [aws_api_gateway_integration.s3proxy]
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

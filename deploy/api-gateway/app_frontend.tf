resource "aws_s3_bucket" "frontend" {
  bucket_prefix = "frontend"

  force_destroy=true

  tags = merge(
    local.common_tags
  )
}

#https://stackoverflow.com/questions/50600893/api-gateway-proxy-for-s3-with-subdirectories



resource "aws_api_gateway_resource" "s3proxy" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  parent_id   = aws_api_gateway_rest_api.api-gw.root_resource_id
  path_part   = "{proxy+}"
}
resource "aws_api_gateway_method" "s3proxy" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  resource_id   = aws_api_gateway_resource.s3proxy.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "s3proxy" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  resource_id = aws_api_gateway_resource.s3proxy.id
  http_method = aws_api_gateway_method.s3proxy.http_method

  type="AWS"

  #TODO: get region from var
  #see https://docs.aws.amazon.com/apigateway/api-reference/resource/integration/
  uri="arn:aws:apigateway:eu-west-1:s3:path/${aws_s3_bucket.frontend.bucket}/{proxy}"

  credentials=aws_iam_role.frontendReader.arn

  integration_http_method = "GET"
  passthrough_behavior    = "WHEN_NO_MATCH"
  request_parameters = {
      "integration.request.path.proxy" = "method.request.path.proxy"
    }
}

resource "aws_api_gateway_deployment" "s3proxy" {
  depends_on = [
    aws_api_gateway_integration.s3proxy
  ]

  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  stage_name  = "test"
}

resource "aws_iam_role" "frontendReader" {
  name = "apigwRO-${aws_s3_bucket.frontend.bucket}"
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

  tags = merge(
    local.common_tags
  )

}
resource "aws_iam_role_policy_attachment" "frontendReader_bucketRoPolicy" {
  role = aws_iam_role.frontendReader.name
  policy_arn = aws_iam_policy.bucketRoPolicy.arn
}

resource "aws_iam_policy" "bucketRoPolicy" {
  name = "apigwRO-${aws_s3_bucket.frontend.bucket}"
  description = "can read bucket ${aws_s3_bucket.frontend.bucket}"
  policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "logs:*"
        ],
        "Resource": "arn:aws:logs:*:*:*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "s3:GetObject"
        ],
        "Resource": "arn:aws:s3:::${aws_s3_bucket.frontend.bucket}/*"
    }
  ]

}
EOF
}


/*
resource "aws_api_gateway_method" "s3proxy_get" {
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  resource_id   = aws_api_gateway_resource.s3proxy.id
  http_method   = "GET"
  authorization = "NONE"
}


resource "aws_api_gateway_deployment" "s3proxy" {
  depends_on = [
  ]

  rest_api_id = "${aws_api_gateway_rest_api.api-gw.id}"
  stage_name  = "test"
}

output "base_url" {
  value = "${aws_api_gateway_deployment.s3proxy.invoke_url}"
}
*/

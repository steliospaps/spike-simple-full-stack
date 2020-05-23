resource "aws_api_gateway_rest_api" "api-gw" {
  name        = "simple-fullstack api gateway"
  description = "externally facing api gateway"
  tags = local.common_tags
}

// enable logging for gateway
resource "aws_iam_role" "iam_for_api_gw_logging" {
  name_prefix = "iam_for_api_gw_logging"

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

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "api_gw_logging" {
  role = aws_iam_role.iam_for_api_gw_logging.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

output "backend_url" {
  value = module.stage.base_url
}

module "stage" {
  source = "../modules/api-gw-stage"
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  stage_name="dev"
  stage_dependencies = concat(module.api-gw-lambda.stage_dependencies)
  tags=local.common_tags
  logging_level="INFO"
}

module "api-gw-lambda" {
  source = "../modules/api-gw-lambda"
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  parent_id = aws_api_gateway_rest_api.api-gw.root_resource_id
  lambda_invoke_arn = aws_lambda_function.backend.invoke_arn
  tags=local.common_tags
  options_allow_origin="'${local.frontend_base_url}'"
}


resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.backend.arn
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
   source_arn = "${aws_api_gateway_rest_api.api-gw.execution_arn}/*/*/*"
}

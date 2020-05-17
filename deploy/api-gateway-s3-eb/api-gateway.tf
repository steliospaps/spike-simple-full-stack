resource "aws_api_gateway_rest_api" "api-gw" {
  name        = "simple-fullstack api gateway"
  description = "externally facing api gateway"
  tags = merge(
    local.common_tags
  )
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

  tags = merge(
    local.common_tags
  )

}

resource "aws_iam_role_policy_attachment" "api_gw_logging" {
  role = aws_iam_role.iam_for_api_gw_logging.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}


locals {
  api_path="api"
}

output "frontend_base_url" {
  value = module.stage.base_url
}
output "backend_relative_url" {
  value = "./${local.api_path}"
}
output "backend_url" {
  value = "${module.stage.base_url}/${local.api_path}"
}

module "stage" {
  source = "../modules/api-gw-stage"
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  stage_name="dev"
  stage_dependencies = concat(module.frontend.stage_dependencies, module.eb_tunnel.stage_dependencies)
  tags=local.common_tags
  logging_level="INFO"
}

module "eb_tunnel" {
  source = "../modules/api-gw-tunnel"
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  parent_id = aws_api_gateway_rest_api.api-gw.root_resource_id
  tags=local.common_tags
  url="http://${module.eb.cname}"
  path_part=local.api_path
}

module "frontend" {
  source = "../modules/api-gw-static"
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  parent_id = aws_api_gateway_rest_api.api-gw.root_resource_id
  region = var.region
  bucket_path="${aws_s3_bucket.frontend.bucket}"
  tags=local.common_tags
}

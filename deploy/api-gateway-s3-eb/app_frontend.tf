resource "aws_s3_bucket" "frontend" {
  bucket_prefix = "frontend"

  force_destroy=true

  tags = merge(
    local.common_tags
  )
}

resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.frontend.bucket
  key    = "index.html"
  source = "dummy_frontend/index.html"
  content_type="text/html"
  #todo verify this is not updated on tf apply
}

output "frontend_base_url" {
  value = module.stage.base_url
}
output "frontend_bucket" {
  value = aws_s3_bucket.frontend.bucket
}

module "stage" {
  source = "../modules/api-gw-stage"
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  stage_name="dev"
  stage_dependencies = module.frontend.stage_dependencies
  tags=local.common_tags
}

module "frontend" {
  source = "../modules/api-gw-static"
  rest_api_id = aws_api_gateway_rest_api.api-gw.id
  parent_id = aws_api_gateway_rest_api.api-gw.root_resource_id
  region = var.region
  bucket_path="${aws_s3_bucket.frontend.bucket}"
  tags=local.common_tags
}

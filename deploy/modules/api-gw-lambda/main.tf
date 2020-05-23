resource "aws_api_gateway_resource" "parent" {
  count=length(var.path_part)>0 ? 1:0
  rest_api_id = var.rest_api_id
  parent_id   = var.parent_id
  path_part   = var.path_part
}

resource "aws_api_gateway_resource" "default" {
  rest_api_id = var.rest_api_id
  parent_id   = length(var.path_part)>0 ? aws_api_gateway_resource.parent[0].id : var.parent_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "default" {
  count=length(var.methods)
  rest_api_id = var.rest_api_id
  resource_id   = aws_api_gateway_resource.default.id
  http_method   = var.methods[count.index]
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "default" {
  count=length(aws_api_gateway_method.default)

  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.default.id
  http_method = aws_api_gateway_method.default[count.index].http_method

  type="AWS_PROXY"
  integration_http_method = "POST"

  #see https://docs.aws.amazon.com/apigateway/api-reference/resource/integration/
  uri=var.lambda_invoke_arn
}

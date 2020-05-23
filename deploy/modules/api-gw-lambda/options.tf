//OPTIONS fake response
//see https://medium.com/@MrPonath/terraform-and-aws-api-gateway-a137ee48a8ac
//see also https://github.com/squidfunk/terraform-aws-api-gateway-enable-cors/blob/master/main.tf

resource "aws_api_gateway_method" "proxy_options" {
  count=var.override_options ? 1 : 0
  rest_api_id   = var.rest_api_id
  resource_id   = aws_api_gateway_resource.default.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}
resource "aws_api_gateway_method_response" "proxy_options_200" {
  count=var.override_options ? 1 : 0
    rest_api_id   = var.rest_api_id
    resource_id   = aws_api_gateway_resource.default.id
    http_method   = aws_api_gateway_method.proxy_options[count.index].http_method
    status_code   = 200
  response_models = {
    "application/json" = "Empty"
  }

    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true,
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Origin" = true
    }
    depends_on = [aws_api_gateway_method.proxy_options]
}

resource "aws_api_gateway_integration" "proxy_options" {
  count=var.override_options ? 1 : 0
  rest_api_id   = var.rest_api_id
  resource_id   = aws_api_gateway_resource.default.id
  http_method   = aws_api_gateway_method.proxy_options[count.index].http_method
  type          = "MOCK"
  request_templates = {
    "application/json" = <<EOT
{"statusCode": 200}
EOT
  }
  depends_on = [aws_api_gateway_method.proxy_options]
}

resource "aws_api_gateway_integration_response" "proxy_options_integration_response" {
    count=var.override_options ? 1 : 0
    rest_api_id   = var.rest_api_id
    resource_id   = aws_api_gateway_resource.default.id
    http_method   = aws_api_gateway_method.proxy_options[count.index].http_method
    status_code   = aws_api_gateway_method_response.proxy_options_200[count.index].status_code
    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = var.options_allow_headers,
        "method.response.header.Access-Control-Allow-Methods" = var.options_allow_methods,
        "method.response.header.Access-Control-Allow-Origin" = var.options_allow_origin
    }
    depends_on = [aws_api_gateway_method_response.proxy_options_200]
}
//OPTIONS ends

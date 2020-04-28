#https://stackoverflow.com/questions/50600893/api-gateway-proxy-for-s3-with-subdirectories

resource "aws_api_gateway_resource" "parent" {
  rest_api_id = var.rest_api_id
  parent_id   = var.parent_id
  path_part   = var.path_part
}

resource "aws_api_gateway_resource" "default" {
  rest_api_id = var.rest_api_id
  parent_id   = aws_api_gateway_resource.parent.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "default" {
  rest_api_id = var.rest_api_id
  resource_id   = aws_api_gateway_resource.default.id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.header.Accept" = true
    "method.request.path.proxy" = true
  }

}

resource "aws_api_gateway_integration" "default" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.default.id
  http_method = aws_api_gateway_method.default.http_method

  type="HTTP_PROXY"

  #see https://docs.aws.amazon.com/apigateway/api-reference/resource/integration/
  uri="${var.url}/{proxy}"

  integration_http_method = "ANY"
  passthrough_behavior    = "WHEN_NO_MATCH"
  request_parameters = {
      "integration.request.header.Accept" = "method.request.header.Accept"
      "integration.request.path.proxy" = "method.request.path.proxy"
    }
}
/*
resource "aws_api_gateway_method_response" "default_200" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.default.id
  http_method = aws_api_gateway_method.default.http_method
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

resource "aws_api_gateway_integration_response" "default_response_200" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.default.id
  http_method = aws_api_gateway_method.default.http_method
  status_code = aws_api_gateway_method_response.default_200.status_code

  //selection_pattern = "-" this makes tf modify it one very apply
  selection_pattern = "" //tell tf this is the default
  response_parameters = {
    "method.response.header.Content-Type" = "integration.response.header.Content-Type"
  }


  depends_on = [aws_api_gateway_integration.default]
}
*/


output "stage_dependencies" {
  description = "dependencies to be passed to the stage"
  value= [
    aws_api_gateway_integration.s3proxy,
    aws_api_gateway_integration_response.s3proxy_response_200
  ]
}

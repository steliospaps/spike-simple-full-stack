
output "stage_dependencies" {
  description = "dependencies to be passed to the stage"
  value= [
    aws_api_gateway_integration.default,
    // aws_api_gateway_integration_response.default_response_200
  ]
}


output "stage_dependencies" {
  description = "dependencies to be passed to the stage"
  value= [
    aws_api_gateway_integration.default,
    // aws_api_gateway_integration_response.default_response_200
  ]
}

output "resource_id" {
  description="the resource id used. This can be used to add OPTIONS to the method"
  value=length(var.path_part)>0 ? aws_api_gateway_resource.parent[0].id : var.parent_id
}

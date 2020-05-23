output "resource_id" {
  description="the resource id used. This can be used to add OPTIONS to the method"
  value=length(var.path_part)>0 ? aws_api_gateway_resource.parent[0].id : var.parent_id
}


output "stage_dependencies" {
  description = "dependencies to be passed to the stage"
  value= concat(
    aws_api_gateway_integration_response.proxy_options_integration_response.*,
    aws_api_gateway_integration.proxy_options.*,
    aws_api_gateway_integration.default.*
  )
}

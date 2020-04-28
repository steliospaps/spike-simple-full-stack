output "base_url" {
  value = aws_api_gateway_deployment.default.invoke_url
}

output "log_group" {
  value = aws_cloudwatch_log_group.api_gateway_default_logs.name
}

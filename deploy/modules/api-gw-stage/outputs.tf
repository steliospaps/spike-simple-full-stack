output "base_url" {
  value = aws_api_gateway_deployment.s3proxy_test.invoke_url
}

output "log_group" {
  value = aws_cloudwatch_log_group.api_gateway_s3Proxy_test_logs.name
}

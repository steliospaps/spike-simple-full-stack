resource "aws_api_gateway_deployment" "s3proxy_test" {
  depends_on = [var.stage_dependencies]

  rest_api_id = var.rest_api_id
  stage_name  = var.stage_name
}

resource "aws_api_gateway_method_settings" "s3proxy_test_settings" {
  #see https://www.rockedscience.net/articles/api-gateway-logging-with-terraform/
  rest_api_id = var.rest_api_id
  stage_name  = aws_api_gateway_deployment.s3proxy_test.stage_name
  method_path = "*/*"
  settings {
    # Enable CloudWatch logging and metrics
    metrics_enabled        = false
    data_trace_enabled     = true
    logging_level          = "INFO"
    # Limit the rate of calls to prevent abuse and unwanted charges
    throttling_rate_limit  = 100
    throttling_burst_limit = 50
  }
}

#log expiration
resource "aws_cloudwatch_log_group" "api_gateway_s3Proxy_test_logs" {
  name = "API-Gateway-Execution-Logs_${var.rest_api_id}/${aws_api_gateway_deployment.s3proxy_test.stage_name}"

  retention_in_days = "7"
  tags = var.tags
}

resource "aws_api_gateway_rest_api" "api-gw" {
  name        = "simple-fullstack api gateway"
  description = "externally facing api gateway"
  tags = merge(
    local.common_tags
  )
}

// enable logging for gateway
resource "aws_iam_role" "iam_for_api_gw_logging" {
  name_prefix = "iam_for_api_gw_logging"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = merge(
    local.common_tags
  )

}

resource "aws_iam_role_policy_attachment" "api_gw_logging" {
  role = aws_iam_role.iam_for_api_gw_logging.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

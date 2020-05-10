resource "aws_flow_log" "flow_log" {
  count = var.enable_flow_log ? 1 : 0
  tags = local.common_tags
  iam_role_arn    = aws_iam_role.flow_log[0].arn
  log_destination = aws_cloudwatch_log_group.flow_log[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.default.id
}

resource "aws_cloudwatch_log_group" "flow_log" {
  count = var.enable_flow_log ? 1 : 0
  tags = local.common_tags
  name = "${local.vpc_name}-flow-log"
  retention_in_days = "7"

}

resource "aws_iam_role" "flow_log" {
  count = var.enable_flow_log ? 1 : 0
  tags = local.common_tags
  name = "${local.vpc_name}-flow_log"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "flow_log" {
  count = var.enable_flow_log ? 1 : 0
  name = "${local.vpc_name}-flow_log"
  role = aws_iam_role.flow_log[0].id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

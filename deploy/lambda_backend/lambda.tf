output lambda_arn {
  value = aws_lambda_function.backend.arn
}


resource "aws_iam_role" "iam_for_lambda" {
  name_prefix = "iam_for_lambda-"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_run" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

// deploy empty dummy lambda
// see https://amido.com/blog/terraform-does-not-need-your-code-to-provision-a-lambda-function/
//
data "archive_file" "dummy_non_empty_jar" {
  type        = "zip"
  output_path = "${path.module}/dummy_lambda/dummy.jar"

  source {
    content  = "nothing"
    filename = "empty.txt"
  }
}

locals {
  function_name="backend"
}

resource "aws_lambda_function" "backend" {
  filename      = data.archive_file.dummy_non_empty_jar.output_path
  function_name = local.function_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "io.github.steliospaps.echo.lambda.StreamLambdaHandler"

  runtime = "java11"

  tags = local.common_tags

  timeout=10 //give it time to startup
  memory_size=512 //mb
  environment {
    variables = {
      "AT_LEAST_ONE_VARIABLE_IS_REQUIRED"="true"
      "CORS_ALLOWED_ORIGINS"="*"
      "CORS_ALLOWED_METHODS"="GET,POST"

    }
  }

  depends_on=[aws_cloudwatch_log_group.lambda_log]
}


# this will cause the logs to be deleted on destroy
resource "aws_cloudwatch_log_group" "lambda_log" {
  name = "/aws/lambda/${local.function_name}"
  retention_in_days=14

  tags = local.common_tags
}

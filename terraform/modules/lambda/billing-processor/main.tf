terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Archive the Lambda function code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/index.py"
  output_path = "${path.module}/billing-processor.zip"
}# Trigger error: Invalid course ID
curl https://q5ucammh0g.execute-api.eu-central-1.amazonaws.com/prod/courses/invalid-id-123

# Trigger error: Missing data
curl -X POST https://q5ucammh0g.execute-api.eu-central-1.amazonaws.com/prod/courses \
  -H "Content-Type: application/json" \
  -d '{}'

# Trigger error: Malformed JSON
curl -X POST https://q5ucammh0g.execute-api.eu-central-1.amazonaws.com/prod/courses \
  -H "Content-Type: application/json" \
  -d 'invalid json'

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.function_name}-role"
    Environment = var.environment
  }
}

# Attach basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# CloudWatch Logs
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 7

  tags = {
    Name        = "${var.function_name}-logs"
    Environment = var.environment
  }
}

# Lambda Function
resource "aws_lambda_function" "billing_processor" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = var.function_name
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime         = "python3.11"
  timeout         = 30
  memory_size     = 256

  environment {
    variables = {
      SLACK_WEBHOOK_URL = var.slack_webhook_url
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic,
    aws_cloudwatch_log_group.lambda_logs
  ]

  tags = {
    Name        = var.function_name
    Environment = var.environment
  }
}

# Lambda permission to allow SNS to invoke it
resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.billing_processor.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_topic_arn
}

# Subscribe Lambda to SNS topic
resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = var.sns_topic_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.billing_processor.arn
}

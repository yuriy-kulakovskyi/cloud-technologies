output "lambda_function_arn" {
  description = "ARN of the error processor Lambda function"
  value       = aws_lambda_function.error_processor.arn
}

output "lambda_function_name" {
  description = "Name of the error processor Lambda function"
  value       = aws_lambda_function.error_processor.function_name
}

output "lambda_role_arn" {
  description = "ARN of the Lambda IAM role"
  value       = aws_iam_role.lambda_role.arn
}

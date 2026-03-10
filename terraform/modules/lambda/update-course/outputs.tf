output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.update_course.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.update_course.arn
}

output "lambda_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.update_course.invoke_arn
}

output "lambda_role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.lambda_role.arn
}

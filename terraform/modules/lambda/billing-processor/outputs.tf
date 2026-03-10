output "lambda_function_arn" {
  description = "ARN of the billing processor Lambda function"
  value       = aws_lambda_function.billing_processor.arn
}

output "lambda_function_name" {
  description = "Name of the billing processor Lambda function"
  value       = aws_lambda_function.billing_processor.function_name
}

output "lambda_function_invoke_arn" {
  description = "Invoke ARN of the billing processor Lambda function"
  value       = aws_lambda_function.billing_processor.invoke_arn
}

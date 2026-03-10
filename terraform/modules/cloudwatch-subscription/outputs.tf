output "subscription_filter_name" {
  description = "Name of the CloudWatch log subscription filter"
  value       = aws_cloudwatch_log_subscription_filter.lambda_errors.name
}

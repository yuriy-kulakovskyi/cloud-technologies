resource "aws_cloudwatch_log_subscription_filter" "lambda_errors" {
  name            = "${var.lambda_function_name}-error-filter"
  log_group_name  = var.log_group_name
  filter_pattern  = var.filter_pattern
  destination_arn = var.destination_lambda_arn

  depends_on = [var.lambda_permission_id]
}

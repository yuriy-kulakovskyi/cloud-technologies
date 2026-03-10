variable "lambda_function_name" {
  description = "Name of the Lambda function being monitored"
  type        = string
}

variable "log_group_name" {
  description = "Name of the CloudWatch log group to monitor"
  type        = string
}

variable "filter_pattern" {
  description = "Filter pattern to match log events (e.g., '?ERROR ?CRITICAL ?5xx')"
  type        = string
  default     = "?ERROR ?CRITICAL ?5xx ?WARN"
}

variable "destination_lambda_arn" {
  description = "ARN of the Lambda function to invoke when pattern matches"
  type        = string
}

variable "lambda_permission_id" {
  description = "ID of the Lambda permission resource (for dependency)"
  type        = string
}

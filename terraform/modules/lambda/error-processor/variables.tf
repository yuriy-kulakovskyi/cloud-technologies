variable "function_name" {
  description = "Name of the error processor Lambda function"
  type        = string
  default     = "lambda-error-processor"
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for email notifications"
  type        = string
}

variable "slack_webhook_url" {
  description = "Slack webhook URL for notifications"
  type        = string
  default     = ""
  sensitive   = true
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "log_group_arn_pattern" {
  description = "Pattern for log groups that will trigger this function"
  type        = string
  default     = "arn:aws:logs:*:*:log-group:/aws/lambda/*"
}

variable "timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 256
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

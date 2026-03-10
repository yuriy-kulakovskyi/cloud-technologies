variable "alarm_name" {
  description = "Name of the billing alarm"
  type        = string
  default     = "aws-billing-alert"
}

variable "billing_threshold" {
  description = "The dollar amount threshold that triggers the alarm (in USD)"
  type        = number
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic to send notifications to"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

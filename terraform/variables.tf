variable "slack_webhook_url" {
  description = "Slack webhook URL for error notifications (optional)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "billing_threshold" {
  description = "Billing alarm threshold in USD (e.g., 50 for $50/month)"
  type        = number
  default     = 100
}

variable "billing_alert_emails" {
  description = "List of email addresses to receive billing alerts"
  type        = list(string)
  default     = []
}

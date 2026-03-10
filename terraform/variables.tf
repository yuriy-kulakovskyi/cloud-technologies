variable "slack_webhook_url" {
  description = "Slack webhook URL for error notifications (optional)"
  type        = string
  default     = ""
  sensitive   = true
}

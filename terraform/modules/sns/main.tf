resource "aws_sns_topic" "alerts" {
  name         = var.topic_name
  display_name = var.display_name

  tags = var.tags
}

resource "aws_sns_topic_subscription" "email" {
  count     = length(var.email_addresses)
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.email_addresses[count.index]
}

# CloudWatch Billing Alarm Module
# IMPORTANT: This must be deployed in us-east-1 region as billing metrics are only available there

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "billing_alarm" {
  alarm_name          = var.alarm_name
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 21600 # 6 hours in seconds
  statistic           = "Maximum"
  threshold           = var.billing_threshold
  alarm_description   = "Alarm when AWS estimated charges exceed $${var.billing_threshold}"
  alarm_actions       = [var.sns_topic_arn]
  
  dimensions = {
    Currency = "USD"
  }

  treat_missing_data = "notBreaching"

  tags = {
    Name        = var.alarm_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

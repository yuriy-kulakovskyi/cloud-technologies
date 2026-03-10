output "alarm_arn" {
  description = "ARN of the billing alarm"
  value       = aws_cloudwatch_metric_alarm.billing_alarm.arn
}

output "alarm_name" {
  description = "Name of the billing alarm"
  value       = aws_cloudwatch_metric_alarm.billing_alarm.alarm_name
}

output "alarm_id" {
  description = "ID of the billing alarm"
  value       = aws_cloudwatch_metric_alarm.billing_alarm.id
}

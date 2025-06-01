output "alarm_sns_topic_arn" {
  description = "ARN of the SNS topic for alarms"
  value       = aws_sns_topic.alarm.arn
}

output "alarm_sns_topic_name" {
  description = "Name of the SNS topic for alarms"
  value       = aws_sns_topic.alarm.name
}

output "alarm_cloudwatch_log_metric_filter_error_names" {
  description = "List of error log metric filter names"
  value       = { for k, v in aws_cloudwatch_log_metric_filter.error : k => v.name }
}

output "alarm_cloudwatch_metric_alarm_error_names" {
  description = "List of error log metric alarm names"
  value       = { for k, v in aws_cloudwatch_metric_alarm.error : k => v.alarm_name }
}

output "alarm_cloudwatch_event_rule_health_name" {
  description = "Name of the CloudWatch EventBridge rule for AWS Health events"
  value       = length(aws_cloudwatch_event_rule.health) > 0 ? aws_cloudwatch_event_rule.health[0].name : null
}

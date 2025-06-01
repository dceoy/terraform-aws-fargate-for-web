output "chatbot_slack_channel_configuration_arn" {
  description = "Chatbot Slack channel configuration ARN"
  value       = length(aws_chatbot_slack_channel_configuration.slack) > 0 ? aws_chatbot_slack_channel_configuration.slack[0].chat_configuration_arn : null
}

output "chatbot_iam_role_arn" {
  description = "Chatbot IAM role ARN"
  value       = length(aws_iam_role.slack) > 0 ? aws_iam_role.slack[0].arn : null
}

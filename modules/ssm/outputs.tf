output "ssm_session_document_name" {
  description = "SSM session document name"
  value       = aws_ssm_document.session.name
}

output "ssm_session_cloudwatch_log_group_name" {
  description = "SSM session CloudWatch log group name"
  value       = aws_cloudwatch_log_group.session.name
}

output "ssm_session_kms_key_arn" {
  description = "SSM session KMS key ARN"
  value       = aws_kms_key.session.arn
}

output "ssm_session_log_iam_policy_arn" {
  description = "SSM session IAM policy ARN"
  value       = aws_iam_policy.session.arn
}

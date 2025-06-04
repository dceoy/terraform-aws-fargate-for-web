output "kms_key_arn" {
  description = "KMS key ARN"
  value       = aws_kms_key.custom.arn
}

output "kms_key_alias_name" {
  description = "KMS key alias name"
  value       = aws_kms_alias.custom.name
}

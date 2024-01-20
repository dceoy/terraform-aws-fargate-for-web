output "ecs_cluster_id" {
  description = "ECS cluster ID"
  value       = aws_ecs_cluster.container.id
}

output "ecs_cluster_cloudwatch_log_group_name" {
  description = "ECS cluster CloudWatch log group name"
  value       = aws_cloudwatch_log_group.container.name
}

output "ecs_cluster_kms_key_arn" {
  description = "ECS cluster KMS key ARN"
  value       = aws_kms_key.container.arn
}

output "ecs_task_execution_iam_role_arn" {
  description = "ECS task execution IAM role ARN"
  value       = aws_iam_role.container.arn
}

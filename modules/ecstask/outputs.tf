output "ecs_task_definition_arn" {
  description = "ECS task definition ARN"
  value       = aws_ecs_task_definition.task.arn
}

output "ecs_task_definition_arn_without_revision" {
  description = "ECS task definition ARN without revision"
  value       = aws_ecs_task_definition.task.arn_without_revision
}

output "ecs_task_definition_revision" {
  description = "ECS task definition revision"
  value       = aws_ecs_task_definition.task.revision
}

output "ecs_task_iam_role_arn" {
  description = "ECS task IAM role ARN"
  value       = aws_iam_role.task.arn
}

output "ecs_task_cloudwatch_logs_log_group_name" {
  description = "ECS task CloudWatch Logs log group name"
  value       = aws_cloudwatch_log_group.task.name
}

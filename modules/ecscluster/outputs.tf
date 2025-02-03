output "ecs_cluster_id" {
  description = "ECS cluster ID"
  value       = aws_ecs_cluster.main.id
}

output "ecs_cluster_cloudwatch_logs_log_group_name" {
  description = "ECS cluster CloudWatch Logs log group name"
  value       = length(aws_cloudwatch_log_group.ecs) > 0 ? aws_cloudwatch_log_group.ecs[0].name : null
}

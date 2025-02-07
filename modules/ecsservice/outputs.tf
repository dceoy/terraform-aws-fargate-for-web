output "ecs_security_group_id" {
  description = "ECS security group ID"
  value       = aws_security_group.ecs.id
}

output "ecs_service_id" {
  description = "ECS service ID"
  value       = aws_ecs_service.fargate.id
}

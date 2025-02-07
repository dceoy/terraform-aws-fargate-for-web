output "lb_security_group_id" {
  description = "ALB security group ID"
  value       = aws_security_group.alb.id
}

output "lb_arn" {
  description = "ALB ARN"
  value       = aws_lb.app.arn
}

output "lb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.app.dns_name
}

output "lb_zone_id" {
  description = "ALB zone ID"
  value       = aws_lb.app.zone_id
}

output "lb_target_group_arn" {
  description = "ALB target group ARN"
  value       = aws_lb_target_group.app.arn
}

output "lb_target_group_load_balancer_arns" {
  description = "Load balancer ARNs associated with the ALB target group"
  value       = aws_lb_target_group.app.load_balancer_arns
}

output "lb_listener_arn" {
  description = "ALB listener ARN"
  value       = aws_lb_listener.app.arn
}

# trivy:ignore:AVD-AWS-0104
resource "aws_security_group" "ecs" {
  # checkov:skip=CKV_AWS_382:ECS task egress is intentionally open
  name        = "${var.system_name}-${var.env_type}-ecs-sg"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id
  ingress {
    description = "Allow all inbound traffic from the security group itself"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }
  ingress {
    description     = "Allow all inbound traffic from the ALB security group"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [var.alb_security_group_id]
  }
  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name       = "${var.system_name}-${var.env_type}-ecs-sg"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_service" "fargate" {
  name                               = "${var.system_name}-${var.env_type}-ecs-service"
  cluster                            = var.ecs_cluster_id
  task_definition                    = var.ecs_task_definition_arn
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  platform_version                   = var.ecs_service_platform_version
  desired_count                      = var.ecs_service_desired_count
  deployment_maximum_percent         = var.ecs_service_deployment_maximum_percent
  deployment_minimum_healthy_percent = var.ecs_service_deployment_minimum_healthy_percent
  health_check_grace_period_seconds  = var.ecs_service_health_check_grace_period_seconds
  availability_zone_rebalancing      = var.ecs_service_availability_zone_rebalancing
  enable_ecs_managed_tags            = var.ecs_service_enable_ecs_managed_tags
  enable_execute_command             = var.ecs_service_enable_execute_command
  propagate_tags                     = var.ecs_service_propagate_tags
  force_delete                       = var.ecs_service_force_delete
  force_new_deployment               = var.ecs_service_force_new_deployment
  wait_for_steady_state              = var.ecs_service_wait_for_steady_state
  triggers                           = var.ecs_service_triggers
  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = var.ecs_service_container_name
    container_port   = var.ecs_service_container_port
  }
  dynamic "deployment_controller" {
    for_each = var.ecs_service_deployment_controller_type != null ? [true] : []
    content {
      type = var.ecs_service_deployment_controller_type
    }
  }
  dynamic "alarms" {
    for_each = length(var.ecs_service_alarms) > 0 ? [true] : []
    content {
      alarm_names = lookup(var.ecs_service_alarms, "alarm_names", [])
      enable      = lookup(var.ecs_service_alarms, "enable", false)
      rollback    = lookup(var.ecs_service_alarms, "rollback", false)
    }
  }
  dynamic "deployment_circuit_breaker" {
    for_each = length(var.ecs_service_deployment_circuit_breaker) > 0 ? [true] : []
    content {
      enable   = lookup(var.ecs_service_deployment_circuit_breaker, "enable", false)
      rollback = lookup(var.ecs_service_deployment_circuit_breaker, "rollback", false)
    }
  }
  dynamic "ordered_placement_strategy" {
    for_each = var.ecs_service_ordered_placement_strategy
    content {
      field = lookup(ordered_placement_strategy.value, "field", null)
      type  = lookup(ordered_placement_strategy.value, "type", null)
    }
  }
  dynamic "placement_constraints" {
    for_each = var.ecs_service_placement_constraints
    content {
      expression = lookup(placement_constraints.value, "expression", null)
      type       = lookup(placement_constraints.value, "type", null)
    }
  }
  tags = {
    Name       = "${var.system_name}-${var.env_type}-ecs-service"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
  lifecycle {
    ignore_changes = [desired_count]
  }
}

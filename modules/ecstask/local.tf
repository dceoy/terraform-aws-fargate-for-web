data "aws_region" "current" {}

locals {
  region                     = data.aws_region.current.id
  ecs_task_definition_family = var.ecs_task_definition_family != null ? var.ecs_task_definition_family : "${var.system_name}-${var.env_type}-ecs-task"
}

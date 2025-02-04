resource "aws_ecs_task_definition" "fargate" {
  family                   = local.ecs_task_definition_family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_memory
  execution_role_arn       = var.ecs_execution_iam_role_arn
  task_role_arn            = aws_iam_role.task.arn
  skip_destroy             = var.ecs_task_skip_destroy
  pid_mode                 = "task"
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = var.ecs_task_runtime_platform_cpu_architecture
  }
  dynamic "ephemeral_storage" {
    for_each = length(var.ecs_task_ephemeral_storage_size_in_gib) > 0 ? [true] : []
    content {
      size_in_gib = var.ecs_task_ephemeral_storage_size_in_gib
    }
  }
  container_definitions = jsonencode([
    for n, u in var.ecs_image_uris : {
      name                   = n
      image                  = u
      versionConsistency     = "enabled"
      essential              = true
      readonlyRootFilesystem = false
      entryPoint             = lookup(var.ecs_task_container_entry_points, each.key, null)
      command                = lookup(var.ecs_task_container_commands, each.key, null)
      workingDirectory       = lookup(var.ecs_task_container_working_directories, each.key, null)
      user                   = lookup(var.ecs_task_container_users, each.key, null)
      portMappings           = lookup(var.ecs_task_container_port_mappings, each.key, null)
      restartPolicy          = lookup(var.ecs_task_container_restart_policies, each.key, null)
      healthCheck            = lookup(var.ecs_task_container_health_checks, each.key, null)
      startTimeout           = lookup(var.ecs_task_container_start_timeouts, each.key, null)
      stopTimeout            = lookup(var.ecs_task_container_stop_timeouts, each.key, null)
      environment = [
        for k, v in lookup(var.ecs_task_container_environment_variables, each.key, {}) : {
          name  = k
          value = v
        }
      ]
      secrets = [
        for k, v in lookup(var.ecs_task_container_secrets, each.key, {}) : {
          name      = k
          valueFrom = v
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-region        = local.region
          awslogs-group         = aws_cloudwatch_log_group.task.name
          awslogs-stream-prefix = n
        }
      }
    }
  ])
  tags = {
    Name       = local.ecs_task_definition_family
    SystemName = var.system_name
    EnvType    = var.env_type
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "task" {
  name                  = "${var.system_name}-${var.env_type}-ecs-task-iam-role"
  description           = "ECS task IAM role"
  force_detach_policies = var.iam_role_force_detach_policies
  path                  = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowECSTasksToAssumeRole"
        Effect = "Allow"
        Action = ["sts:AssumeRole"]
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    Name       = "${var.system_name}-${var.env_type}-ecs-task-iam-role"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_iam_role_policy_attachments_exclusive" "task" {
  role_name   = aws_iam_role.task.name
  policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}

resource "aws_iam_role_policy_attachment" "task" {
  for_each   = toset(var.ecs_task_iam_role_policy_arns)
  role       = aws_iam_role.task.name
  policy_arn = each.key
}

# trivy:ignore:AVD-AWS-0017
resource "aws_cloudwatch_log_group" "task" {
  name              = "/${var.system_name}/${var.env_type}/ecs/task/${local.ecs_task_definition_family}"
  retention_in_days = var.cloudwatch_logs_retention_in_days
  kms_key_id        = var.kms_key_arn
  tags = {
    Name       = "/${var.system_name}/${var.env_type}/ecs/task/${local.ecs_task_definition_family}"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

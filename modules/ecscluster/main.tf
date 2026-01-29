# trivy:ignore:AVD-AWS-0034
resource "aws_ecs_cluster" "main" {
  # checkov:skip=CKV_AWS_65: Container insights is configurable via variables
  name = local.ecs_cluster_name
  configuration {
    execute_command_configuration {
      logging    = var.ecs_cluster_execute_command_logging
      kms_key_id = var.ecs_cluster_execute_command_logging != "NONE" ? var.kms_key_arn : null
      dynamic "log_configuration" {
        for_each = var.ecs_cluster_execute_command_logging != "NONE" ? [true] : []
        content {
          cloud_watch_encryption_enabled = length(aws_cloudwatch_log_group.cluster) > 0 && var.kms_key_arn != null ? true : null
          cloud_watch_log_group_name     = length(aws_cloudwatch_log_group.cluster) > 0 ? aws_cloudwatch_log_group.cluster[0].name : null
          s3_bucket_encryption_enabled   = var.ecs_cluster_execute_command_log_s3_bucket_name != null && var.kms_key_arn != null ? true : null
          s3_bucket_name                 = var.ecs_cluster_execute_command_log_s3_bucket_name
          s3_key_prefix                  = var.ecs_cluster_execute_command_log_s3_key_prefix
        }
      }
    }
  }
  dynamic "setting" {
    for_each = var.ecs_cluster_setting_container_insights != null ? [true] : []
    content {
      name  = "containerInsights"
      value = var.ecs_cluster_setting_container_insights
    }
  }
  dynamic "service_connect_defaults" {
    for_each = length(var.ecs_cluster_service_connect_default_namespaces) > 0 ? var.ecs_cluster_service_connect_default_namespaces : []
    content {
      namespace = service_connect_defaults.value
    }
  }
  tags = {
    Name       = local.ecs_cluster_name
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

# trivy:ignore:AVD-AWS-0017
resource "aws_cloudwatch_log_group" "cluster" {
  # checkov:skip=CKV_AWS_338: Retention period is configurable via variables
  count             = var.ecs_cluster_execute_command_logging != "NONE" && var.ecs_cluster_execute_command_log_s3_bucket_name == null ? 1 : 0
  name              = "/${var.system_name}/${var.env_type}/ecs/cluster/${local.ecs_cluster_name}"
  retention_in_days = var.cloudwatch_logs_retention_in_days
  kms_key_id        = var.kms_key_arn
  tags = {
    Name       = "/${var.system_name}/${var.env_type}/ecs/cluster/${local.ecs_cluster_name}"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_iam_role" "execution" {
  name                  = "${var.system_name}-${var.env_type}-ecs-execution-iam-role"
  description           = "ECS execution IAM role"
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
    Name       = "${var.system_name}-${var.env_type}-ecs-execution-iam-role"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_iam_role_policy_attachments_exclusive" "execution" {
  role_name   = aws_iam_role.execution.name
  policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}

resource "aws_iam_role_policy" "logs" {
  count = length(aws_cloudwatch_log_group.cluster) > 0 ? 1 : 0
  name  = "${var.system_name}-${var.env_type}-ecs-execution-logs-iam-policy"
  role  = aws_iam_role.execution.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Sid    = "AllowLogStreamAccess"
          Effect = "Allow"
          Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = ["${aws_cloudwatch_log_group.cluster[0].arn}:*"]
        }
      ],
      (
        var.kms_key_arn != null ? [
          {
            Sid      = "AllowKMSAccess"
            Effect   = "Allow"
            Action   = ["kms:GenerateDataKey"]
            Resource = [var.kms_key_arn]
          }
        ] : []
      )
    )
  })
}

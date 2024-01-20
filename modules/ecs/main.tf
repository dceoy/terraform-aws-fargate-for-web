resource "aws_ecs_cluster" "container" {
  name = local.ecs_cluster_name
  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"
      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.container.name
      }
    }
  }
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = {
    Name       = local.ecs_cluster_name
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_cloudwatch_log_group" "container" {
  name              = local.ecs_cluster_cloudwatch_log_group_name
  retention_in_days = 14
  kms_key_id        = aws_kms_key.container.arn
  tags = {
    Name       = local.ecs_cluster_cloudwatch_log_group_name
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_kms_key" "container" {
  description             = "KMS key for encrypting CloudWatch Logs"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${local.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch to encrypt logs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${local.region}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        Resource = "*"
        Condition = {
          ArnEquals = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${local.region}:${local.account_id}:log-group:${local.ecs_cluster_cloudwatch_log_group_name}"
          }
        }
      }
    ]
  })
  tags = {
    Name       = "${local.ecs_cluster_cloudwatch_log_group_name}-kms-key"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_kms_alias" "container" {
  name          = "alias/${aws_kms_key.container.tags.Name}"
  target_key_id = aws_kms_key.container.arn
}

resource "aws_iam_role" "container" {
  name = "${var.system_name}-${var.env_type}-ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

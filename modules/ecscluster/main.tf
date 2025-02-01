# trivy:ignore:AVD-AWS-0034
resource "aws_ecs_cluster" "main" {
  name = local.ecs_cluster_name
  configuration {
    execute_command_configuration {
      logging    = var.ecs_cluster_execute_command_logging
      kms_key_id = var.ecs_cluster_execute_command_logging != "NONE" ? var.kms_key_arn : null
      dynamic "log_configuration" {
        for_each = var.ecs_cluster_execute_command_logging != "NONE" ? [true] : []
        content {
          cloud_watch_encryption_enabled = length(aws_cloudwatch_log_group.ecs) > 0 && var.kms_key_arn != null ? true : null
          cloud_watch_log_group_name     = length(aws_cloudwatch_log_group.ecs) > 0 ? aws_cloudwatch_log_group.ecs[0].name : null
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
resource "aws_cloudwatch_log_group" "ecs" {
  count             = var.ecs_cluster_execute_command_logging != "NONE" && var.ecs_cluster_execute_command_log_s3_bucket_name == null ? 1 : 0
  name              = "/${var.system_name}/${var.env_type}/ecs/${local.ecs_cluster_name}"
  retention_in_days = var.cloudwatch_logs_retention_in_days
  kms_key_id        = var.kms_key_arn
  tags = {
    Name       = "/${var.system_name}/${var.env_type}/ecs/${local.ecs_cluster_name}"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

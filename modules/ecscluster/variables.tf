variable "system_name" {
  description = "System name"
  type        = string
  default     = "slc"
}

variable "env_type" {
  description = "Environment type"
  type        = string
  default     = "dev"
}

variable "cloudwatch_logs_retention_in_days" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 30
  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.cloudwatch_logs_retention_in_days)
    error_message = "CloudWatch Logs retention in days must be 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653 or 0 (zero indicates never expire logs)"
  }
}

variable "kms_key_arn" {
  description = "KMS key ARN"
  type        = string
  default     = null
}

variable "iam_role_force_detach_policies" {
  description = "Whether to force detaching any IAM policies the IAM role has before destroying it"
  type        = bool
  default     = true
}

variable "ecs_cluster_execute_command_logging" {
  description = "ECS cluster log setting to use for redirecting logs for execute command results"
  type        = string
  default     = "DEFAULT"
  validation {
    condition     = contains(["NONE", "DEFAULT", "OVERRIDE"], var.ecs_cluster_execute_command_logging)
    error_message = "ECS cluster execute command logging must be either NONE, DEFAULT, or OVERRIDE"
  }
}

variable "ecs_cluster_execute_command_log_s3_bucket_name" {
  description = "Name of the S3 bucket to send ECS cluster execute command logs to"
  type        = string
  default     = null
}

variable "ecs_cluster_execute_command_log_s3_key_prefix" {
  description = "S3 key prefix to place ECS cluster execute command logs in"
  type        = string
  default     = null
}

variable "ecs_cluster_setting_container_insights" {
  description = "ECS cluster setting for CloudWatch Container Insights"
  type        = string
  default     = null
  validation {
    condition     = var.ecs_cluster_setting_container_insights == null || contains(["enhanced", "enabled", "disabled"], var.ecs_cluster_setting_container_insights)
    error_message = "ECS cluster setting for CloudWatch Container Insights must be either enhanced, enabled, or disabled"
  }
}

variable "ecs_cluster_service_connect_default_namespaces" {
  description = "ECS cluster default Service Connect namespaces"
  type        = list(string)
  default     = []
}

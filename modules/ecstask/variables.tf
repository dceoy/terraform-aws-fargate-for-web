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

variable "ecs_execution_iam_role_arn" {
  description = "ECS execution IAM role ARN"
  type        = string
}

variable "ecs_task_container_definitions_template_file_path" {
  description = "Path to ECS task container definitions template file"
  type        = string
}

variable "ecs_task_container_definitions_template_file_vars" {
  description = "Variables for ECS task container definitions template file"
  type        = map(string)
  default     = {}
}

variable "ecs_task_definition_family" {
  description = "ECS task definition family"
  type        = string
  default     = null
}

variable "ecs_task_cpu" {
  description = "Number of cpu units used for ECS tasks"
  type        = number
  default     = 256
  validation {
    condition     = var.ecs_task_cpu >= 256
    error_message = "ECS task definition CPU must be greater than or equal to 256"
  }
}

variable "ecs_task_memory" {
  description = "Amount (in MiB) of memory used for ECS tasks"
  type        = number
  default     = 512
  validation {
    condition     = var.ecs_task_memory >= 512
    error_message = "ECS task definition memory must be greater than or equal to 512"
  }
}

variable "ecs_task_runtime_platform_cpu_architecture" {
  description = "Runtime platform CPU architecture for ECS tasks"
  type        = string
  default     = "ARM64"
  validation {
    condition     = var.ecs_task_runtime_platform_cpu_architecture == "ARM64" || var.ecs_task_runtime_platform_cpu_architecture == "X86_64"
    error_message = "Runtime platform CPU architecture for ECS tasks must be ARM64 or X86_64"
  }
}

variable "ecs_task_ephemeral_storage_size_in_gib" {
  description = "Ephemeral storage size in GiB for ECS tasks"
  type        = number
  default     = 0
  validation {
    condition     = var.ecs_task_ephemeral_storage_size_in_gib == 0 || (var.ecs_task_ephemeral_storage_size_in_gib >= 21 && var.ecs_task_ephemeral_storage_size_in_gib <= 200)
    error_message = "Ephemeral storage size in GiB for ECS tasks must be 0 or between 21 and 200"
  }
}

variable "ecs_task_skip_destroy" {
  description = "Whether to retain the old revision when the resource is destroyed or replacement is necessary"
  type        = bool
  default     = false
}

variable "ecs_task_iam_role_policy_arns" {
  description = "IAM role policy ARNs for ECS tasks"
  type        = list(string)
  default     = []
}

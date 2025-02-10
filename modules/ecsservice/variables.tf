variable "system_name" {
  description = "System name"
  type        = string
}

variable "env_type" {
  description = "Environment type"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ALB security group ID"
  type        = string
}

variable "alb_target_group_arn" {
  description = "ALB target group ARN"
  type        = string
}

variable "ecs_cluster_id" {
  description = "ECS cluster ID"
  type        = string
}

variable "ecs_task_definition_arn" {
  description = "ECS task definition ARN"
  type        = string
}

variable "ecs_service_container_name" {
  description = "Name of the container to associate with the ALB"
  type        = string
}

variable "ecs_service_container_port" {
  description = "Port on the container to associate with the ALB"
  type        = number
  default     = 80
}

variable "ecs_service_platform_version" {
  description = "Platform version on which to run the ECS service"
  type        = string
  default     = "LATEST"
}

variable "ecs_service_desired_count" {
  description = "Number of the task instances to place and keep running in the ECS service"
  type        = number
  default     = 0
}

variable "ecs_service_deployment_maximum_percent" {
  description = "Upper limit (as a percentage of the desired count) of running tasks in the ECS service during a deployment"
  type        = number
  default     = null
}

variable "ecs_service_deployment_minimum_healthy_percent" {
  description = "Lower limit (as a percentage of the desired count) of healthy and running tasks in the ECS service during a deployment"
  type        = number
  default     = null
}

variable "ecs_service_health_check_grace_period_seconds" {
  description = "Seconds to ignore failing ALB health checks on newly instantiated ECS service tasks to prevent premature shutdown"
  type        = number
  default     = null
  validation {
    condition     = var.ecs_service_health_check_grace_period_seconds == null || var.ecs_service_health_check_grace_period_seconds >= 0 && var.ecs_service_health_check_grace_period_seconds <= 2147483647
    error_message = "ECS service health check grace period seconds must be between 0 and 2147483647"
  }
}

variable "ecs_service_availability_zone_rebalancing" {
  description = "Automatic redistribution of ECS service tasks across AZs"
  type        = string
  default     = "DISABLED"
}

variable "ecs_service_enable_ecs_managed_tags" {
  description = "Whether to enable ECS managed tags for the tasks within the service"
  type        = bool
  default     = null
}

variable "ecs_service_enable_execute_command" {
  description = "Whether to enable ECS Exec for the tasks within the service"
  type        = bool
  default     = null
}

variable "ecs_service_propagate_tags" {
  description = "Whether to propagate the tags from the ECS task definition or the ECS service to the ECS tasks"
  type        = string
  default     = null
  validation {
    condition     = var.ecs_service_propagate_tags == null || contains(["SERVICE", "TASK_DEFINITION"], var.ecs_service_propagate_tags)
    error_message = "ECS service propagate tags must be SERVICE or TASK_DEFINITION"
  }
}

variable "ecs_service_force_delete" {
  description = "Whether to enable to delete the ECS service even if it wasn't scaled down to zero tasks"
  type        = bool
  default     = null
}

variable "ecs_service_force_new_deployment" {
  description = "Whether to enable to force a new task deployment of the ECS service"
  type        = bool
  default     = null
}

variable "ecs_service_wait_for_steady_state" {
  description = "Whether to make Terraform wait for the ECS service to reach a steady state before continuing"
  type        = bool
  default     = false
}

variable "ecs_service_triggers" {
  description = "Map of arbitrary triggers for redeployment of the ECS service (useful with plantimestamp())"
  type        = map(string)
  default     = null
}

variable "ecs_service_deployment_controller_type" {
  description = "Type of deployment controller for the ECS service"
  type        = string
  default     = null
  validation {
    condition     = var.ecs_service_deployment_controller_type == null || contains(["CODE_DEPLOY", "ECS", "EXTERNAL"], var.ecs_service_deployment_controller_type)
    error_message = "ECS service deployment controller type must be CODE_DEPLOY, ECS, or EXTERNAL"
  }
}

variable "ecs_service_alarms" {
  description = "CloudWatch alarms for the ECS service"
  type        = map(any)
  default     = {}
  validation {
    condition     = alltrue([for k in keys(var.ecs_service_alarms) : contains(["alarm_names", "enable", "rollback"], k)])
    error_message = "ECS service alarms allow only alarm_names, enable, and rollback as keys"
  }
}

variable "ecs_service_deployment_circuit_breaker" {
  description = "Deployment circuit breaker for the ECS service"
  type        = map(any)
  default     = {}
  validation {
    condition     = alltrue([for k in keys(var.ecs_service_deployment_circuit_breaker) : contains(["enable", "rollback"], k)])
    error_message = "ECS service deployment circuit breaker allow only enable and rollback as keys"
  }
}

variable "ecs_service_ordered_placement_strategy" {
  description = "Service level strategy rules for ECS service task placement (list from top to bottom in order of precedence)"
  type        = list(map(string))
  default     = []
  validation {
    condition     = alltrue([for s in var.ecs_service_ordered_placement_strategy : alltrue([for k in keys(s) : contains(["field", "type"], k)])]) && length(var.ecs_service_ordered_placement_strategy) <= 5
    error_message = "ECS service ordered placement strategy allow only field and type as keys and maximum 5 blocks"
  }
}

variable "ecs_service_placement_constraints" {
  description = "Rules for ECS service task placement"
  type        = list(map(string))
  default     = []
  validation {
    condition     = alltrue([for s in var.ecs_service_placement_constraints : alltrue([for k in keys(s) : contains(["expression", "type"], k)])]) && length(var.ecs_service_placement_constraints) <= 10
    error_message = "ECS service placement constraints allow only expression and type as keys and maximum 10 blocks"
  }
}

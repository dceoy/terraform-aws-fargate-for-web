variable "system_name" {
  description = "System name"
  type        = string
}

variable "env_type" {
  description = "Environment type"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN"
  type        = string
  default     = null
}

variable "cloudwatch_log_metric_filter_log_groups" {
  description = "CloudWatch Logs log groups to create a metric filter for (key: key name, value: log group name)"
  type        = map(string)
  default     = {}
}

variable "cloudwatch_log_metric_filter_error_pattern" {
  description = "CloudWatch log metric filter pattern for error logs"
  type        = string
  default     = "%error|Error|ERROR%"
}

variable "cloudwatch_metric_alarm_period" {
  description = "Period in seconds over which the specified statistic is applied for CloudWatch metric alarms"
  type        = number
  default     = 300
  validation {
    condition     = var.cloudwatch_metric_alarm_period == 10 || var.cloudwatch_metric_alarm_period == 20 || var.cloudwatch_metric_alarm_period == 30 || (var.cloudwatch_metric_alarm_period % 60 == 0)
    error_message = "The period must be a multiple of 10 or 60 seconds."
  }
}

variable "cloudwatch_event_rule_health_services" {
  description = "Services to monitor for AWS Health events for CloudWatch EventBridge rule"
  type        = list(string)
  default     = []
}

variable "cloudwatch_event_rule_health_event_type_categories" {
  description = "Event type categories to monitor for AWS Health events for CloudWatch EventBridge rule"
  type        = list(string)
  default     = ["issue", "scheduledChange", "accountNotification"]
}

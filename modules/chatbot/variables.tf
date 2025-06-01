variable "system_name" {
  description = "System name"
  type        = string
}

variable "env_type" {
  description = "Environment type"
  type        = string
}

variable "iam_role_force_detach_policies" {
  description = "Whether to force detaching any IAM policies the IAM role has before destroying it"
  type        = bool
  default     = true
}

variable "sns_topic_arns" {
  description = "SNS topic ARNs"
  type        = list(string)
  default     = []
}

variable "chatbot_slack_workspace_id" {
  description = "ID of the Slack workspace authorized with Chatbot"
  type        = string
  default     = null
}

variable "chatbot_slack_channel_id" {
  description = "ID of the Slack channel for Chatbot"
  type        = string
  default     = null
}

variable "guardrail_policy_arns" {
  description = "List of IAM policy ARNs that are applied as channel guardrails for Chatbot"
  type        = list(string)
  default     = []
}

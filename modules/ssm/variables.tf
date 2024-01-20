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

variable "idle_session_timeout" {
  description = "Idle session timeout"
  type        = number
  default     = 60
}

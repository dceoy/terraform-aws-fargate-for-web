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

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = null
}

variable "codecommit_repository_name" {
  description = "CodeCommit repository name"
  type        = string
  default     = null
}

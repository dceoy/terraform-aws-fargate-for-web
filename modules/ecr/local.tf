locals {
  ecr_repository_name        = var.ecr_repository_name != null ? var.ecr_repository_name : "${var.system_name}-${var.env_type}-ecr-repository"
  codecommit_repository_name = var.codecommit_repository_name != null ? var.codecommit_repository_name : "${var.system_name}-${var.env_type}-codecommit-repository"
}

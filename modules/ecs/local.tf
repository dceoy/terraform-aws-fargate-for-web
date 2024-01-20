data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  account_id       = data.aws_caller_identity.current.account_id
  region           = data.aws_region.current.name
  ecs_cluster_name = "${var.system_name}-${var.env_type}-ecs-cluster"
}

locals {
  ecs_cluster_cloudwatch_log_group_name = "${local.ecs_cluster_name}-log-group"
}

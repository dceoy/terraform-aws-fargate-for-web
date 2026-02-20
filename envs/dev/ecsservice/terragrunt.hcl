include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = "vpc-12345678"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

dependency "subnet" {
  config_path = "../subnet"
  mock_outputs = {
    private_subnet_ids = ["subnet-23456789", "subnet-98765432"]
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

dependency "ecscluster" {
  config_path = "../ecscluster"
  mock_outputs = {
    ecs_cluster_id = "cluster-12345678"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

dependency "ecstask" {
  config_path = "../ecstask"
  mock_outputs = {
    ecs_task_definition_arn = "arn:aws:ecs:us-west-2:123456789012:task-definition/task-12345678"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

dependency "alb" {
  config_path = "../alb"
  mock_outputs = {
    lb_security_group_id = "sg-12345678"
    lb_target_group_arn  = "arn:aws:elasticloadbalancing:us-west-2:123456789012:targetgroup/target-12345678"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

inputs = {
  vpc_id                  = dependency.vpc.outputs.vpc_id
  private_subnet_ids      = dependency.subnet.outputs.private_subnet_ids
  alb_security_group_id   = dependency.alb.outputs.lb_security_group_id
  alb_target_group_arn    = dependency.alb.outputs.lb_target_group_arn
  ecs_cluster_id          = dependency.ecscluster.outputs.ecs_cluster_id
  ecs_task_definition_arn = dependency.ecstask.outputs.ecs_task_definition_arn
}

terraform {
  source = "${get_repo_root()}/modules/ecsservice"
}

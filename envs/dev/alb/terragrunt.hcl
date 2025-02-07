include "root" {
  path   = find_in_parent_folders("root.hcl")
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id         = "vpc-12345678"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "subnet" {
  config_path = "../subnet"
  mock_outputs = {
    public_subnet_ids = ["subnet-23456789", "subnet-98765432"]
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

inputs = {
  vpc_id               = dependency.vpc.outputs.vpc_id
  public_subnet_ids    = dependency.subnet.outputs.public_subnet_ids
}

terraform {
  source = "${get_repo_root()}/modules/alb"
}

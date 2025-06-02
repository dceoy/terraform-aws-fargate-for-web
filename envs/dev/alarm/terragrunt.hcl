include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "kms" {
  config_path = "../kms"
  mock_outputs = {
    kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "ecscluster" {
  config_path = "../ecscluster"
  mock_outputs = {
    ecs_cluster_cloudwatch_logs_log_group_name = "/aws/ecs/cluster/my-ecs-cluster"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

dependency "ecstask" {
  config_path = "../ecstask"
  mock_outputs = {
    ecs_task_cloudwatch_logs_log_group_name = "/aws/ecs/task/my-ecs-task"
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

inputs = {
  kms_key_arn = include.root.inputs.create_kms_key ? dependency.kms.outputs.kms_key_arn : null
  cloudwatch_log_metric_filter_log_groups = {
    "ecs-cluster" = dependency.ecscluster.outputs.ecs_cluster_cloudwatch_logs_log_group_name
    "ecs-task"    = dependency.ecstask.outputs.ecs_task_cloudwatch_logs_log_group_name
  }
}

terraform {
  source = "${get_repo_root()}/modules/alarm"
}

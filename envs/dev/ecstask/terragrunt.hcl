include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

dependency "kms" {
  config_path = "../kms"
  mock_outputs = {
    kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

dependency "docker" {
  config_path = "../docker"
  mock_outputs = {
    docker_registry_primary_image_uri = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:latest"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

dependency "ecscluster" {
  config_path = "../ecscluster"
  mock_outputs = {
    ecs_execution_iam_role_arn = "arn:aws:iam::123456789012:role/my-execution-role"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
  mock_outputs_merge_strategy_with_state  = "shallow"
}

inputs = {
  kms_key_arn                = include.root.inputs.create_kms_key ? dependency.kms.outputs.kms_key_arn : null
  ecs_execution_iam_role_arn = dependency.ecscluster.outputs.ecs_execution_iam_role_arn
  ecs_task_container_definitions_template_file_vars = {
    name                        = include.root.inputs.ecs_service_container_name
    image                       = dependency.docker.outputs.docker_registry_primary_image_uri
    system-name                 = include.root.inputs.system_name
    env-type                    = include.root.inputs.env_type
    port-mapping-container-port = include.root.inputs.ecs_service_container_port
    port-mapping-host-port      = include.root.inputs.ecs_service_container_port
    restart-attempt-period      = include.root.inputs.ecs_task_container_restart_attempt_period
  }
}

terraform {
  source = "${get_repo_root()}/modules/ecstask"
}

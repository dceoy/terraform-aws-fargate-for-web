locals {
  image_name           = "streamlit-app"
  fargate_architecture = "ARM64"
  docker_image_build_platforms = {
    "X86_64" = "linux/amd64"
    "ARM64"  = "linux/arm64"
  }
  repo_root   = get_repo_root()
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  ecr_address = "${local.env_vars.locals.account_id}.dkr.ecr.${local.env_vars.locals.region}.amazonaws.com"
}

terraform {
  extra_arguments "parallelism" {
    commands  = get_terraform_commands_that_need_parallelism()
    arguments = ["-parallelism=2"]
  }
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket       = local.env_vars.locals.terraform_s3_bucket
    key          = "${basename(local.repo_root)}/${local.env_vars.locals.system_name}/${path_relative_to_include()}/terraform.tfstate"
    region       = local.env_vars.locals.region
    encrypt      = true
    use_lockfile = true
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
  provider "aws" {
    region = "${local.env_vars.locals.region}"
    default_tags {
      tags = {
        SystemName = "${local.env_vars.locals.system_name}"
        EnvType    = "${local.env_vars.locals.env_type}"
      }
    }
  }
  EOF
}

catalog {
  urls = [
    "github.com/dceoy/terraform-aws-docker-based-lambda",
    "github.com/dceoy/terraform-aws-vpc-for-slc",
    "${local.repo_root}/modules/ecscluster",
    "${local.repo_root}/modules/ecstask",
    "${local.repo_root}/modules/ecsservice"
  ]
}

inputs = {
  system_name                               = local.env_vars.locals.system_name
  env_type                                  = local.env_vars.locals.env_type
  create_kms_key                            = true
  kms_key_deletion_window_in_days           = 30
  kms_key_rotation_period_in_days           = 365
  create_io_s3_bucket                       = true
  create_awslogs_s3_bucket                  = true
  create_s3logs_s3_bucket                   = true
  s3_force_destroy                          = true
  s3_noncurrent_version_expiration_days     = 7
  s3_abort_incomplete_multipart_upload_days = 7
  s3_expired_object_delete_marker           = true
  vpc_cidr_block                            = "10.0.0.0/16"
  vpc_secondary_cidr_blocks                 = []
  vpc_assign_generated_ipv6_cidr_block      = false
  cloudwatch_logs_retention_in_days         = 30
  private_subnet_count                      = 2
  public_subnet_count                       = 2
  subnet_newbits                            = 8
  nat_gateway_count                         = 0
  vpc_interface_endpoint_services = [
    "ecr.dkr", "ecr.api", "ecs", "ecs-agent", "ecs-telemetry", "logs", "kms", "ssm", "ssmmessages"
  ]
  ecr_repository_name                               = local.image_name
  ecr_image_secondary_tags                          = compact(split("\n", get_env("DOCKER_METADATA_OUTPUT_TAGS", "latest")))
  ecr_image_tag_mutability                          = "MUTABLE"
  ecr_force_delete                                  = true
  ecr_lifecycle_policy_semver_image_count           = 9999
  ecr_lifecycle_policy_any_image_count              = 10
  ecr_lifecycle_policy_untagged_image_days          = 7
  create_io_s3_bucket                               = true
  create_awslogs_s3_bucket                          = true
  create_s3logs_s3_bucket                           = true
  s3_force_destroy                                  = true
  s3_noncurrent_version_expiration_days             = 7
  s3_abort_incomplete_multipart_upload_days         = 7
  s3_expired_object_delete_marker                   = true
  enable_s3_server_access_logging                   = true
  docker_image_force_remove                         = true
  docker_image_build                                = local.env_vars.locals.docker_image_build
  docker_image_build_context                        = "${local.repo_root}/src"
  docker_image_build_dockerfile                     = "Dockerfile"
  docker_image_build_build_args                     = {}
  docker_image_build_platform                       = local.docker_image_build_platforms[local.fargate_architecture]
  docker_image_build_target                         = "app"
  docker_image_primary_tag                          = get_env("DOCKER_PRIMARY_TAG", format("sha-%s", run_cmd("--terragrunt-quiet", "git", "rev-parse", "--short", "HEAD")))
  docker_host                                       = get_env("DOCKER_HOST", "unix:///var/run/docker.sock")
  cloudwatch_logs_retention_in_days                 = 30
  iam_role_force_detach_policies                    = true
  ecs_cluster_execute_command_logging               = "OVERRIDE"
  ecs_cluster_setting_container_insights            = "enhanced"
  ecs_task_cpu                                      = 256
  ecs_task_memory                                   = 512
  ecs_task_runtime_platform_cpu_architecture        = local.fargate_architecture
  ecs_task_ephemeral_storage_size_in_gib            = 200
  ecs_task_skip_destroy                             = false
  ecs_task_iam_role_policy_arns                     = []
  ecs_task_container_definitions_template_file_path = find_in_parent_folders("ecs-task-container-definitions.json.tpl")
  lb_security_group_ingress_from_port               = 0
  lb_security_group_ingress_to_port                 = 0
  lb_security_group_ingress_protocol                = "-1"
  lb_security_group_ingress_ipv4_cidr_blocks        = ["0.0.0.0/0"]
  lb_security_group_ingress_ipv6_cidr_blocks        = ["::/0"]
  lb_client_keep_alive                              = 3600
  lb_desync_mitigation_mode                         = "defensive"
  lb_enable_delete_protection                       = false
  lb_enable_http2                                   = true
  lb_enable_tls_version_and_cipher_suite_headers    = false
  lb_enable_xff_client_port                         = false
  lb_enable_waf_fail_open                           = false
  lb_enable_zonal_shift                             = false
  lb_idle_timeout                                   = 60
  lb_ip_address_type                                = "ipv4"
  lb_preserve_host_header                           = false
  lb_xff_header_processing_mode                     = "append"
  lb_target_group_port                              = 80
  lb_target_group_protocol                          = "HTTP"
  lb_target_group_protocol_version                  = "HTTP1"
  lb_target_group_ip_address_type                   = "ipv4"
  lb_target_group_deregistration_delay              = 300
  lb_target_group_load_balancing_algorithm_type     = "round_robin"
  lb_target_group_load_balancing_anomaly_mitigation = "off"
  lb_target_group_load_balancing_cross_zone_enabled = "use_load_balancer_configuration"
  lb_target_group_preserve_client_ip                = false
  lb_target_group_slow_start                        = 0
  lb_target_group_stickiness                        = {}
  lb_target_group_health_check                      = {}
  lb_target_group_health_dns_failover               = {}
  lb_target_group_health_unhealthy_state_routing    = {}
  lb_listener_port                                  = 80
  lb_listener_protocol                              = "HTTP"
  lb_listener_ssl_policy                            = "ELBSecurityPolicy-2016-08"
  lb_listener_mutual_authentication                 = {}
  lb_listener_stickiness                            = {}
}

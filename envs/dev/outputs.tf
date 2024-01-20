output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_default_security_group_id" {
  description = "VPC default security group ID"
  value       = module.vpc.vpc_default_security_group_id
}

output "vpc_default_network_acl_id" {
  description = "VPC default network ACL ID"
  value       = module.vpc.vpc_default_network_acl_id
}

output "vpc_default_route_table_id" {
  description = "VPC default route table ID"
  value       = module.vpc.vpc_default_route_table_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr_block
}

output "vpc_flow_log_id" {
  description = "VPC flow log"
  value       = module.vpc.vpc_flow_log_id
}

output "vpc_flow_log_cloudwatch_log_group_name" {
  description = "VPC flow log group"
  value       = module.vpc.vpc_flow_log_cloudwatch_log_group_name
}

output "vpc_flow_log_iam_role_arn" {
  description = "VPC flow log IAM role ARN"
  value       = module.vpc.vpc_flow_log_iam_role_arn
}

output "vpc_flow_log_kms_key_arn" {
  description = "VPC flow log KMS key ARN"
  value       = module.vpc.vpc_flow_log_kms_key_arn
}

output "private_subnet_azs" {
  description = "Private subnet AZs"
  value       = module.subnet.private_subnet_azs
}

output "private_subnet_cidr_blocks" {
  description = "Private subnet CIDR blocks"
  value       = module.subnet.private_subnet_cidr_blocks
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.subnet.private_subnet_ids
}

output "private_route_table_ids" {
  description = "Private route table IDs"
  value       = module.subnet.private_route_table_ids
}

output "private_security_group_id" {
  description = "Private security group ID"
  value       = module.subnet.private_security_group_id
}

output "s3_gateway_endpoint" {
  description = "S3 gateway endpoint"
  value       = module.subnet.s3_gateway_endpoint
}

output "dynamodb_gateway_endpoint" {
  description = "DynamoDB gateway endpoint"
  value       = module.subnet.dynamodb_gateway_endpoint
}

output "public_subnet_azs" {
  description = "Public subnet AZs"
  value       = module.subnet.public_subnet_azs
}

output "public_subnet_cidr_blocks" {
  description = "Public subnet CIDR blocks"
  value       = module.subnet.public_subnet_cidr_blocks
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.subnet.public_subnet_ids
}

output "public_route_table_ids" {
  description = "Public route table IDs"
  value       = module.subnet.public_route_table_ids
}

output "internet_gateway_id" {
  description = "Internet gateway ID"
  value       = module.subnet.internet_gateway_id
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = length(module.nat) > 0 ? module.nat[0].nat_gateway_ids : null
}

output "nat_gateway_public_ips" {
  description = "The public IPs of the NAT Gateways"
  value       = length(module.nat) > 0 ? module.nat[0].nat_gateway_public_ips : null
}

output "ec2_interface_endpoint" {
  description = "EC2 interface endpoint"
  value       = length(module.vpce) > 0 ? module.vpce[0].ec2_interface_endpoint : null
}

output "ec2_messages_interface_endpoint" {
  description = "EC2 messages interface endpoint"
  value       = length(module.vpce) > 0 ? module.vpce[0].ec2_messages_interface_endpoint : null
}

output "ssm_interface_endpoint" {
  description = "SSM interface endpoint"
  value       = length(module.vpce) > 0 ? module.vpce[0].ssm_interface_endpoint : null
}

output "ssm_messages_interface_endpoint" {
  description = "SSM messages interface endpoint"
  value       = length(module.vpce) > 0 ? module.vpce[0].ssm_messages_interface_endpoint : null
}

output "secrets_manager_interface_endpoint" {
  description = "Secrets Manager interface endpoint"
  value       = length(module.vpce) > 0 ? module.vpce[0].secrets_manager_interface_endpoint : null
}

output "ecr_dkr_interface_endpoint" {
  description = "ECR DKR interface endpoint"
  value       = length(module.vpce) > 0 ? module.vpce[0].ecr_dkr_interface_endpoint : null
}

output "ecr_api_interface_endpoint" {
  description = "ECR API interface endpoint"
  value       = length(module.vpce) > 0 ? module.vpce[0].ecr_api_interface_endpoint : null
}

output "ecs_interface_endpoint" {
  description = "ECS interface endpoint"
  value       = length(module.vpce) > 0 ? module.vpce[0].ecs_interface_endpoint : null
}

output "ecs_agent_interface_endpoint" {
  description = "ECS agent interface endpoint"
  value       = length(module.vpce) > 0 ? module.vpce[0].ecs_agent_interface_endpoint : null
}

output "ecs_telemetry_interface_endpoint" {
  description = "ECS telemetry interface endpoint"
  value       = length(module.vpce) > 0 ? module.vpce[0].ecs_telemetry_interface_endpoint : null
}

output "logs_interface_endpoint" {
  description = "Logs interface endpoint"
  value       = length(module.vpce) > 0 ? module.vpce[0].logs_interface_endpoint : null
}

output "ssm_session_document_name" {
  description = "SSM session document name"
  value       = module.ssm.ssm_session_document_name
}

output "ssm_session_cloudwatch_log_group_name" {
  description = "SSM session CloudWatch log group name"
  value       = module.ssm.ssm_session_cloudwatch_log_group_name
}

output "ssm_session_kms_key_arn" {
  description = "SSM session KMS key ARN"
  value       = module.ssm.ssm_session_kms_key_arn
}

output "ssm_session_log_iam_policy_arn" {
  description = "SSM session log IAM policy ARN"
  value       = module.ssm.ssm_session_log_iam_policy_arn
}

output "ecs_cluster_id" {
  description = "ECS cluster ID"
  value       = module.ecs.ecs_cluster_id
}

output "ecs_cluster_cloudwatch_log_group_name" {
  description = "ECS cluster CloudWatch log group name"
  value       = module.ecs.ecs_cluster_cloudwatch_log_group_name
}

output "ecs_cluster_kms_key_arn" {
  description = "ECS cluster KMS key ARN"
  value       = module.ecs.ecs_cluster_kms_key_arn
}

output "ecs_task_execution_iam_role_arn" {
  description = "ECS task execution IAM role ARN"
  value       = module.ecs.ecs_task_execution_iam_role_arn
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.ecr_repository_url
}

output "codecommit_repository_id" {
  description = "CodeCommit repository ID"
  value       = module.ecr.codecommit_repository_id
}

output "codecommit_repository_clone_url_http" {
  description = "CodeCommit repository URL for cloning over HTTPS"
  value       = module.ecr.codecommit_repository_clone_url_http
}

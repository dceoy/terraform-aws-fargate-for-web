module "vpc" {
  source              = "github.com/dceoy/terraform-aws-vpc-for-slc//modules/vpc?ref=v0.1.1"
  system_name         = var.system_name
  env_type            = var.env_type
  vpc_cidr_block      = var.vpc_cidr_block
  enable_vpc_flow_log = var.enable_vpc_flow_log
}

module "subnet" {
  source               = "github.com/dceoy/terraform-aws-vpc-for-slc//modules/subnet?ref=v0.1.1"
  vpc_id               = module.vpc.vpc_id
  system_name          = var.system_name
  env_type             = var.env_type
  private_subnet_count = var.private_subnet_count
  public_subnet_count  = var.public_subnet_count
  subnet_newbits       = var.subnet_newbits
}

module "nat" {
  source                  = "github.com/dceoy/terraform-aws-vpc-for-slc//modules/nat?ref=v0.1.1"
  count                   = var.create_nat_gateways && var.public_subnet_count > 0 && var.private_subnet_count > 0 ? 1 : 0
  public_subnet_ids       = module.subnet.public_subnet_ids
  private_route_table_ids = module.subnet.private_route_table_ids
  system_name             = var.system_name
  env_type                = var.env_type
}

module "vpce" {
  source             = "github.com/dceoy/terraform-aws-vpc-for-slc//modules/vpce?ref=v0.1.1"
  count              = var.create_vpc_interface_endpoints && var.private_subnet_count > 0 ? 1 : 0
  private_subnet_ids = module.subnet.private_subnet_ids
  security_group_ids = [module.subnet.private_security_group_id]
  system_name        = var.system_name
  env_type           = var.env_type
}

module "ssm" {
  source      = "github.com/dceoy/terraform-aws-vpc-for-slc//modules/ssm?ref=v0.1.1"
  system_name = var.system_name
  env_type    = var.env_type
}

module "ecr" {
  source                     = "../../modules/ecr"
  system_name                = var.system_name
  env_type                   = var.env_type
  ecr_repository_name        = var.ecr_repository_name
  codecommit_repository_name = var.codecommit_repository_name
}

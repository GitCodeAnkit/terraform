# Main Terraform configuration for Production Environment
# This file serves as the entry point for the production infrastructure

# Local values for computed configurations
locals {
  # Common resource naming
  name_prefix = "${var.project_name}-${var.environment}"
}

# VPC Module
module "vpc" {
  source = "../modules/vpc"

  vpc_cidr             = var.vpc_cidr
  name_prefix          = local.name_prefix
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  common_tags          = var.common_tags
}

# Subnets Module
module "subnets" {
  source = "../modules/subnets"

  vpc_id                   = module.vpc.vpc_id
  internet_gateway_id      = module.vpc.internet_gateway_id
  name_prefix              = local.name_prefix
  availability_zones       = var.availability_zones
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_subnet_cidrs_1
  private_db_subnet_cidrs  = var.private_subnet_cidrs_2
  common_tags              = var.common_tags
}

# NAT Gateway Module
module "nat_gateway" {
  source = "../modules/nat-gateway"

  vpc_id                  = module.vpc.vpc_id
  internet_gateway_id     = module.vpc.internet_gateway_id
  name_prefix             = local.name_prefix
  nat_gateway_count       = 2
  public_subnet_ids       = module.subnets.public_subnet_ids
  private_app_subnet_ids  = module.subnets.private_app_subnet_ids
  private_db_subnet_ids   = module.subnets.private_db_subnet_ids
  common_tags             = var.common_tags
}

# VPC Endpoints Module
module "vpc_endpoints" {
  source = "../modules/vpc-endpoints"

  vpc_id                   = module.vpc.vpc_id
  aws_region               = var.aws_region
  name_prefix              = local.name_prefix
  route_table_ids          = concat([module.subnets.public_route_table_id], module.nat_gateway.private_route_table_ids)
  enable_dynamodb_endpoint = true
  common_tags              = var.common_tags
}
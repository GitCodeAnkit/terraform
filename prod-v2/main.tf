# Production Environment - Improved Modular Structure
# Using the enhanced module architecture

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  
  # NAT Gateway distribution logic for your requirement:
  # 2 NAT gateways - one serves AZ 1a+1b, another serves AZ 1c
  nat_gateway_count = 2
}

# Networking Module - All networking infrastructure
module "networking" {
  source = "../modules-v2/networking"

  name_prefix          = local.name_prefix
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  
  # Subnet configuration
  enable_private_subnets   = true
  enable_database_subnets  = true
  
  # CIDR blocks from variables
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_subnet_cidrs_1
  private_db_subnet_cidrs  = var.private_subnet_cidrs_2
  
  # NAT Gateway configuration
  enable_nat_gateway      = true
  nat_gateway_count       = local.nat_gateway_count
  
  # DNS configuration
  enable_dns_hostnames    = var.enable_dns_hostnames
  enable_dns_support      = var.enable_dns_support
  
  common_tags = var.common_tags
}

# Routing Module - All routing logic
module "routing" {
  source = "../modules-v2/routing"

  name_prefix         = local.name_prefix
  vpc_id             = module.networking.vpc_id
  internet_gateway_id = module.networking.internet_gateway_id
  
  # NAT Gateway routing
  nat_gateway_ids    = module.networking.nat_gateway_ids
  nat_gateway_count  = local.nat_gateway_count
  
  # Subnet associations
  public_subnet_ids      = module.networking.public_subnet_ids
  private_app_subnet_ids = module.networking.private_app_subnet_ids
  private_db_subnet_ids  = module.networking.private_db_subnet_ids
  
  # Routing configuration
  enable_nat_routes              = true
  create_database_route_table    = false  # Use same routing as app subnets
  
  common_tags = var.common_tags
}

# VPC Endpoints Module - Enhanced endpoint management
module "vpc_endpoints" {
  source = "../modules-v2/vpc-endpoints"

  name_prefix    = local.name_prefix
  vpc_id        = module.networking.vpc_id
  aws_region    = var.aws_region
  route_table_ids = module.routing.all_route_table_ids
  
  # Gateway endpoints (your requirements)
  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = true
  
  # Optional interface endpoints (commented out for cost)
  enable_ec2_endpoint      = false
  enable_ssm_endpoints     = false
  
  # Private subnets for interface endpoints (if enabled)
  private_subnet_ids = module.networking.private_app_subnet_ids
  
  common_tags = var.common_tags
}

# Production environment variables

aws_region    = "us-east-1"
environment   = "prod"
project_name  = "terraform-infra"

# VPC Configuration
vpc_cidr = "10.10.0.0/16"

# Availability Zones for production
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

# Subnet CIDR blocks
public_subnet_cidrs     = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
private_subnet_cidrs_1  = ["10.10.10.0/24", "10.10.20.0/24", "10.10.30.0/24"]
private_subnet_cidrs_2  = ["10.10.11.0/24", "10.10.21.0/24", "10.10.31.0/24"]

# Network configuration
enable_dns_hostnames = true
enable_dns_support   = true
enable_nat_gateway   = true
single_nat_gateway   = false

# Common tags
common_tags = {
  Project     = "terraform-infra"
  Environment = "prod"
  ManagedBy   = "terraform"
  Owner       = "DevOps Team"
  CostCenter  = "Engineering"
}

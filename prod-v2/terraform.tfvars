# Production environment variables

aws_region    = "ap-south-1"
environment   = "prod"
project_name  = "terraform-infra"

# VPC Configuration
vpc_cidr = "10.10.0.0/16"

# Availability Zones for production

availability_zones = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]

# Subnet CIDR blocks
public_subnet_cidrs     = ["10.10.192.0/20", "10.10.208.0/20", "10.10.224.0/20"]
private_subnet_cidrs_1  = ["10.10.96.0/19", "10.10.128.0/19", "10.10.160.0/19"]
private_subnet_cidrs_2  = ["10.10.0.0/19", "10.10.32.0/19", "10.10.64.0/19"]

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

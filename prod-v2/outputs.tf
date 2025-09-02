# Production Environment - Outputs (Improved Structure)

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.networking.vpc_cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.networking.internet_gateway_id
}

# Subnet Outputs
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "List of private application subnet IDs"
  value       = module.networking.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "List of private database subnet IDs"
  value       = module.networking.private_db_subnet_ids
}

output "availability_zones" {
  description = "List of availability zones used"
  value       = module.networking.availability_zones
}

# NAT Gateway Outputs
output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = module.networking.nat_gateway_ids
}

output "nat_gateway_public_ips" {
  description = "List of NAT Gateway public IPs"
  value       = module.networking.nat_gateway_public_ips
}

# Routing Outputs
output "public_route_table_id" {
  description = "ID of the public route table"
  value       = module.routing.public_route_table_id
}

output "private_route_table_ids" {
  description = "List of private route table IDs"
  value       = module.routing.private_route_table_ids
}

# VPC Endpoint Outputs
output "s3_vpc_endpoint_id" {
  description = "ID of the S3 VPC endpoint"
  value       = module.vpc_endpoints.s3_vpc_endpoint_id
}

output "dynamodb_vpc_endpoint_id" {
  description = "ID of the DynamoDB VPC endpoint"
  value       = module.vpc_endpoints.dynamodb_vpc_endpoint_id
}

# Summary Outputs
output "infrastructure_summary" {
  description = "Summary of created infrastructure"
  value = {
    vpc_id              = module.networking.vpc_id
    availability_zones  = module.networking.availability_zones
    nat_gateway_count   = module.networking.nat_gateway_count
    public_subnets      = length(module.networking.public_subnet_ids)
    private_app_subnets = length(module.networking.private_app_subnet_ids)
    private_db_subnets  = length(module.networking.private_db_subnet_ids)
    vpc_endpoints       = length(module.vpc_endpoints.all_vpc_endpoint_ids)
  }
}

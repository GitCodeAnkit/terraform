# Outputs for the infrastructure

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

# Subnet Outputs
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.subnets.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "IDs of the private application subnets"
  value       = module.subnets.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "IDs of the private database subnets"
  value       = module.subnets.private_db_subnet_ids
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = module.subnets.public_route_table_id
}

# NAT Gateway Outputs
output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = module.nat_gateway.nat_gateway_ids
}

output "nat_gateway_public_ips" {
  description = "Public IPs of the NAT Gateways"
  value       = module.nat_gateway.nat_gateway_public_ips
}

output "private_route_table_ids" {
  description = "IDs of the private route tables"
  value       = module.nat_gateway.private_route_table_ids
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

# General Outputs
output "availability_zones" {
  description = "List of availability zones used"
  value       = module.subnets.availability_zones
}

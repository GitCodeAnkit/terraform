# Networking Module - Outputs

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = aws_vpc.main.arn
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

# Subnet Outputs
output "public_subnet_ids" {
  description = "List of IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "public_subnet_arns" {
  description = "List of ARNs of the public subnets"
  value       = aws_subnet.public[*].arn
}

output "public_subnets_cidr_blocks" {
  description = "List of CIDR blocks of the public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "private_app_subnet_ids" {
  description = "List of IDs of the private application subnets"
  value       = aws_subnet.private_app[*].id
}

output "private_app_subnet_arns" {
  description = "List of ARNs of the private application subnets"
  value       = aws_subnet.private_app[*].arn
}

output "private_app_subnets_cidr_blocks" {
  description = "List of CIDR blocks of the private application subnets"
  value       = aws_subnet.private_app[*].cidr_block
}

output "private_db_subnet_ids" {
  description = "List of IDs of the private database subnets"
  value       = aws_subnet.private_db[*].id
}

output "private_db_subnet_arns" {
  description = "List of ARNs of the private database subnets"
  value       = aws_subnet.private_db[*].arn
}

output "private_db_subnets_cidr_blocks" {
  description = "List of CIDR blocks of the private database subnets"
  value       = aws_subnet.private_db[*].cidr_block
}

# NAT Gateway Outputs
output "nat_gateway_ids" {
  description = "List of IDs of the NAT Gateways"
  value       = aws_nat_gateway.main[*].id
}

output "nat_gateway_public_ips" {
  description = "List of public Elastic IP addresses of the NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

output "elastic_ip_ids" {
  description = "List of IDs of the Elastic IP addresses for NAT Gateways"
  value       = aws_eip.nat[*].id
}

# Availability Zone Outputs
output "availability_zones" {
  description = "List of availability zones used"
  value       = local.azs
}

# Computed Values
output "nat_gateway_count" {
  description = "Number of NAT gateways created"
  value       = length(aws_nat_gateway.main)
}

output "public_subnet_count" {
  description = "Number of public subnets created"
  value       = length(aws_subnet.public)
}

output "private_app_subnet_count" {
  description = "Number of private application subnets created"
  value       = length(aws_subnet.private_app)
}

output "private_db_subnet_count" {
  description = "Number of private database subnets created"
  value       = length(aws_subnet.private_db)
}

# Subnets Module - Outputs

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "public_subnet_cidrs" {
  description = "CIDR blocks of the public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "private_app_subnet_ids" {
  description = "IDs of the private application subnets"
  value       = aws_subnet.private_app[*].id
}

output "private_app_subnet_cidrs" {
  description = "CIDR blocks of the private application subnets"
  value       = aws_subnet.private_app[*].cidr_block
}

output "private_db_subnet_ids" {
  description = "IDs of the private database subnets"
  value       = aws_subnet.private_db[*].id
}

output "private_db_subnet_cidrs" {
  description = "CIDR blocks of the private database subnets"
  value       = aws_subnet.private_db[*].cidr_block
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "availability_zones" {
  description = "List of availability zones used"
  value       = var.availability_zones
}

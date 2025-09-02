# VPC Endpoints Module - Outputs

# S3 Endpoint Outputs
output "s3_vpc_endpoint_id" {
  description = "ID of the S3 VPC endpoint"
  value       = var.enable_s3_endpoint ? aws_vpc_endpoint.s3[0].id : null
}

output "s3_vpc_endpoint_arn" {
  description = "ARN of the S3 VPC endpoint"
  value       = var.enable_s3_endpoint ? aws_vpc_endpoint.s3[0].arn : null
}

# DynamoDB Endpoint Outputs
output "dynamodb_vpc_endpoint_id" {
  description = "ID of the DynamoDB VPC endpoint"
  value       = var.enable_dynamodb_endpoint ? aws_vpc_endpoint.dynamodb[0].id : null
}

output "dynamodb_vpc_endpoint_arn" {
  description = "ARN of the DynamoDB VPC endpoint"
  value       = var.enable_dynamodb_endpoint ? aws_vpc_endpoint.dynamodb[0].arn : null
}

# EC2 Endpoint Outputs
output "ec2_vpc_endpoint_id" {
  description = "ID of the EC2 VPC endpoint"
  value       = var.enable_ec2_endpoint ? aws_vpc_endpoint.ec2[0].id : null
}

output "ec2_vpc_endpoint_arn" {
  description = "ARN of the EC2 VPC endpoint"
  value       = var.enable_ec2_endpoint ? aws_vpc_endpoint.ec2[0].arn : null
}

# SSM Endpoints Outputs
output "ssm_vpc_endpoint_id" {
  description = "ID of the SSM VPC endpoint"
  value       = var.enable_ssm_endpoints ? aws_vpc_endpoint.ssm[0].id : null
}

output "ssm_messages_vpc_endpoint_id" {
  description = "ID of the SSM Messages VPC endpoint"
  value       = var.enable_ssm_endpoints ? aws_vpc_endpoint.ssm_messages[0].id : null
}

output "ec2_messages_vpc_endpoint_id" {
  description = "ID of the EC2 Messages VPC endpoint"
  value       = var.enable_ssm_endpoints ? aws_vpc_endpoint.ec2_messages[0].id : null
}

# Custom Endpoints Outputs
output "custom_vpc_endpoint_ids" {
  description = "Map of custom VPC endpoint IDs"
  value       = { for k, v in aws_vpc_endpoint.custom : k => v.id }
}

output "custom_vpc_endpoint_arns" {
  description = "Map of custom VPC endpoint ARNs"
  value       = { for k, v in aws_vpc_endpoint.custom : k => v.arn }
}

# All Endpoint IDs for reference
output "all_vpc_endpoint_ids" {
  description = "List of all VPC endpoint IDs"
  value = compact([
    var.enable_s3_endpoint ? aws_vpc_endpoint.s3[0].id : null,
    var.enable_dynamodb_endpoint ? aws_vpc_endpoint.dynamodb[0].id : null,
    var.enable_ec2_endpoint ? aws_vpc_endpoint.ec2[0].id : null,
    var.enable_ssm_endpoints ? aws_vpc_endpoint.ssm[0].id : null,
    var.enable_ssm_endpoints ? aws_vpc_endpoint.ssm_messages[0].id : null,
    var.enable_ssm_endpoints ? aws_vpc_endpoint.ec2_messages[0].id : null
  ])
}

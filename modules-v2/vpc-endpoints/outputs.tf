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

# All Endpoint IDs for reference
output "all_vpc_endpoint_ids" {
  description = "List of all VPC endpoint IDs"
  value = compact([
    var.enable_s3_endpoint ? aws_vpc_endpoint.s3[0].id : null,
  ])
}

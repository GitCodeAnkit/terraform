# VPC Endpoints Module - Outputs

output "s3_vpc_endpoint_id" {
  description = "ID of the S3 VPC endpoint"
  value       = aws_vpc_endpoint.s3.id
}

output "s3_vpc_endpoint_arn" {
  description = "ARN of the S3 VPC endpoint"
  value       = aws_vpc_endpoint.s3.arn
}

output "dynamodb_vpc_endpoint_id" {
  description = "ID of the DynamoDB VPC endpoint"
  value       = var.enable_dynamodb_endpoint ? aws_vpc_endpoint.dynamodb[0].id : null
}

output "dynamodb_vpc_endpoint_arn" {
  description = "ARN of the DynamoDB VPC endpoint"
  value       = var.enable_dynamodb_endpoint ? aws_vpc_endpoint.dynamodb[0].arn : null
}

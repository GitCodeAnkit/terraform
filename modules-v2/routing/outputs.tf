# Routing Module - Outputs

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "public_route_table_arn" {
  description = "ARN of the public route table"
  value       = aws_route_table.public.arn
}

output "private_route_table_ids" {
  description = "List of IDs of the private route tables"
  value       = aws_route_table.private[*].id
}

output "private_route_table_arns" {
  description = "List of ARNs of the private route tables"
  value       = aws_route_table.private[*].arn
}

output "private_2_route_table_id" {
  description = "ID of the private_2 route table (if created)"
  value       = var.create_private_2_route_table ? aws_route_table.private_2[0].id : null
}

output "private_2_route_table_arn" {
  description = "ARN of the private_2 route table (if created)"
  value       = var.create_private_2_route_table ? aws_route_table.private_2[0].arn : null
}

output "all_route_table_ids" {
  description = "List of all route table IDs for VPC endpoint associations"
  value = concat(
    [aws_route_table.public.id],
    aws_route_table.private[*].id,
    var.create_private_2_route_table ? [aws_route_table.private_2[0].id] : []
  )
}

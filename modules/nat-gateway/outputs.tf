# NAT Gateway Module - Outputs

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = var.nat_gateway_count > 1 ? [aws_nat_gateway.nat_1.id, aws_nat_gateway.nat_2[0].id] : [aws_nat_gateway.nat_1.id]
}

output "nat_gateway_public_ips" {
  description = "Public IPs of the NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

output "private_route_table_ids" {
  description = "IDs of the private route tables"
  value       = [aws_route_table.private_1.id, aws_route_table.private_2.id]
}

output "elastic_ip_ids" {
  description = "IDs of the Elastic IPs"
  value       = aws_eip.nat[*].id
}

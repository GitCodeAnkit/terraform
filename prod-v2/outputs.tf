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

# ==============================================================================
# ECS Cluster Outputs
# ==============================================================================

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.ecs.cluster_arn
}

output "ecs_capacity_providers" {
  description = "ECS capacity provider information"
  value = {
    ec2_capacity_provider  = module.ecs.ec2_capacity_provider_name
    spot_capacity_provider = module.ecs.spot_capacity_provider_name
  }
}

output "ecs_security_groups" {
  description = "ECS security group IDs"
  value = {
    cluster_security_group = module.ecs.cluster_security_group_id
    alb_security_group     = module.ecs.alb_security_group_id
  }
}

output "ecs_key_pair" {
  description = "ECS key pair information"
  value = {
    key_pair_name = module.ecs.key_pair_name
    private_key_ssm_parameter = module.ecs.private_key_ssm_parameter
  }
  sensitive = true
}

output "ecs_service_deployment_config" {
  description = "Configuration for deploying ECS services"
  value       = module.ecs.service_deployment_configuration
}

# ==============================================================================
# Application Load Balancer Outputs
# ==============================================================================

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = module.alb.alb_zone_id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.alb.alb_arn
}

output "alb_target_group_arn" {
  description = "ARN of the primary target group"
  value       = module.alb.primary_target_group_arn
}

output "alb_security_group_id" {
  description = "Security group ID for the ALB"
  value       = module.alb.security_group_id
}

# ==============================================================================
# ECS Service Outputs
# ==============================================================================

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.ecs_service.service_name
}

output "ecs_service_arn" {
  description = "ARN of the ECS service"
  value       = module.ecs_service.service_arn
}

output "ecs_task_definition_arn" {
  description = "ARN of the task definition"
  value       = module.ecs_service.task_definition_arn
}

output "ecs_service_log_group" {
  description = "CloudWatch log group for the ECS service"
  value       = module.ecs_service.log_group_name
}

# ==============================================================================
# Application URL
# ==============================================================================

output "application_url" {
  description = "URL to access the application"
  value       = "https://${module.alb.alb_dns_name}"
}

output "application_url_http" {
  description = "HTTP URL (redirects to HTTPS)"
  value       = "http://${module.alb.alb_dns_name}"
}

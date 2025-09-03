# ECS Module Outputs

# ==============================================================================
# ECS Cluster Outputs
# ==============================================================================

output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.main.id
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

# ==============================================================================
# Capacity Provider Outputs
# ==============================================================================

output "ec2_capacity_provider_name" {
  description = "Name of the EC2 capacity provider"
  value       = aws_ecs_capacity_provider.ec2.name
}

output "ec2_capacity_provider_arn" {
  description = "ARN of the EC2 capacity provider"
  value       = aws_ecs_capacity_provider.ec2.arn
}

output "spot_capacity_provider_name" {
  description = "Name of the Spot capacity provider"
  value       = aws_ecs_capacity_provider.spot.name
}

output "spot_capacity_provider_arn" {
  description = "ARN of the Spot capacity provider"
  value       = aws_ecs_capacity_provider.spot.arn
}

# ==============================================================================
# Auto Scaling Group Outputs
# ==============================================================================

output "ec2_autoscaling_group_name" {
  description = "Name of the EC2 Auto Scaling Group"
  value       = aws_autoscaling_group.ecs_ec2.name
}

output "ec2_autoscaling_group_arn" {
  description = "ARN of the EC2 Auto Scaling Group"
  value       = aws_autoscaling_group.ecs_ec2.arn
}

output "spot_autoscaling_group_name" {
  description = "Name of the Spot Auto Scaling Group"
  value       = aws_autoscaling_group.ecs_spot.name
}

output "spot_autoscaling_group_arn" {
  description = "ARN of the Spot Auto Scaling Group"
  value       = aws_autoscaling_group.ecs_spot.arn
}

# ==============================================================================
# Launch Template Outputs
# ==============================================================================

output "ec2_launch_template_id" {
  description = "ID of the EC2 launch template"
  value       = aws_launch_template.ecs_ec2.id
}

output "ec2_launch_template_arn" {
  description = "ARN of the EC2 launch template"
  value       = aws_launch_template.ecs_ec2.arn
}

output "spot_launch_template_id" {
  description = "ID of the Spot launch template"
  value       = aws_launch_template.ecs_spot.id
}

output "spot_launch_template_arn" {
  description = "ARN of the Spot launch template"
  value       = aws_launch_template.ecs_spot.arn
}

# ==============================================================================
# Security Group Outputs
# ==============================================================================

output "cluster_security_group_id" {
  description = "ID of the ECS cluster security group"
  value       = aws_security_group.ecs_cluster.id
}

output "cluster_security_group_arn" {
  description = "ARN of the ECS cluster security group"
  value       = aws_security_group.ecs_cluster.arn
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.ecs_alb.id
}

output "alb_security_group_arn" {
  description = "ARN of the ALB security group"
  value       = aws_security_group.ecs_alb.arn
}

# ==============================================================================
# IAM Role Outputs
# ==============================================================================

output "ecs_instance_role_name" {
  description = "Name of the ECS instance IAM role"
  value       = aws_iam_role.ecs_instance_role.name
}

output "ecs_instance_role_arn" {
  description = "ARN of the ECS instance IAM role"
  value       = aws_iam_role.ecs_instance_role.arn
}

output "ecs_service_role_name" {
  description = "Name of the ECS service IAM role"
  value       = aws_iam_role.ecs_service_role.name
}

output "ecs_service_role_arn" {
  description = "ARN of the ECS service IAM role"
  value       = aws_iam_role.ecs_service_role.arn
}

output "ecs_task_execution_role_name" {
  description = "Name of the ECS task execution IAM role"
  value       = aws_iam_role.ecs_task_execution_role.name
}

output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution IAM role"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_instance_profile_name" {
  description = "Name of the ECS instance profile"
  value       = aws_iam_instance_profile.ecs_instance_profile.name
}

output "ecs_instance_profile_arn" {
  description = "ARN of the ECS instance profile"
  value       = aws_iam_instance_profile.ecs_instance_profile.arn
}

# ==============================================================================
# Key Pair Outputs
# ==============================================================================

output "key_pair_name" {
  description = "Name of the key pair (if created)"
  value       = var.create_key_pair ? aws_key_pair.ecs_key_pair[0].key_name : null
}

output "key_pair_id" {
  description = "ID of the key pair (if created)"
  value       = var.create_key_pair ? aws_key_pair.ecs_key_pair[0].id : null
}

output "private_key_ssm_parameter" {
  description = "SSM parameter name containing the private key (if created)"
  value       = var.create_key_pair ? aws_ssm_parameter.ecs_private_key[0].name : null
  sensitive   = true
}

# ==============================================================================
# CloudWatch Outputs
# ==============================================================================

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.ecs_cluster.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.ecs_cluster.arn
}

# ==============================================================================
# Useful Information for Service Deployment
# ==============================================================================

output "service_deployment_configuration" {
  description = "Configuration for deploying ECS services"
  value = {
    cluster_name                    = aws_ecs_cluster.main.name
    cluster_arn                     = aws_ecs_cluster.main.arn
    ec2_capacity_provider          = aws_ecs_capacity_provider.ec2.name
    spot_capacity_provider         = aws_ecs_capacity_provider.spot.name
    task_execution_role_arn        = aws_iam_role.ecs_task_execution_role.arn
    service_role_arn               = aws_iam_role.ecs_service_role.arn
    cluster_security_group_id      = aws_security_group.ecs_cluster.id
    alb_security_group_id          = aws_security_group.ecs_alb.id
    cloudwatch_log_group           = aws_cloudwatch_log_group.ecs_cluster.name
  }
}

# ECS Service Module Outputs

# ==============================================================================
# Task Definition Outputs
# ==============================================================================

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = aws_ecs_task_definition.app.arn
}

output "task_definition_family" {
  description = "Family of the task definition"
  value       = aws_ecs_task_definition.app.family
}

output "task_definition_revision" {
  description = "Revision of the task definition"
  value       = aws_ecs_task_definition.app.revision
}

# ==============================================================================
# ECS Service Outputs
# ==============================================================================

output "service_id" {
  description = "ID of the ECS service"
  value       = aws_ecs_service.app.id
}

output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.app.name
}

output "service_arn" {
  description = "ARN of the ECS service"
  value       = aws_ecs_service.app.id
}

output "service_desired_count" {
  description = "Desired count of the ECS service"
  value       = aws_ecs_service.app.desired_count
}

output "service_running_count" {
  description = "Running count of the ECS service"
  value       = aws_ecs_service.app.running_count
}

output "service_pending_count" {
  description = "Pending count of the ECS service"
  value       = aws_ecs_service.app.pending_count
}

# ==============================================================================
# CloudWatch Log Group Outputs
# ==============================================================================

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.app.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.app.arn
}

# ==============================================================================
# Auto Scaling Outputs
# ==============================================================================

output "autoscaling_target_resource_id" {
  description = "Resource ID of the auto scaling target"
  value       = var.enable_autoscaling ? aws_appautoscaling_target.ecs_target[0].resource_id : null
}

output "autoscaling_cpu_policy_arn" {
  description = "ARN of the CPU auto scaling policy"
  value       = var.enable_autoscaling && var.autoscaling_cpu_policy_enabled ? aws_appautoscaling_policy.ecs_policy_cpu[0].arn : null
}

output "autoscaling_memory_policy_arn" {
  description = "ARN of the memory auto scaling policy"
  value       = var.enable_autoscaling && var.autoscaling_memory_policy_enabled ? aws_appautoscaling_policy.ecs_policy_memory[0].arn : null
}

# ==============================================================================
# Container Configuration Outputs
# ==============================================================================

output "container_definitions" {
  description = "Container definitions (sensitive)"
  value       = aws_ecs_task_definition.app.container_definitions
  sensitive   = true
}

output "container_name" {
  description = "Name of the primary container"
  value       = var.container_name
}

output "container_port" {
  description = "Port of the primary container"
  value       = var.container_port
}

# ==============================================================================
# Service Configuration Summary
# ==============================================================================

output "service_configuration" {
  description = "Summary of service configuration"
  value = {
    service_name     = aws_ecs_service.app.name
    service_arn      = aws_ecs_service.app.id
    cluster_name     = var.cluster_name
    task_definition  = aws_ecs_task_definition.app.arn
    desired_count    = aws_ecs_service.app.desired_count
    network_mode     = var.network_mode
    container_name   = var.container_name
    container_port   = var.container_port
    log_group_name   = aws_cloudwatch_log_group.app.name
  }
}

# ==============================================================================
# Load Balancer Integration
# ==============================================================================

output "load_balancer_target_group_arn" {
  description = "Target group ARN for load balancer (if enabled)"
  value       = var.load_balancer_enabled ? var.load_balancer_config.target_group_arn : null
}

output "load_balancer_container_name" {
  description = "Container name for load balancer (if enabled)"
  value       = var.load_balancer_enabled ? var.load_balancer_config.container_name : null
}

output "load_balancer_container_port" {
  description = "Container port for load balancer (if enabled)"
  value       = var.load_balancer_enabled ? var.load_balancer_config.container_port : null
}

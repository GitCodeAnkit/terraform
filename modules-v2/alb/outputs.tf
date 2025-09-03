# ALB Module Outputs

# ==============================================================================
# Load Balancer Outputs
# ==============================================================================

output "alb_id" {
  description = "ID of the Application Load Balancer"
  value       = aws_lb.main.id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

output "alb_hosted_zone_id" {
  description = "Hosted zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

# ==============================================================================
# Security Group Outputs
# ==============================================================================

output "security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "security_group_arn" {
  description = "ARN of the ALB security group"
  value       = aws_security_group.alb.arn
}

# ==============================================================================
# Target Group Outputs
# ==============================================================================

output "primary_target_group_id" {
  description = "ID of the primary target group"
  value       = aws_lb_target_group.primary.id
}

output "primary_target_group_arn" {
  description = "ARN of the primary target group"
  value       = aws_lb_target_group.primary.arn
}

output "primary_target_group_name" {
  description = "Name of the primary target group"
  value       = aws_lb_target_group.primary.name
}

output "secondary_target_group_id" {
  description = "ID of the secondary target group (if created)"
  value       = var.create_secondary_target_group ? aws_lb_target_group.secondary[0].id : null
}

output "secondary_target_group_arn" {
  description = "ARN of the secondary target group (if created)"
  value       = var.create_secondary_target_group ? aws_lb_target_group.secondary[0].arn : null
}

output "secondary_target_group_name" {
  description = "Name of the secondary target group (if created)"
  value       = var.create_secondary_target_group ? aws_lb_target_group.secondary[0].name : null
}

# ==============================================================================
# Listener Outputs
# ==============================================================================

output "http_listener_id" {
  description = "ID of the HTTP listener"
  value       = aws_lb_listener.http.id
}

output "http_listener_arn" {
  description = "ARN of the HTTP listener"
  value       = aws_lb_listener.http.arn
}

output "https_listener_id" {
  description = "ID of the HTTPS listener (if created)"
  value       = var.domain_name != null ? aws_lb_listener.https[0].id : null
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener (if created)"
  value       = var.domain_name != null ? aws_lb_listener.https[0].arn : null
}

# ==============================================================================
# SSL Certificate Outputs
# ==============================================================================

output "ssl_certificate_arn" {
  description = "ARN of the SSL certificate (if created)"
  value       = var.domain_name != null ? aws_acm_certificate.main[0].arn : null
}

output "ssl_certificate_domain_validation_options" {
  description = "Domain validation options for the SSL certificate"
  value       = var.domain_name != null ? aws_acm_certificate.main[0].domain_validation_options : null
}

# ==============================================================================
# Route53 Outputs
# ==============================================================================

output "route53_record_name" {
  description = "Name of the Route53 record (if created)"
  value       = var.domain_name != null && var.route53_zone_id != null ? aws_route53_record.alb[0].name : null
}

output "route53_record_fqdn" {
  description = "FQDN of the Route53 record (if created)"
  value       = var.domain_name != null && var.route53_zone_id != null ? aws_route53_record.alb[0].fqdn : null
}

# ==============================================================================
# Useful Information for ECS Service
# ==============================================================================

output "ecs_service_configuration" {
  description = "Configuration for ECS service integration"
  value = {
    load_balancer = {
      target_group_arn = aws_lb_target_group.primary.arn
      container_name   = "app" # Default container name
      container_port   = var.target_group_port
    }
    security_group_id = aws_security_group.alb.id
    alb_dns_name     = aws_lb.main.dns_name
    alb_zone_id      = aws_lb.main.zone_id
  }
}

# ==============================================================================
# All Target Group ARNs
# ==============================================================================

output "all_target_group_arns" {
  description = "List of all target group ARNs"
  value = compact([
    aws_lb_target_group.primary.arn,
    var.create_secondary_target_group ? aws_lb_target_group.secondary[0].arn : ""
  ])
}

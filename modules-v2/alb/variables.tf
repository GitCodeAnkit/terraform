# ALB Module Variables

# ==============================================================================
# Required Variables
# ==============================================================================

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where ALB will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ALB (should be public for internet-facing ALB)"
  type        = list(string)
}

# ==============================================================================
# ALB Configuration
# ==============================================================================

variable "internal" {
  description = "Whether the ALB is internal or internet-facing"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the ALB"
  type        = bool
  default     = false
}

variable "enable_http2" {
  description = "Enable HTTP/2 for the ALB"
  type        = bool
  default     = true
}

variable "enable_cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing"
  type        = bool
  default     = true
}

# ==============================================================================
# Security Configuration
# ==============================================================================

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "custom_ingress_rules" {
  description = "Custom ingress rules for the ALB security group"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

# ==============================================================================
# Target Group Configuration
# ==============================================================================

variable "target_group_port" {
  description = "Port for the target group"
  type        = number
  default     = 80
}

variable "target_group_protocol" {
  description = "Protocol for the target group"
  type        = string
  default     = "HTTP"
}

variable "target_type" {
  description = "Type of target (instance, ip, lambda)"
  type        = string
  default     = "instance"
}

variable "create_secondary_target_group" {
  description = "Create a secondary target group for blue/green deployments"
  type        = bool
  default     = false
}

variable "deregistration_delay" {
  description = "Time in seconds for deregistration delay"
  type        = number
  default     = 300
}

variable "slow_start" {
  description = "Slow start duration in seconds"
  type        = number
  default     = 0
}

variable "load_balancing_algorithm_type" {
  description = "Load balancing algorithm type (round_robin, least_outstanding_requests)"
  type        = string
  default     = "round_robin"
}

variable "preserve_client_ip" {
  description = "Preserve client IP address"
  type        = bool
  default     = false
}

# ==============================================================================
# Health Check Configuration
# ==============================================================================

variable "health_check_enabled" {
  description = "Enable health checks"
  type        = bool
  default     = true
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive health checks successes required"
  type        = number
  default     = 2
}

variable "health_check_interval" {
  description = "Interval between health checks in seconds"
  type        = number
  default     = 30
}

variable "health_check_matcher" {
  description = "HTTP response codes to use when checking for healthy responses"
  type        = string
  default     = "200"
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}

variable "health_check_port" {
  description = "Port for health checks (traffic-port or specific port)"
  type        = string
  default     = "traffic-port"
}

variable "health_check_protocol" {
  description = "Protocol for health checks"
  type        = string
  default     = "HTTP"
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive health check failures required"
  type        = number
  default     = 2
}

# ==============================================================================
# Stickiness Configuration
# ==============================================================================

variable "stickiness_enabled" {
  description = "Enable session stickiness"
  type        = bool
  default     = false
}

variable "stickiness_type" {
  description = "Type of stickiness (lb_cookie, app_cookie)"
  type        = string
  default     = "lb_cookie"
}

variable "stickiness_cookie_duration" {
  description = "Cookie duration in seconds (1-604800)"
  type        = number
  default     = 86400
}

# ==============================================================================
# SSL/TLS Configuration
# ==============================================================================

variable "domain_name" {
  description = "Domain name for SSL certificate (leave null to disable HTTPS)"
  type        = string
  default     = null
}

variable "subject_alternative_names" {
  description = "Subject alternative names for SSL certificate"
  type        = list(string)
  default     = []
}

variable "ssl_policy" {
  description = "SSL policy for HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "route53_zone_id" {
  description = "Route53 zone ID for DNS validation and A record"
  type        = string
  default     = null
}

# ==============================================================================
# Access Logs Configuration
# ==============================================================================

variable "access_logs_enabled" {
  description = "Enable ALB access logs"
  type        = bool
  default     = false
}

variable "access_logs_bucket" {
  description = "S3 bucket for ALB access logs"
  type        = string
  default     = null
}

variable "access_logs_prefix" {
  description = "S3 prefix for ALB access logs"
  type        = string
  default     = "alb-logs"
}

# ==============================================================================
# Listener Rules Configuration
# ==============================================================================

variable "listener_rules" {
  description = "Custom listener rules"
  type = list(object({
    priority    = number
    action_type = string # forward, fixed-response, redirect
    target_group_arn = optional(string)
    
    # Fixed response action
    fixed_response = optional(object({
      content_type = string
      message_body = string
      status_code  = string
    }))
    
    # Redirect action
    redirect = optional(object({
      port        = string
      protocol    = string
      status_code = string
      host        = optional(string)
      path        = optional(string)
      query       = optional(string)
    }))
    
    # Conditions
    conditions = list(object({
      field = string # path-pattern, host-header, http-header, http-request-method, query-string, source-ip
      values = optional(list(string))
      http_header_name = optional(string)
      key = optional(string)
      value = optional(string)
    }))
  }))
  default = []
}

# ==============================================================================
# Tags
# ==============================================================================

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

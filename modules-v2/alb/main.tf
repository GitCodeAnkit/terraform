# Application Load Balancer Module
# This module creates an ALB with security groups, target groups, and listeners

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

# ==============================================================================
# Security Groups
# ==============================================================================

# ALB Security Group
resource "aws_security_group" "alb" {
  name_prefix = "${var.name_prefix}-alb-"
  vpc_id      = var.vpc_id
  description = "Security group for Application Load Balancer"

  # HTTP access
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # HTTPS access
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # Custom ports (optional)
  dynamic "ingress" {
    for_each = var.custom_ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  # Allow all outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-alb-sg"
    Type = "alb"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ==============================================================================
# Application Load Balancer
# ==============================================================================

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.name_prefix}-alb"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection
  enable_http2              = var.enable_http2
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing

  # Access logs (optional)
  dynamic "access_logs" {
    for_each = var.access_logs_enabled ? [1] : []
    content {
      bucket  = var.access_logs_bucket
      prefix  = var.access_logs_prefix
      enabled = true
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-alb"
    Type = "application-load-balancer"
  })
}

# ==============================================================================
# Target Groups
# ==============================================================================

# Primary Target Group (HTTP)
resource "aws_lb_target_group" "primary" {
  name     = "${var.name_prefix}-primary-tg"
  port     = var.target_group_port
  protocol = var.target_group_protocol
  vpc_id   = var.vpc_id

  # Health check configuration
  health_check {
    enabled             = true
    healthy_threshold   = var.health_check_healthy_threshold
    interval            = var.health_check_interval
    matcher             = var.health_check_matcher
    path                = var.health_check_path
    port                = var.health_check_port
    protocol            = var.health_check_protocol
    timeout             = var.health_check_timeout
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  # Target group attributes
  target_type                       = var.target_type
  deregistration_delay              = var.deregistration_delay
  slow_start                        = var.slow_start
  load_balancing_algorithm_type     = var.load_balancing_algorithm_type
  preserve_client_ip                = var.preserve_client_ip

  # Stickiness (optional)
  dynamic "stickiness" {
    for_each = var.stickiness_enabled ? [1] : []
    content {
      type            = var.stickiness_type
      cookie_duration = var.stickiness_cookie_duration
      enabled         = true
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-primary-tg"
    Type = "target-group"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Secondary Target Group (for Blue/Green deployments)
resource "aws_lb_target_group" "secondary" {
  count = var.create_secondary_target_group ? 1 : 0

  name     = "${var.name_prefix}-secondary-tg"
  port     = var.target_group_port
  protocol = var.target_group_protocol
  vpc_id   = var.vpc_id

  # Health check configuration
  health_check {
    enabled             = true
    healthy_threshold   = var.health_check_healthy_threshold
    interval            = var.health_check_interval
    matcher             = var.health_check_matcher
    path                = var.health_check_path
    port                = var.health_check_port
    protocol            = var.health_check_protocol
    timeout             = var.health_check_timeout
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  # Target group attributes
  target_type                       = var.target_type
  deregistration_delay              = var.deregistration_delay
  slow_start                        = var.slow_start
  load_balancing_algorithm_type     = var.load_balancing_algorithm_type
  preserve_client_ip                = var.preserve_client_ip

  # Stickiness (optional)
  dynamic "stickiness" {
    for_each = var.stickiness_enabled ? [1] : []
    content {
      type            = var.stickiness_type
      cookie_duration = var.stickiness_cookie_duration
      enabled         = true
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-secondary-tg"
    Type = "target-group"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ==============================================================================
# SSL Certificate (optional)
# ==============================================================================

# SSL Certificate (if domain is provided)
resource "aws_acm_certificate" "main" {
  count = var.domain_name != null ? 1 : 0

  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-ssl-cert"
  })
}

# Certificate validation (if Route53 zone is provided)
resource "aws_acm_certificate_validation" "main" {
  count = var.domain_name != null && var.route53_zone_id != null ? 1 : 0

  certificate_arn         = aws_acm_certificate.main[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

  timeouts {
    create = "5m"
  }
}

# Route53 records for certificate validation
resource "aws_route53_record" "cert_validation" {
  for_each = var.domain_name != null && var.route53_zone_id != null ? {
    for dvo in aws_acm_certificate.main[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.route53_zone_id
}

# ==============================================================================
# Listeners
# ==============================================================================

# HTTP Listener (redirect to HTTPS if SSL is enabled, otherwise forward to target group)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  # Redirect to HTTPS if SSL is enabled
  dynamic "default_action" {
    for_each = var.domain_name != null ? [1] : []
    content {
      type = "redirect"

      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  # Forward to target group if no SSL
  dynamic "default_action" {
    for_each = var.domain_name == null ? [1] : []
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.primary.arn
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-http-listener"
  })
}

# HTTPS Listener (only if SSL certificate is available)
resource "aws_lb_listener" "https" {
  count = var.domain_name != null ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.route53_zone_id != null ? aws_acm_certificate_validation.main[0].certificate_arn : aws_acm_certificate.main[0].arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.primary.arn
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-https-listener"
  })
}

# ==============================================================================
# Listener Rules (optional)
# ==============================================================================

# Custom listener rules
resource "aws_lb_listener_rule" "custom" {
  count = length(var.listener_rules)

  listener_arn = var.domain_name != null ? aws_lb_listener.https[0].arn : aws_lb_listener.http.arn
  priority     = var.listener_rules[count.index].priority

  # Action
  action {
    type             = var.listener_rules[count.index].action_type
    target_group_arn = var.listener_rules[count.index].action_type == "forward" ? var.listener_rules[count.index].target_group_arn : null

    # Fixed response (if action type is fixed-response)
    dynamic "fixed_response" {
      for_each = var.listener_rules[count.index].action_type == "fixed-response" ? [1] : []
      content {
        content_type = var.listener_rules[count.index].fixed_response.content_type
        message_body = var.listener_rules[count.index].fixed_response.message_body
        status_code  = var.listener_rules[count.index].fixed_response.status_code
      }
    }

    # Redirect (if action type is redirect)
    dynamic "redirect" {
      for_each = var.listener_rules[count.index].action_type == "redirect" ? [1] : []
      content {
        port        = var.listener_rules[count.index].redirect.port
        protocol    = var.listener_rules[count.index].redirect.protocol
        status_code = var.listener_rules[count.index].redirect.status_code
        host        = var.listener_rules[count.index].redirect.host
        path        = var.listener_rules[count.index].redirect.path
        query       = var.listener_rules[count.index].redirect.query
      }
    }
  }

  # Conditions
  dynamic "condition" {
    for_each = var.listener_rules[count.index].conditions
    content {
      # Path pattern
      dynamic "path_pattern" {
        for_each = condition.value.field == "path-pattern" ? [1] : []
        content {
          values = condition.value.values
        }
      }

      # Host header
      dynamic "host_header" {
        for_each = condition.value.field == "host-header" ? [1] : []
        content {
          values = condition.value.values
        }
      }

      # HTTP header
      dynamic "http_header" {
        for_each = condition.value.field == "http-header" ? [1] : []
        content {
          http_header_name = condition.value.http_header_name
          values          = condition.value.values
        }
      }

      # HTTP request method
      dynamic "http_request_method" {
        for_each = condition.value.field == "http-request-method" ? [1] : []
        content {
          values = condition.value.values
        }
      }

      # Query string
      dynamic "query_string" {
        for_each = condition.value.field == "query-string" ? [1] : []
        content {
          key   = condition.value.key
          value = condition.value.value
        }
      }

      # Source IP
      dynamic "source_ip" {
        for_each = condition.value.field == "source-ip" ? [1] : []
        content {
          values = condition.value.values
        }
      }
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-listener-rule-${count.index + 1}"
  })
}

# ==============================================================================
# Route53 Records (optional)
# ==============================================================================

# A record for the ALB (if Route53 zone is provided)
resource "aws_route53_record" "alb" {
  count = var.domain_name != null && var.route53_zone_id != null ? 1 : 0

  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

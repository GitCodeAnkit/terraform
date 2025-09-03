# ==============================================================================
# Auto Scaling Groups
# ==============================================================================

# Auto Scaling Group for On-Demand EC2 instances
resource "aws_autoscaling_group" "ecs_ec2" {
  name                = "${var.name_prefix}-ecs-ec2-asg"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = []
  health_check_type   = "EC2"
  health_check_grace_period = 300

  min_size         = var.ec2_min_capacity
  max_size         = var.ec2_max_capacity
  desired_capacity = var.ec2_desired_capacity

  launch_template {
    id      = aws_launch_template.ecs_ec2.id
    version = "$Latest"
  }

  # Enable instance scale-in protection
  protect_from_scale_in = true

  # Instance refresh configuration
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-ecs-ec2-asg"
    propagate_at_launch = false
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = false
  }

  dynamic "tag" {
    for_each = var.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = false
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes       = [desired_capacity]
  }
}

# Auto Scaling Group for Spot instances
resource "aws_autoscaling_group" "ecs_spot" {
  name                = "${var.name_prefix}-ecs-spot-asg"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = []
  health_check_type   = "EC2"
  health_check_grace_period = 300

  min_size         = var.spot_min_capacity
  max_size         = var.spot_max_capacity
  desired_capacity = var.spot_desired_capacity

  launch_template {
    id      = aws_launch_template.ecs_spot.id
    version = "$Latest"
  }

  # Enable instance scale-in protection
  protect_from_scale_in = true

  # Instance refresh configuration
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-ecs-spot-asg"
    propagate_at_launch = false
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = false
  }

  dynamic "tag" {
    for_each = var.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = false
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes       = [desired_capacity]
  }
}

# ==============================================================================
# ECS Cluster
# ==============================================================================

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.name_prefix}-ecs-cluster"

  configuration {
    execute_command_configuration {
      kms_key_id = var.kms_key_id
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecs_cluster.name
      }
    }
  }

  service_connect_defaults {
    namespace = var.service_connect_namespace
  }

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-ecs-cluster"
  })
}

# CloudWatch Log Group for ECS Cluster
resource "aws_cloudwatch_log_group" "ecs_cluster" {
  name              = "/aws/ecs/cluster/${var.name_prefix}"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-ecs-cluster-logs"
  })
}

# ==============================================================================
# ECS Capacity Providers
# ==============================================================================

# EC2 Capacity Provider (On-Demand)
resource "aws_ecs_capacity_provider" "ec2" {
  name = "${var.name_prefix}-ec2-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_ec2.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = var.ec2_maximum_scaling_step_size
      minimum_scaling_step_size = var.ec2_minimum_scaling_step_size
      status                    = "ENABLED"
      target_capacity           = var.ec2_target_capacity
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-ec2-capacity-provider"
    Type = "ec2-ondemand"
  })
}

# Spot Capacity Provider
resource "aws_ecs_capacity_provider" "spot" {
  name = "${var.name_prefix}-spot-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_spot.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = var.spot_maximum_scaling_step_size
      minimum_scaling_step_size = var.spot_minimum_scaling_step_size
      status                    = "ENABLED"
      target_capacity           = var.spot_target_capacity
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-spot-capacity-provider"
    Type = "ec2-spot"
  })
}

# ==============================================================================
# ECS Cluster Capacity Providers
# ==============================================================================

# Associate Capacity Providers with ECS Cluster
resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = [
    aws_ecs_capacity_provider.ec2.name,
    aws_ecs_capacity_provider.spot.name
  ]

  default_capacity_provider_strategy {
    base              = var.default_capacity_provider_base
    weight            = var.default_capacity_provider_weight_ec2
    capacity_provider = aws_ecs_capacity_provider.ec2.name
  }

  default_capacity_provider_strategy {
    base              = 0
    weight            = var.default_capacity_provider_weight_spot
    capacity_provider = aws_ecs_capacity_provider.spot.name
  }

  depends_on = [
    aws_ecs_capacity_provider.ec2,
    aws_ecs_capacity_provider.spot
  ]
}

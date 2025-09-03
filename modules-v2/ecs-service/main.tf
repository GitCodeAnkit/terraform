# ECS Service and Task Definition Module
# This module creates ECS task definitions and services

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ==============================================================================
# CloudWatch Log Group
# ==============================================================================

resource "aws_cloudwatch_log_group" "app" {
  name              = "/aws/ecs/${var.service_name}"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.service_name}-logs"
  })
}

# ==============================================================================
# Task Definition
# ==============================================================================

# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = var.service_name
  network_mode             = var.network_mode
  requires_compatibilities = ["EC2"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn           = var.task_role_arn

  # Container definitions
  container_definitions = jsonencode([
    {
      name  = var.container_name
      image = var.container_image
      
      # Port mappings
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.host_port
          protocol      = "tcp"
        }
      ]
      
      # Essential container
      essential = true
      
      # Resource requirements
      cpu    = var.container_cpu
      memory = var.container_memory
      
      # Memory reservation (soft limit)
      memoryReservation = var.container_memory_reservation
      
      # Environment variables
      environment = [
        for key, value in var.environment_variables : {
          name  = key
          value = tostring(value)
        }
      ]
      
      # Secrets (from Parameter Store or Secrets Manager)
      secrets = [
        for secret in var.secrets : {
          name      = secret.name
          valueFrom = secret.valueFrom
        }
      ]
      
      # Logging configuration
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
      
      # Health check
      healthCheck = var.health_check_enabled ? {
        command     = var.health_check_command
        interval    = var.health_check_interval
        timeout     = var.health_check_timeout
        retries     = var.health_check_retries
        startPeriod = var.health_check_start_period
      } : null
      
      # Mount points (if volumes are specified)
      mountPoints = [
        for mount in var.mount_points : {
          sourceVolume  = mount.source_volume
          containerPath = mount.container_path
          readOnly      = mount.read_only
        }
      ]
      
      # Volume from (for data volumes)
      volumesFrom = []
      
      # Working directory
      workingDirectory = var.working_directory
      
      # User
      user = var.container_user
      
      # Entry point and command
      entryPoint = var.entry_point
      command    = var.command
      
      # Linux parameters
      linuxParameters = var.linux_parameters != null ? {
        capabilities = var.linux_parameters.capabilities
        devices      = var.linux_parameters.devices
        initProcessEnabled = var.linux_parameters.init_process_enabled
        maxSwap            = var.linux_parameters.max_swap
        sharedMemorySize   = var.linux_parameters.shared_memory_size
        swappiness         = var.linux_parameters.swappiness
        tmpfs              = var.linux_parameters.tmpfs
      } : null
      
      # Ulimits
      ulimits = [
        for ulimit in var.ulimits : {
          name      = ulimit.name
          hardLimit = ulimit.hard_limit
          softLimit = ulimit.soft_limit
        }
      ]
      
      # Docker labels
      dockerLabels = var.docker_labels
      
      # Start timeout
      startTimeout = var.start_timeout
      
      # Stop timeout
      stopTimeout = var.stop_timeout
      
      # System controls
      systemControls = [
        for control in var.system_controls : {
          namespace = control.namespace
          value     = control.value
        }
      ]
    }
  ])

  # Volumes
  dynamic "volume" {
    for_each = var.volumes
    content {
      name = volume.value.name
      
      # Host path
      dynamic "host_path" {
        for_each = volume.value.host_path != null ? [volume.value.host_path] : []
        content {
          source_path = host_path.value.source_path
        }
      }
      
      # Docker volume
      dynamic "docker_volume_configuration" {
        for_each = volume.value.docker_volume_configuration != null ? [volume.value.docker_volume_configuration] : []
        content {
          scope         = docker_volume_configuration.value.scope
          autoprovision = docker_volume_configuration.value.autoprovision
          driver        = docker_volume_configuration.value.driver
          driver_opts   = docker_volume_configuration.value.driver_opts
          labels        = docker_volume_configuration.value.labels
        }
      }
      
      # EFS volume
      dynamic "efs_volume_configuration" {
        for_each = volume.value.efs_volume_configuration != null ? [volume.value.efs_volume_configuration] : []
        content {
          file_system_id          = efs_volume_configuration.value.file_system_id
          root_directory          = efs_volume_configuration.value.root_directory
          transit_encryption      = efs_volume_configuration.value.transit_encryption
          transit_encryption_port = efs_volume_configuration.value.transit_encryption_port
          
          dynamic "authorization_config" {
            for_each = efs_volume_configuration.value.authorization_config != null ? [efs_volume_configuration.value.authorization_config] : []
            content {
              access_point_id = authorization_config.value.access_point_id
              iam             = authorization_config.value.iam
            }
          }
        }
      }
    }
  }

  # Placement constraints
  dynamic "placement_constraints" {
    for_each = var.placement_constraints
    content {
      type       = placement_constraints.value.type
      expression = placement_constraints.value.expression
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.service_name}-task-definition"
  })
}

# ==============================================================================
# ECS Service
# ==============================================================================

# ECS Service
resource "aws_ecs_service" "app" {
  name            = var.service_name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count
  
  # Launch type or capacity provider strategy
  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategy
    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
      base              = capacity_provider_strategy.value.base
    }
  }
  
  # Platform version (for Fargate)
  platform_version = var.platform_version
  
  # Scheduling strategy
  scheduling_strategy = var.scheduling_strategy
  
  # Health check grace period
  health_check_grace_period_seconds = var.load_balancer_enabled ? var.health_check_grace_period : null
  
  # Enable execute command
  enable_execute_command = var.enable_execute_command
  
  # Propagate tags
  propagate_tags = var.propagate_tags
  
  # Enable ECS managed tags
  enable_ecs_managed_tags = var.enable_ecs_managed_tags
  
  # Force new deployment
  force_new_deployment = var.force_new_deployment
  
  # Wait for steady state
  wait_for_steady_state = var.wait_for_steady_state

  # Network configuration (for awsvpc network mode)
  dynamic "network_configuration" {
    for_each = var.network_mode == "awsvpc" ? [1] : []
    content {
      subnets          = var.subnet_ids
      security_groups  = var.security_group_ids
      assign_public_ip = var.assign_public_ip
    }
  }

  # Load balancer configuration
  dynamic "load_balancer" {
    for_each = var.load_balancer_enabled ? [var.load_balancer_config] : []
    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  # Service registries (for service discovery)
  dynamic "service_registries" {
    for_each = var.service_registries
    content {
      registry_arn   = service_registries.value.registry_arn
      port           = service_registries.value.port
      container_name = service_registries.value.container_name
      container_port = service_registries.value.container_port
    }
  }

  # Deployment configuration
  deployment_configuration {
    maximum_percent         = var.deployment_maximum_percent
    minimum_healthy_percent = var.deployment_minimum_healthy_percent
    
    dynamic "deployment_circuit_breaker" {
      for_each = var.deployment_circuit_breaker_enabled ? [1] : []
      content {
        enable   = true
        rollback = var.deployment_circuit_breaker_rollback
      }
    }
  }

  # Deployment controller
  dynamic "deployment_controller" {
    for_each = var.deployment_controller_type != "ECS" ? [1] : []
    content {
      type = var.deployment_controller_type
    }
  }

  # Placement constraints
  dynamic "placement_constraints" {
    for_each = var.service_placement_constraints
    content {
      type       = placement_constraints.value.type
      expression = placement_constraints.value.expression
    }
  }

  # Placement strategy
  dynamic "placement_strategy" {
    for_each = var.placement_strategy
    content {
      type  = placement_strategy.value.type
      field = placement_strategy.value.field
    }
  }

  # Ordered placement strategy
  dynamic "ordered_placement_strategy" {
    for_each = var.ordered_placement_strategy
    content {
      type  = ordered_placement_strategy.value.type
      field = ordered_placement_strategy.value.field
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.service_name}-service"
  })

  # Lifecycle rules
  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count
    ]
  }

  # Depends on load balancer target group
  depends_on = [var.load_balancer_dependency]
}

# ==============================================================================
# Auto Scaling (optional)
# ==============================================================================

# Application Auto Scaling Target
resource "aws_appautoscaling_target" "ecs_target" {
  count = var.enable_autoscaling ? 1 : 0

  max_capacity       = var.autoscaling_max_capacity
  min_capacity       = var.autoscaling_min_capacity
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  tags = merge(var.common_tags, {
    Name = "${var.service_name}-autoscaling-target"
  })
}

# CPU-based Auto Scaling Policy
resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  count = var.enable_autoscaling && var.autoscaling_cpu_policy_enabled ? 1 : 0

  name               = "${var.service_name}-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.autoscaling_cpu_target_value
    scale_in_cooldown  = var.autoscaling_scale_in_cooldown
    scale_out_cooldown = var.autoscaling_scale_out_cooldown
  }
}

# Memory-based Auto Scaling Policy
resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  count = var.enable_autoscaling && var.autoscaling_memory_policy_enabled ? 1 : 0

  name               = "${var.service_name}-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = var.autoscaling_memory_target_value
    scale_in_cooldown  = var.autoscaling_scale_in_cooldown
    scale_out_cooldown = var.autoscaling_scale_out_cooldown
  }
}

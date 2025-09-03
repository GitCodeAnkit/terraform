# ECS Service Module Variables

# ==============================================================================
# Required Variables
# ==============================================================================

variable "service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "cluster_id" {
  description = "ID of the ECS cluster"
  type        = string
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "container_image" {
  description = "Docker image for the container"
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the task execution role"
  type        = string
}

# ==============================================================================
# Task Definition Configuration
# ==============================================================================

variable "task_cpu" {
  description = "CPU units for the task (1024 = 1 vCPU)"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Memory (MiB) for the task"
  type        = number
  default     = 512
}

variable "task_role_arn" {
  description = "ARN of the task role (optional)"
  type        = string
  default     = null
}

variable "network_mode" {
  description = "Network mode for the task (bridge, host, awsvpc, none)"
  type        = string
  default     = "bridge"
}

# ==============================================================================
# Container Configuration
# ==============================================================================

variable "container_name" {
  description = "Name of the container"
  type        = string
  default     = "app"
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 80
}

variable "host_port" {
  description = "Port on the host (0 for dynamic port mapping)"
  type        = number
  default     = 0
}

variable "container_cpu" {
  description = "CPU units for the container (leave null for unlimited)"
  type        = number
  default     = null
}

variable "container_memory" {
  description = "Hard memory limit for the container in MiB"
  type        = number
  default     = 512
}

variable "container_memory_reservation" {
  description = "Soft memory limit for the container in MiB"
  type        = number
  default     = 256
}

variable "container_user" {
  description = "User to run the container as"
  type        = string
  default     = null
}

variable "working_directory" {
  description = "Working directory for the container"
  type        = string
  default     = null
}

variable "entry_point" {
  description = "Entry point for the container"
  type        = list(string)
  default     = null
}

variable "command" {
  description = "Command to run in the container"
  type        = list(string)
  default     = null
}

variable "start_timeout" {
  description = "Timeout for container start in seconds"
  type        = number
  default     = null
}

variable "stop_timeout" {
  description = "Timeout for container stop in seconds"
  type        = number
  default     = null
}

# ==============================================================================
# Environment and Secrets
# ==============================================================================

variable "environment_variables" {
  description = "Environment variables for the container"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Secrets from Parameter Store or Secrets Manager"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

# ==============================================================================
# Health Check Configuration
# ==============================================================================

variable "health_check_enabled" {
  description = "Enable container health check"
  type        = bool
  default     = false
}

variable "health_check_command" {
  description = "Health check command"
  type        = list(string)
  default     = ["CMD-SHELL", "curl -f http://localhost/ || exit 1"]
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "health_check_retries" {
  description = "Number of health check retries"
  type        = number
  default     = 3
}

variable "health_check_start_period" {
  description = "Health check start period in seconds"
  type        = number
  default     = 60
}

# ==============================================================================
# Volumes and Mount Points
# ==============================================================================

variable "volumes" {
  description = "List of volumes for the task definition"
  type = list(object({
    name = string
    host_path = optional(object({
      source_path = string
    }))
    docker_volume_configuration = optional(object({
      scope         = string
      autoprovision = bool
      driver        = string
      driver_opts   = map(string)
      labels        = map(string)
    }))
    efs_volume_configuration = optional(object({
      file_system_id          = string
      root_directory          = string
      transit_encryption      = string
      transit_encryption_port = number
      authorization_config = optional(object({
        access_point_id = string
        iam             = string
      }))
    }))
  }))
  default = []
}

variable "mount_points" {
  description = "Mount points for the container"
  type = list(object({
    source_volume  = string
    container_path = string
    read_only      = bool
  }))
  default = []
}

# ==============================================================================
# Linux Parameters and Limits
# ==============================================================================

variable "linux_parameters" {
  description = "Linux-specific parameters"
  type = object({
    capabilities = optional(object({
      add  = list(string)
      drop = list(string)
    }))
    devices = optional(list(object({
      host_path      = string
      container_path = string
      permissions    = list(string)
    })))
    init_process_enabled = optional(bool)
    max_swap            = optional(number)
    shared_memory_size  = optional(number)
    swappiness          = optional(number)
    tmpfs = optional(list(object({
      container_path = string
      size           = number
      mount_options  = list(string)
    })))
  })
  default = null
}

variable "ulimits" {
  description = "Ulimits for the container"
  type = list(object({
    name       = string
    hard_limit = number
    soft_limit = number
  }))
  default = []
}

variable "system_controls" {
  description = "System controls for the container"
  type = list(object({
    namespace = string
    value     = string
  }))
  default = []
}

variable "docker_labels" {
  description = "Docker labels for the container"
  type        = map(string)
  default     = {}
}

# ==============================================================================
# Service Configuration
# ==============================================================================

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 1
}

variable "platform_version" {
  description = "Platform version for Fargate tasks"
  type        = string
  default     = null
}

variable "scheduling_strategy" {
  description = "Scheduling strategy (REPLICA or DAEMON)"
  type        = string
  default     = "REPLICA"
}

variable "enable_execute_command" {
  description = "Enable ECS Exec for debugging"
  type        = bool
  default     = false
}

variable "propagate_tags" {
  description = "How to propagate tags (TASK_DEFINITION, SERVICE, or NONE)"
  type        = string
  default     = "SERVICE"
}

variable "enable_ecs_managed_tags" {
  description = "Enable ECS managed tags"
  type        = bool
  default     = true
}

variable "force_new_deployment" {
  description = "Force new deployment on every apply"
  type        = bool
  default     = false
}

variable "wait_for_steady_state" {
  description = "Wait for service to reach steady state"
  type        = bool
  default     = true
}

# ==============================================================================
# Capacity Provider Strategy
# ==============================================================================

variable "capacity_provider_strategy" {
  description = "Capacity provider strategy for the service"
  type = list(object({
    capacity_provider = string
    weight            = number
    base              = number
  }))
  default = []
}

# ==============================================================================
# Network Configuration
# ==============================================================================

variable "subnet_ids" {
  description = "List of subnet IDs for awsvpc network mode"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "List of security group IDs for awsvpc network mode"
  type        = list(string)
  default     = []
}

variable "assign_public_ip" {
  description = "Assign public IP for awsvpc network mode"
  type        = bool
  default     = false
}

# ==============================================================================
# Load Balancer Configuration
# ==============================================================================

variable "load_balancer_enabled" {
  description = "Enable load balancer integration"
  type        = bool
  default     = false
}

variable "load_balancer_config" {
  description = "Load balancer configuration"
  type = object({
    target_group_arn = string
    container_name   = string
    container_port   = number
  })
  default = null
}

variable "load_balancer_dependency" {
  description = "Load balancer dependency (target group listener)"
  type        = any
  default     = null
}

variable "health_check_grace_period" {
  description = "Health check grace period in seconds"
  type        = number
  default     = 300
}

# ==============================================================================
# Service Discovery
# ==============================================================================

variable "service_registries" {
  description = "Service discovery registries"
  type = list(object({
    registry_arn   = string
    port           = number
    container_name = string
    container_port = number
  }))
  default = []
}

# ==============================================================================
# Deployment Configuration
# ==============================================================================

variable "deployment_maximum_percent" {
  description = "Maximum percent of tasks during deployment"
  type        = number
  default     = 200
}

variable "deployment_minimum_healthy_percent" {
  description = "Minimum healthy percent of tasks during deployment"
  type        = number
  default     = 50
}

variable "deployment_circuit_breaker_enabled" {
  description = "Enable deployment circuit breaker"
  type        = bool
  default     = true
}

variable "deployment_circuit_breaker_rollback" {
  description = "Enable automatic rollback on deployment failure"
  type        = bool
  default     = true
}

variable "deployment_controller_type" {
  description = "Deployment controller type (ECS, CODE_DEPLOY, EXTERNAL)"
  type        = string
  default     = "ECS"
}

# ==============================================================================
# Placement Configuration
# ==============================================================================

variable "placement_constraints" {
  description = "Task placement constraints"
  type = list(object({
    type       = string
    expression = string
  }))
  default = []
}

variable "service_placement_constraints" {
  description = "Service placement constraints"
  type = list(object({
    type       = string
    expression = string
  }))
  default = []
}

variable "placement_strategy" {
  description = "Task placement strategy"
  type = list(object({
    type  = string
    field = string
  }))
  default = []
}

variable "ordered_placement_strategy" {
  description = "Ordered placement strategy"
  type = list(object({
    type  = string
    field = string
  }))
  default = [
    {
      type  = "spread"
      field = "attribute:ecs.availability-zone"
    },
    {
      type  = "spread"
      field = "instanceId"
    }
  ]
}

# ==============================================================================
# Auto Scaling Configuration
# ==============================================================================

variable "enable_autoscaling" {
  description = "Enable auto scaling for the service"
  type        = bool
  default     = false
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of tasks for auto scaling"
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of tasks for auto scaling"
  type        = number
  default     = 10
}

variable "autoscaling_cpu_policy_enabled" {
  description = "Enable CPU-based auto scaling policy"
  type        = bool
  default     = true
}

variable "autoscaling_cpu_target_value" {
  description = "Target CPU utilization percentage for auto scaling"
  type        = number
  default     = 70
}

variable "autoscaling_memory_policy_enabled" {
  description = "Enable memory-based auto scaling policy"
  type        = bool
  default     = false
}

variable "autoscaling_memory_target_value" {
  description = "Target memory utilization percentage for auto scaling"
  type        = number
  default     = 80
}

variable "autoscaling_scale_in_cooldown" {
  description = "Scale in cooldown period in seconds"
  type        = number
  default     = 300
}

variable "autoscaling_scale_out_cooldown" {
  description = "Scale out cooldown period in seconds"
  type        = number
  default     = 300
}

# ==============================================================================
# Logging Configuration
# ==============================================================================

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

# ==============================================================================
# Tags
# ==============================================================================

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# ECS Module Variables

# ==============================================================================
# Required Variables
# ==============================================================================

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where ECS cluster will be deployed"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS instances"
  type        = list(string)
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
}

# ==============================================================================
# Instance Configuration
# ==============================================================================

variable "ec2_instance_type" {
  description = "Instance type for on-demand EC2 instances"
  type        = string
  default     = "t3.medium"
}

variable "spot_instance_type" {
  description = "Instance type for spot instances"
  type        = string
  default     = "t3.medium"
}

variable "spot_max_price" {
  description = "Maximum price for spot instances (per hour)"
  type        = string
  default     = "0.05"
}

variable "ebs_volume_size" {
  description = "Size of EBS volume in GB"
  type        = number
  default     = 30
}

variable "ebs_volume_type" {
  description = "Type of EBS volume"
  type        = string
  default     = "gp3"
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring for EC2 instances"
  type        = bool
  default     = true
}

# ==============================================================================
# Auto Scaling Configuration - EC2
# ==============================================================================

variable "ec2_min_capacity" {
  description = "Minimum number of EC2 instances"
  type        = number
  default     = 1
}

variable "ec2_max_capacity" {
  description = "Maximum number of EC2 instances"
  type        = number
  default     = 10
}

variable "ec2_desired_capacity" {
  description = "Desired number of EC2 instances"
  type        = number
  default     = 2
}

variable "ec2_target_capacity" {
  description = "Target capacity percentage for EC2 instances"
  type        = number
  default     = 100
}

variable "ec2_maximum_scaling_step_size" {
  description = "Maximum scaling step size for EC2 instances"
  type        = number
  default     = 1000
}

variable "ec2_minimum_scaling_step_size" {
  description = "Minimum scaling step size for EC2 instances"
  type        = number
  default     = 1
}

# ==============================================================================
# Auto Scaling Configuration - Spot
# ==============================================================================

variable "spot_min_capacity" {
  description = "Minimum number of spot instances"
  type        = number
  default     = 0
}

variable "spot_max_capacity" {
  description = "Maximum number of spot instances"
  type        = number
  default     = 10
}

variable "spot_desired_capacity" {
  description = "Desired number of spot instances"
  type        = number
  default     = 1
}

variable "spot_target_capacity" {
  description = "Target capacity percentage for spot instances"
  type        = number
  default     = 100
}

variable "spot_maximum_scaling_step_size" {
  description = "Maximum scaling step size for spot instances"
  type        = number
  default     = 1000
}

variable "spot_minimum_scaling_step_size" {
  description = "Minimum scaling step size for spot instances"
  type        = number
  default     = 1
}

# ==============================================================================
# Capacity Provider Strategy
# ==============================================================================

variable "default_capacity_provider_base" {
  description = "Base number of tasks to run on the default capacity provider"
  type        = number
  default     = 1
}

variable "default_capacity_provider_weight_ec2" {
  description = "Weight for EC2 capacity provider in default strategy"
  type        = number
  default     = 1
}

variable "default_capacity_provider_weight_spot" {
  description = "Weight for Spot capacity provider in default strategy"
  type        = number
  default     = 2
}

# ==============================================================================
# Security Configuration
# ==============================================================================

variable "enable_ssh_access" {
  description = "Enable SSH access to ECS instances"
  type        = bool
  default     = false
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = []
}

variable "create_key_pair" {
  description = "Create a new key pair for ECS instances"
  type        = bool
  default     = true
}

variable "existing_key_pair_name" {
  description = "Name of existing key pair to use (if create_key_pair is false)"
  type        = string
  default     = null
}

# ==============================================================================
# ECS Configuration
# ==============================================================================

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights for ECS cluster"
  type        = bool
  default     = true
}

variable "service_connect_namespace" {
  description = "Service Connect namespace for ECS cluster"
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "KMS key ID for ECS execute command encryption"
  type        = string
  default     = null
}

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

# Variables for production environment

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraform-infra"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

# Subnet CIDR blocks
variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.10.192.0/20", "10.10.208.0/20", "10.10.224.0/20"]
}

variable "private_subnet_cidrs_1" {
  description = "CIDR blocks for first set of private subnets"
  type        = list(string)
  default     = ["10.10.96.0/19", "10.10.128.0/19", "10.10.160.0/19"]
}

variable "private_subnet_cidrs_2" {
  description = "CIDR blocks for second set of private subnets"
  type        = list(string)
  default     = ["10.10.0.0/19", "10.10.32.0/19", "10.10.64.0/19"]
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in VPC"
  type        = bool
  default     = true
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway instead of one per AZ"
  type        = bool
  default     = false
}

# Tags
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "terraform-infra"
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}

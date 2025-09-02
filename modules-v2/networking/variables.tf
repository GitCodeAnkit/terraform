# Networking Module - Variables

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "List of availability zones to use. If null, will auto-select based on az_count"
  type        = list(string)
  default     = null
}

variable "az_count" {
  description = "Number of availability zones to use when availability_zones is null"
  type        = number
  default     = 3
  validation {
    condition     = var.az_count >= 1 && var.az_count <= 6
    error_message = "AZ count must be between 1 and 6."
  }
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

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  validation {
    condition     = length(var.public_subnet_cidrs) >= 1
    error_message = "At least one public subnet CIDR block must be provided."
  }
}

variable "private_app_subnet_cidrs" {
  description = "CIDR blocks for private application subnets"
  type        = list(string)
  validation {
    condition     = length(var.private_app_subnet_cidrs) >= 1 || !var.enable_private_subnets
    error_message = "At least one private app subnet CIDR block must be provided when enable_private_subnets is true."
  }
}

variable "private_db_subnet_cidrs" {
  description = "CIDR blocks for private database subnets"
  type        = list(string)
  validation {
    condition     = length(var.private_db_subnet_cidrs) >= 1 || !var.enable_database_subnets
    error_message = "At least one private DB subnet CIDR block must be provided when enable_database_subnets is true."
  }
}

variable "enable_private_subnets" {
  description = "Enable creation of private application subnets"
  type        = bool
  default     = true
}

variable "enable_database_subnets" {
  description = "Enable creation of private database subnets"
  type        = bool
  default     = true
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway creation"
  type        = bool
  default     = true
}

variable "nat_gateway_count" {
  description = "Number of NAT gateways to create"
  type        = number
  default     = 1
  validation {
    condition     = var.nat_gateway_count >= 1 && var.nat_gateway_count <= 6
    error_message = "NAT gateway count must be between 1 and 6."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

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

variable "public_subnet_bits" {
  description = "Number of additional bits to use for public subnet sizing"
  type        = number
  default     = 8
}

variable "private_subnet_bits" {
  description = "Number of additional bits to use for private subnet sizing"
  type        = number
  default     = 8
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

# Routing Module - Variables

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  type        = string
}

variable "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  type        = list(string)
  default     = []
}

variable "nat_gateway_count" {
  description = "Number of NAT gateways (for route table distribution)"
  type        = number
  default     = 1
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_app_subnet_ids" {
  description = "List of private application subnet IDs"
  type        = list(string)
  default     = []
}

variable "private_db_subnet_ids" {
  description = "List of private database subnet IDs"
  type        = list(string)
  default     = []
}

variable "enable_nat_routes" {
  description = "Enable default route through NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "create_private_2_route_table" {
  description = "Create separate route table for private_2 subnets (more secure)"
  type        = bool
  default     = false
}

variable "additional_public_routes" {
  description = "Additional routes for public route table"
  type = list(object({
    cidr_block                = string
    gateway_id                = optional(string)
    nat_gateway_id            = optional(string)
    vpc_peering_connection_id = optional(string)
  }))
  default = []
}

variable "additional_private_routes" {
  description = "Additional routes for private route tables"
  type = list(object({
    cidr_block                = string
    gateway_id                = optional(string)
    nat_gateway_id            = optional(string)
    vpc_peering_connection_id = optional(string)
  }))
  default = []
}

variable "additional_private_2_routes" {
  description = "Additional routes for private_2 route table"
  type = list(object({
    cidr_block                = string
    gateway_id                = optional(string)
    nat_gateway_id            = optional(string)
    vpc_peering_connection_id = optional(string)
  }))
  default = []
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

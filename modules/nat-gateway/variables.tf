# NAT Gateway Module - Variables

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "nat_gateway_count" {
  description = "Number of NAT gateways to create"
  type        = number
  default     = 2
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets"
  type        = list(string)
}

variable "private_app_subnet_ids" {
  description = "IDs of the private application subnets"
  type        = list(string)
}

variable "private_db_subnet_ids" {
  description = "IDs of the private database subnets"
  type        = list(string)
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

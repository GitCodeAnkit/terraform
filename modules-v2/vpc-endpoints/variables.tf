# VPC Endpoints Module - Variables

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "route_table_ids" {
  description = "List of route table IDs for gateway endpoints"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for interface endpoints"
  type        = list(string)
  default     = []
}

variable "endpoint_security_group_ids" {
  description = "List of security group IDs for interface endpoints"
  type        = list(string)
  default     = []
}

# S3 Endpoint Configuration
variable "enable_s3_endpoint" {
  description = "Enable S3 VPC endpoint"
  type        = bool
  default     = true
}

variable "s3_endpoint_policy" {
  description = "Custom policy for S3 endpoint"
  type        = string
  default     = null
}

# DynamoDB Endpoint Configuration
variable "enable_dynamodb_endpoint" {
  description = "Enable DynamoDB VPC endpoint"
  type        = bool
  default     = true
}

variable "dynamodb_endpoint_policy" {
  description = "Custom policy for DynamoDB endpoint"
  type        = string
  default     = null
}

# EC2 Endpoint Configuration
variable "enable_ec2_endpoint" {
  description = "Enable EC2 VPC endpoint"
  type        = bool
  default     = false
}

variable "ec2_endpoint_policy" {
  description = "Custom policy for EC2 endpoint"
  type        = string
  default     = null
}

# SSM Endpoints Configuration
variable "enable_ssm_endpoints" {
  description = "Enable SSM VPC endpoints (ssm, ssmmessages, ec2messages)"
  type        = bool
  default     = false
}

variable "ssm_endpoint_policy" {
  description = "Custom policy for SSM endpoints"
  type        = string
  default     = null
}

# Custom Endpoints
variable "custom_endpoints" {
  description = "Map of custom VPC endpoints to create"
  type = map(object({
    service_name        = string
    type               = string # "Gateway" or "Interface"
    policy             = optional(string)
    private_dns_enabled = optional(bool)
  }))
  default = {}
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

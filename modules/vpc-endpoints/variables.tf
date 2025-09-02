# VPC Endpoints Module - Variables

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "route_table_ids" {
  description = "List of route table IDs to associate with VPC endpoints"
  type        = list(string)
}

variable "enable_dynamodb_endpoint" {
  description = "Enable DynamoDB VPC endpoint"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

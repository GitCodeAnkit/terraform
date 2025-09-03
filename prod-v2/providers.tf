# Provider configuration

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = var.common_tags
  }
}

# Data sources for AWS information
data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

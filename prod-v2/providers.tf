# Provider configuration

provider "aws" {
  region = var.aws_region
  access_key = "YOUR_AWS_ACCESS_KEY"
  secret_key = "YOUR_AWS_SECRET_KEY"

  default_tags {
    tags = var.common_tags
  }
}

# Data sources for AWS information
data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

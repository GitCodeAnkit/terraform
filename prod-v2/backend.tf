# Backend configuration for Terraform state
# This should be applied after creating the S3 bucket and DynamoDB table manually
# or use a separate bootstrap configuration

terraform {
  backend "s3" {
    bucket         = "fitsib-terra"
    key            = "prod/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-lock-prod"
    encrypt        = true
    
    # Uncomment after initial setup
    # versioning = true
  }
  
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# Generate random suffix for unique bucket naming
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

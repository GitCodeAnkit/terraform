# Production Infrastructure

This directory contains Terraform configuration for the production AWS infrastructure.

## Architecture Overview

- **VPC**: 10.10.0.0/16 CIDR block
- **Subnets**: 
  - 3 Public subnets (one per AZ: us-east-1a, us-east-1b, us-east-1c)
  - 6 Private subnets (2 per AZ - application and database tiers)
- **NAT Gateways**: 2 NAT gateways
  - NAT Gateway 1: Serves AZ 1a and 1b
  - NAT Gateway 2: Serves AZ 1c
- **VPC Endpoints**: S3 and DynamoDB gateway endpoints for all subnets
- **Backend**: S3 + DynamoDB for Terraform state management

## Setup Instructions

### 1. Initial Setup (First Time Only)

1. **Configure AWS credentials:**
   ```bash
   aws configure
   # or use environment variables
   export AWS_ACCESS_KEY_ID="your-access-key"
   export AWS_SECRET_ACCESS_KEY="your-secret-key"
   export AWS_DEFAULT_REGION="us-east-1"
   ```

2. **Initialize Terraform without backend:**
   ```bash
   cd /Users/ankitprajapati/projects/self/terraform/prod
   terraform init
   ```

3. **Create bootstrap resources (S3 bucket and DynamoDB table):**
   ```bash
   # Apply only bootstrap resources first
   terraform apply -target=random_id.bucket_suffix -target=aws_s3_bucket.terraform_state -target=aws_s3_bucket_versioning.terraform_state -target=aws_s3_bucket_server_side_encryption_configuration.terraform_state -target=aws_s3_bucket_public_access_block.terraform_state -target=aws_dynamodb_table.terraform_state_lock
   ```

4. **Update backend configuration:**
   - Uncomment the backend configuration in `backend.tf`
   - Update the bucket name with the actual generated name from step 3

5. **Migrate state to S3:**
   ```bash
   terraform init -migrate-state
   ```

### 2. Regular Deployment

```bash
# Plan the infrastructure
terraform plan

# Apply the changes
terraform apply

# Destroy (if needed)
terraform destroy
```

## File Structure

```
terraform/
├── modules/
│   ├── vpc/
│   │   ├── main.tf       # VPC and Internet Gateway
│   │   ├── variables.tf  # VPC module variables
│   │   └── outputs.tf    # VPC module outputs
│   ├── subnets/
│   │   ├── main.tf       # Public/Private subnets and public routing
│   │   ├── variables.tf  # Subnets module variables
│   │   └── outputs.tf    # Subnets module outputs
│   ├── nat-gateway/
│   │   ├── main.tf       # NAT gateways and private routing
│   │   ├── variables.tf  # NAT gateway module variables
│   │   └── outputs.tf    # NAT gateway module outputs
│   └── vpc-endpoints/
│       ├── main.tf       # S3 and DynamoDB VPC endpoints
│       ├── variables.tf  # VPC endpoints module variables
│       └── outputs.tf    # VPC endpoints module outputs
└── prod/
    ├── backend.tf        # Terraform backend configuration
    ├── bootstrap.tf      # Bootstrap resources (S3, DynamoDB)
    ├── main.tf          # Main configuration using modules
    ├── providers.tf     # Provider configurations
    ├── variables.tf     # Variable definitions
    ├── terraform.tfvars # Variable values
    ├── outputs.tf       # Output values from modules
    └── README.md        # This file
```

## Best Practices Implemented

1. **State Management**: Remote state with S3 backend and DynamoDB locking
2. **Modular Architecture**: Separate modules for VPC, subnets, NAT gateways, and VPC endpoints
3. **Networking**: Multi-AZ setup with proper subnet segregation
4. **Security**: Private subnets, NAT gateways, VPC endpoints
5. **Tagging**: Consistent tagging strategy for all resources
6. **Reusability**: Modules can be reused across environments (dev, staging, prod)
7. **Maintainability**: Clean separation of concerns with dedicated modules
8. **Cost Optimization**: Only 2 NAT gateways instead of 3 (per requirements)

## NAT Gateway Configuration

As per requirements:
- **NAT Gateway 1** (us-east-1a): Serves private subnets in us-east-1a and us-east-1b
- **NAT Gateway 2** (us-east-1c): Serves private subnets in us-east-1c

This reduces costs while maintaining high availability across multiple AZs.

## Modular Architecture Benefits

The infrastructure is organized into reusable modules:

1. **VPC Module**: Creates the core VPC and Internet Gateway
2. **Subnets Module**: Manages all subnet creation and public routing
3. **NAT Gateway Module**: Handles NAT gateways and private subnet routing
4. **VPC Endpoints Module**: Configures S3 and DynamoDB gateway endpoints

### Module Dependencies
```
vpc → subnets → nat-gateway → vpc-endpoints
```

This approach enables:
- **Reusability**: Use the same modules for dev, staging, and prod
- **Testing**: Test individual components in isolation
- **Maintenance**: Update specific components without affecting others
- **Clear Ownership**: Each module has a single responsibility

## VPC Endpoints

Both S3 and DynamoDB gateway endpoints are configured to:
- Reduce data transfer costs
- Improve performance
- Keep traffic within the AWS network
- Support Terraform state operations

## Important Notes

1. Update the `terraform.tfvars` file with your specific requirements
2. Ensure AWS credentials are properly configured
3. Review and adjust the CIDR blocks if needed
4. The bootstrap process needs to be run only once
5. Always run `terraform plan` before applying changes

## Troubleshooting

- If backend initialization fails, ensure the S3 bucket and DynamoDB table exist
- Check AWS credentials and permissions
- Verify the region settings match across all configurations

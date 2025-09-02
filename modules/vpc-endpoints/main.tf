# VPC Endpoints Module - Main Configuration

# S3 VPC Endpoint (Gateway Endpoint)
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  
  # Gateway endpoint type for S3
  vpc_endpoint_type = "Gateway"
  
  # Associate with all route tables
  route_table_ids = var.route_table_ids

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-s3-endpoint"
    Type = "Gateway"
  })
}

# DynamoDB VPC Endpoint (Gateway Endpoint) - for Terraform state locking
resource "aws_vpc_endpoint" "dynamodb" {
  count = var.enable_dynamodb_endpoint ? 1 : 0

  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.dynamodb"
  
  # Gateway endpoint type for DynamoDB
  vpc_endpoint_type = "Gateway"
  
  # Associate with all route tables
  route_table_ids = var.route_table_ids

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem"
        ]
        Resource = [
          "*"
        ]
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-dynamodb-endpoint"
    Type = "Gateway"
  })
}

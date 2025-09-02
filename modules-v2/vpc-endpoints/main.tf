# VPC Endpoints Module - Gateway and Interface Endpoints

# S3 VPC Endpoint (Gateway)
resource "aws_vpc_endpoint" "s3" {
  count = var.enable_s3_endpoint ? 1 : 0

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.route_table_ids

  policy = var.s3_endpoint_policy != null ? var.s3_endpoint_policy : jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:ListAllMyBuckets"
        ]
        Resource = ["*"]
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-s3-endpoint"
    Type = "Gateway"
  })
}

# DynamoDB VPC Endpoint (Gateway)
resource "aws_vpc_endpoint" "dynamodb" {
  count = var.enable_dynamodb_endpoint ? 1 : 0

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.route_table_ids

  policy = var.dynamodb_endpoint_policy != null ? var.dynamodb_endpoint_policy : jsonencode({
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
          "dynamodb:UpdateItem",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem"
        ]
        Resource = ["*"]
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-dynamodb-endpoint"
    Type = "Gateway"
  })
}

# EC2 VPC Endpoint (Interface)
resource "aws_vpc_endpoint" "ec2" {
  count = var.enable_ec2_endpoint ? 1 : 0

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ec2"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = var.endpoint_security_group_ids
  private_dns_enabled = true

  policy = var.ec2_endpoint_policy

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-ec2-endpoint"
    Type = "Interface"
  })
}

# SSM VPC Endpoints (Interface) - For Session Manager
resource "aws_vpc_endpoint" "ssm" {
  count = var.enable_ssm_endpoints ? 1 : 0

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = var.endpoint_security_group_ids
  private_dns_enabled = true

  policy = var.ssm_endpoint_policy

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-ssm-endpoint"
    Type = "Interface"
  })
}

resource "aws_vpc_endpoint" "ssm_messages" {
  count = var.enable_ssm_endpoints ? 1 : 0

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = var.endpoint_security_group_ids
  private_dns_enabled = true

  policy = var.ssm_endpoint_policy

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-ssmmessages-endpoint"
    Type = "Interface"
  })
}

resource "aws_vpc_endpoint" "ec2_messages" {
  count = var.enable_ssm_endpoints ? 1 : 0

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnet_ids
  security_group_ids  = var.endpoint_security_group_ids
  private_dns_enabled = true

  policy = var.ssm_endpoint_policy

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-ec2messages-endpoint"
    Type = "Interface"
  })
}

# Custom VPC Endpoints
resource "aws_vpc_endpoint" "custom" {
  for_each = var.custom_endpoints

  vpc_id            = var.vpc_id
  service_name      = each.value.service_name
  vpc_endpoint_type = each.value.type

  # Gateway endpoint configuration
  route_table_ids = each.value.type == "Gateway" ? var.route_table_ids : null

  # Interface endpoint configuration
  subnet_ids          = each.value.type == "Interface" ? var.private_subnet_ids : null
  security_group_ids  = each.value.type == "Interface" ? var.endpoint_security_group_ids : null
  private_dns_enabled = each.value.type == "Interface" ? lookup(each.value, "private_dns_enabled", true) : null

  policy = lookup(each.value, "policy", null)

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-${each.key}-endpoint"
    Type = each.value.type
  })
}

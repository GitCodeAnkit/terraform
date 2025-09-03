local# ECS Cluster Module - EC2 and Spot Capacity Providers
# This module creates an ECS cluster with both EC2 and Spot instances

# Data sources
data "aws_ami" "ecs_optimized" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# ==============================================================================
# IAM Roles and Policies
# ==============================================================================

# ECS Instance Role
resource "aws_iam_role" "ecs_instance_role" {
  name = "${var.name_prefix}-ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

# Attach ECS Instance Role Policy
resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# Instance Profile
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "${var.name_prefix}-ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name

  tags = var.common_tags
}

# ECS Service Role
resource "aws_iam_role" "ecs_service_role" {
  name = "${var.name_prefix}-ecs-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

# Attach ECS Service Role Policy
resource "aws_iam_role_policy_attachment" "ecs_service_role_policy" {
  role       = aws_iam_role.ecs_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.name_prefix}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

# Attach ECS Task Execution Role Policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ==============================================================================
# Security Groups
# ==============================================================================

# ECS Cluster Security Group
resource "aws_security_group" "ecs_cluster" {
  name_prefix = "${var.name_prefix}-ecs-cluster-"
  vpc_id      = var.vpc_id
  description = "Security group for ECS cluster instances"

  # HTTP access for ALB health checks
  ingress {
    description = "HTTP from ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # HTTPS access for ALB health checks
  ingress {
    description = "HTTPS from ALB"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Dynamic port mapping for ECS
  ingress {
    description = "Dynamic ports for ECS"
    from_port   = 32768
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # SSH access (if key pair is provided)
  dynamic "ingress" {
    for_each = var.enable_ssh_access ? [1] : []
    content {
      description = "SSH access"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.ssh_allowed_cidrs
    }
  }

  # Allow all outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-ecs-cluster-sg"
    Type = "ecs-cluster"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ALB Security Group
resource "aws_security_group" "ecs_alb" {
  name_prefix = "${var.name_prefix}-ecs-alb-"
  vpc_id      = var.vpc_id
  description = "Security group for ECS Application Load Balancer"

  # HTTP access
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-ecs-alb-sg"
    Type = "ecs-alb"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ==============================================================================
# Key Pair
# ==============================================================================

# Generate TLS private key
resource "tls_private_key" "ecs_key" {
  count     = var.create_key_pair ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair
resource "aws_key_pair" "ecs_key_pair" {
  count      = var.create_key_pair ? 1 : 0
  key_name   = "${var.name_prefix}-ecs-key"
  public_key = tls_private_key.ecs_key[0].public_key_openssh

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-ecs-key"
  })
}

# Store private key in AWS Systems Manager Parameter Store
resource "aws_ssm_parameter" "ecs_private_key" {
  count       = var.create_key_pair ? 1 : 0
  name        = "/${var.name_prefix}/ecs/private-key"
  description = "Private key for ECS EC2 instances"
  type        = "SecureString"
  value       = tls_private_key.ecs_key[0].private_key_pem

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-ecs-private-key"
  })
}

# ==============================================================================
# Launch Templates
# ==============================================================================

# User data script for ECS instances
locals {
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    cluster_name = aws_ecs_cluster.main.name
    region       = var.aws_region
  }))
}

# Launch Template for On-Demand EC2 instances
resource "aws_launch_template" "ecs_ec2" {
  name_prefix   = "${var.name_prefix}-ecs-ec2-"
  image_id      = data.aws_ami.ecs_optimized.id
  instance_type = var.ec2_instance_type
  key_name      = var.create_key_pair ? aws_key_pair.ecs_key_pair[0].key_name : var.existing_key_pair_name

  vpc_security_group_ids = [aws_security_group.ecs_cluster.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  user_data = local.user_data

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.ebs_volume_size
      volume_type           = var.ebs_volume_type
      delete_on_termination = true
      encrypted             = true
    }
  }

  monitoring {
    enabled = var.enable_detailed_monitoring
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = "${var.name_prefix}-ecs-ec2"
      Type = "ecs-ec2-ondemand"
    })
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-ecs-ec2-lt"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Launch Template for Spot instances
resource "aws_launch_template" "ecs_spot" {
  name_prefix   = "${var.name_prefix}-ecs-spot-"
  image_id      = data.aws_ami.ecs_optimized.id
  instance_type = var.spot_instance_type
  key_name      = var.create_key_pair ? aws_key_pair.ecs_key_pair[0].key_name : var.existing_key_pair_name

  vpc_security_group_ids = [aws_security_group.ecs_cluster.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  user_data = local.user_data

  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price = var.spot_max_price
    }
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.ebs_volume_size
      volume_type           = var.ebs_volume_type
      delete_on_termination = true
      encrypted             = true
    }
  }

  monitoring {
    enabled = var.enable_detailed_monitoring
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = "${var.name_prefix}-ecs-spot"
      Type = "ecs-ec2-spot"
    })
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-ecs-spot-lt"
  })

  lifecycle {
    create_before_destroy = true
  }
}

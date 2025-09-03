# Production Environment - Improved Modular Structure
# Using the enhanced module architecture

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  
  # NAT Gateway distribution logic for your requirement:
  # 2 NAT gateways - one serves AZ 1a+1b, another serves AZ 1c
  nat_gateway_count = 2
}

# Networking Module - All networking infrastructure
module "networking" {
  source = "../modules-v2/networking"

  name_prefix          = local.name_prefix
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  
  # Subnet configuration
  enable_private_subnets   = true
  enable_database_subnets  = true
  
  # CIDR blocks from variables
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_subnet_cidrs_1
  private_db_subnet_cidrs  = var.private_subnet_cidrs_2
  
  # NAT Gateway configuration
  enable_nat_gateway      = true
  nat_gateway_count       = local.nat_gateway_count
  
  # DNS configuration
  enable_dns_hostnames    = var.enable_dns_hostnames
  enable_dns_support      = var.enable_dns_support
  
  common_tags = var.common_tags
}

# Routing Module - All routing logic
module "routing" {
  source = "../modules-v2/routing"

  name_prefix         = local.name_prefix
  vpc_id             = module.networking.vpc_id
  internet_gateway_id = module.networking.internet_gateway_id
  
  # NAT Gateway routing
  nat_gateway_ids    = module.networking.nat_gateway_ids
  nat_gateway_count  = local.nat_gateway_count
  
  # Subnet associations
  public_subnet_ids      = module.networking.public_subnet_ids
  private_app_subnet_ids = module.networking.private_app_subnet_ids
  private_db_subnet_ids  = module.networking.private_db_subnet_ids
  
  # Routing configuration
  enable_nat_routes              = true
  create_private_2_route_table   = false  # Use same routing as app subnets
  
  common_tags = var.common_tags
}

# VPC Endpoints Module - Enhanced endpoint management
module "vpc_endpoints" {
  source = "../modules-v2/vpc-endpoints"

  name_prefix    = local.name_prefix
  vpc_id        = module.networking.vpc_id
  aws_region    = var.aws_region
  route_table_ids = module.routing.all_route_table_ids
  
  # Gateway endpoints (your requirements)
  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = true
  
  # Optional interface endpoints (commented out for cost)
  enable_ec2_endpoint      = false
  enable_ssm_endpoints     = false
  
  # Private subnets for interface endpoints (if enabled)
  private_subnet_ids = module.networking.private_app_subnet_ids
  
  common_tags = var.common_tags
}

# ECS Cluster Module - Container orchestration with EC2 and Spot capacity
module "ecs" {
  source = "../modules-v2/ecs"

  name_prefix         = local.name_prefix
  vpc_id             = module.networking.vpc_id
  vpc_cidr           = var.vpc_cidr
  private_subnet_ids = module.networking.private_app_subnet_ids
  aws_region         = var.aws_region

  # Instance configuration
  ec2_instance_type  = "t3.medium"
  spot_instance_type = "t3.medium"
  spot_max_price     = "0.05"

  # Auto Scaling configuration - EC2
  ec2_min_capacity     = 1
  ec2_max_capacity     = 5
  ec2_desired_capacity = 2

  # Auto Scaling configuration - Spot
  spot_min_capacity     = 0
  spot_max_capacity     = 10
  spot_desired_capacity = 3

  # Capacity provider strategy (favor spot instances for cost savings)
  default_capacity_provider_base        = 1
  default_capacity_provider_weight_ec2  = 1
  default_capacity_provider_weight_spot = 3

  # Security configuration
  enable_ssh_access   = true
  ssh_allowed_cidrs   = [var.vpc_cidr]  # Allow SSH only from within VPC
  create_key_pair     = true

  # ECS configuration
  enable_container_insights = true
  log_retention_days       = 30

  # Storage configuration
  ebs_volume_size = 30
  ebs_volume_type = "gp3"

  common_tags = var.common_tags
}

# Application Load Balancer Module - Internet-facing load balancer
module "alb" {
  source = "../modules-v2/alb"

  name_prefix = local.name_prefix
  vpc_id      = module.networking.vpc_id
  subnet_ids  = module.networking.public_subnet_ids  # Internet-facing ALB in public subnets

  # ALB Configuration
  internal                          = false
  enable_deletion_protection        = false
  enable_http2                     = true
  enable_cross_zone_load_balancing = true

  # Security Configuration
  allowed_cidr_blocks = ["0.0.0.0/0"]  # Allow internet access

  # Target Group Configuration
  target_group_port     = 80    # Container port
  target_group_protocol = "HTTP"
  target_type          = "instance"

  # Health Check Configuration
  health_check_enabled             = true
  health_check_healthy_threshold   = 2
  health_check_interval           = 30
  health_check_matcher            = "200"
  health_check_path               = "/"
  health_check_port               = "traffic-port"
  health_check_protocol           = "HTTP"
  health_check_timeout            = 5
  health_check_unhealthy_threshold = 2

  # SSL Configuration - ALB listens on port 443
  domain_name                = "your-domain.com"  # Replace with your actual domain
  subject_alternative_names  = ["*.your-domain.com"]
  # route53_zone_id           = "Z1234567890"  # Uncomment if you have Route53 zone

  # Access Logs (optional)
  access_logs_enabled = false

  common_tags = var.common_tags
}

# ECS Service Module - Web application service
module "ecs_service" {
  source = "../modules-v2/ecs-service"

  service_name    = "${local.name_prefix}-web-app"
  cluster_id      = module.ecs.cluster_id
  cluster_name    = module.ecs.cluster_name

  # Container Configuration
  container_image  = "nginx:latest"  # Replace with your application image
  container_name   = "web-app"
  container_port   = 80    # Container listens on port 80
  host_port        = 0     # Dynamic port mapping (ALB forwards 443->80)

  # Task Configuration
  task_cpu    = 256
  task_memory = 512
  network_mode = "bridge"

  # Container Resources
  container_cpu               = 128
  container_memory            = 256
  container_memory_reservation = 128

  # IAM Roles
  execution_role_arn = module.ecs.ecs_task_execution_role_arn
  task_role_arn     = module.ecs.ecs_task_execution_role_arn

  # Service Configuration
  desired_count = 2

  # Capacity Provider Strategy (favor spot instances)
  capacity_provider_strategy = [
    {
      capacity_provider = module.ecs.ec2_capacity_provider_name
      weight           = 1
      base             = 1
    },
    {
      capacity_provider = module.ecs.spot_capacity_provider_name
      weight           = 3
      base             = 0
    }
  ]

  # Load Balancer Integration
  load_balancer_enabled = true
  load_balancer_config = {
    target_group_arn = module.alb.primary_target_group_arn
    container_name   = "web-app"
    container_port   = 80
  }
  load_balancer_dependency = module.alb.http_listener_arn

  # Health Check
  health_check_grace_period = 300

  # Environment Variables
  environment_variables = {
    ENV = "production"
    APP_NAME = "${local.name_prefix}-web-app"
    AWS_REGION = var.aws_region
  }

  # Auto Scaling
  enable_autoscaling                = true
  autoscaling_min_capacity         = 2
  autoscaling_max_capacity         = 10
  autoscaling_cpu_policy_enabled   = true
  autoscaling_cpu_target_value     = 70
  autoscaling_memory_policy_enabled = false

  # Deployment Configuration
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50
  deployment_circuit_breaker_enabled = true
  deployment_circuit_breaker_rollback = true

  # Placement Strategy
  ordered_placement_strategy = [
    {
      type  = "spread"
      field = "attribute:ecs.availability-zone"
    },
    {
      type  = "spread"
      field = "instanceId"
    }
  ]

  # Logging
  log_retention_days = 30

  common_tags = var.common_tags

  depends_on = [module.alb, module.ecs]
}

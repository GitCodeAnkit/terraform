# Networking Module - Comprehensive Network Infrastructure
# This module creates the complete networking foundation: VPC, IGW, Subnets, NAT

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-igw"
  })
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Calculate availability zones to use
locals {
  azs = var.availability_zones != null ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, var.az_count)
}

# Public Subnets
resource "aws_subnet" "public" {
  count = length(local.azs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, var.public_subnet_bits, count.index)
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-public-${substr(local.azs[count.index], -1, 1)}"
    Type = "public"
    Tier = "public"
  })
}

# Private App Subnets
resource "aws_subnet" "private_app" {
  count = var.enable_private_subnets ? length(local.azs) : 0

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, var.private_subnet_bits, count.index + 10)
  availability_zone = local.azs[count.index]

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-private-app-${substr(local.azs[count.index], -1, 1)}"
    Type = "private"
    Tier = "application"
  })
}

# Private DB Subnets
resource "aws_subnet" "private_db" {
  count = var.enable_database_subnets ? length(local.azs) : 0

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, var.private_subnet_bits, count.index + 20)
  availability_zone = local.azs[count.index]

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-private-db-${substr(local.azs[count.index], -1, 1)}"
    Type = "private"
    Tier = "database"
  })
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? var.nat_gateway_count : 0

  domain     = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-nat-eip-${count.index + 1}"
  })
}

# NAT Gateways
resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? var.nat_gateway_count : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  depends_on    = [aws_internet_gateway.main]

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-nat-${count.index + 1}"
  })
}

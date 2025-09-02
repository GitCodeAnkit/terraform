# Subnets Module - Main Configuration

# Public Subnets
resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = var.vpc_id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-public-subnet-${substr(var.availability_zones[count.index], -1, 1)}"
    Type = "public"
    Tier = "public"
  })
}

# Private Subnets - Application Tier
resource "aws_subnet" "private_app" {
  count = length(var.availability_zones)

  vpc_id            = var.vpc_id
  cidr_block        = var.private_app_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-private-app-subnet-${substr(var.availability_zones[count.index], -1, 1)}"
    Type = "private"
    Tier = "application"
  })
}

# Private Subnets - Database Tier
resource "aws_subnet" "private_db" {
  count = length(var.availability_zones)

  vpc_id            = var.vpc_id
  cidr_block        = var.private_db_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-private-db-subnet-${substr(var.availability_zones[count.index], -1, 1)}"
    Type = "private"
    Tier = "database"
  })
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-public-rt"
    Type = "public"
  })
}

# Route Table Associations - Public Subnets
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

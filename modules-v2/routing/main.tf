# Routing Module - Route Tables and Associations
# This module handles all routing logic separate from network infrastructure
locals {
  nat_gateway_mapping = [0, 0, 1]
}
# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }

  dynamic "route" {
    for_each = var.additional_public_routes
    content {
      cidr_block = route.value.cidr_block
      gateway_id = lookup(route.value, "gateway_id", null)
      nat_gateway_id = lookup(route.value, "nat_gateway_id", null)
      vpc_peering_connection_id = lookup(route.value, "vpc_peering_connection_id", null)
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-public-rt"
    Type = "public"
  })
}

# Private Route Tables
resource "aws_route_table" "private" {
  count = var.nat_gateway_count

  vpc_id = var.vpc_id

  # Default route through NAT Gateway
  dynamic "route" {
    for_each = var.enable_nat_routes ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = var.nat_gateway_ids[count.index % length(var.nat_gateway_ids)]
    }
  }

  # Additional custom routes
  dynamic "route" {
    for_each = var.additional_private_routes
    content {
      cidr_block = route.value.cidr_block
      gateway_id = lookup(route.value, "gateway_id", null)
      nat_gateway_id = lookup(route.value, "nat_gateway_id", null)
      vpc_peering_connection_id = lookup(route.value, "vpc_peering_connection_id", null)
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-private-rt-${count.index + 1}"
    Type = "private"
  })
}

# Private Route Table 2 (if separate routing needed)
resource "aws_route_table" "private_2" {
  count = var.create_private_2_route_table ? 1 : 0

  vpc_id = var.vpc_id

  # No default internet route for private_2 subnets (more secure)
  dynamic "route" {
    for_each = var.additional_private_2_routes
    content {
      cidr_block = route.value.cidr_block
      gateway_id = lookup(route.value, "gateway_id", null)
      nat_gateway_id = lookup(route.value, "nat_gateway_id", null)
      vpc_peering_connection_id = lookup(route.value, "vpc_peering_connection_id", null)
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-private-2-rt"
    Type = "private_2"
  })
}

# Route Table Associations - Public Subnets
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_ids)

  subnet_id      = var.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public.id
}

# Route Table Associations - Private App Subnets
resource "aws_route_table_association" "private_app" {
  count = length(var.private_app_subnet_ids)

  subnet_id      = var.private_app_subnet_ids[count.index]
  route_table_id = aws_route_table.private[local.nat_gateway_mapping[count.index]].id
}

# Route Table Associations - Private DB Subnets
resource "aws_route_table_association" "private_db" {
  count = length(var.private_db_subnet_ids)

  subnet_id = var.private_db_subnet_ids[count.index]
  route_table_id = var.create_private_2_route_table ? aws_route_table.private_2[0].id : aws_route_table.private[local.nat_gateway_mapping[count.index]].id
}

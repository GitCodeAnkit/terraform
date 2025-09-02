# NAT Gateway Module - Main Configuration

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = var.nat_gateway_count

  domain     = "vpc"
  depends_on = [var.internet_gateway_id]

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-nat-eip-${count.index + 1}"
  })
}

# NAT Gateway 1 (for AZ 1a and 1b)
resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.nat[0].id
  subnet_id     = var.public_subnet_ids[0] # AZ 1a
  depends_on    = [var.internet_gateway_id]

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-nat-gateway-1"
    Zone = "1a-1b"
  })
}

# NAT Gateway 2 (for AZ 1c)
resource "aws_nat_gateway" "nat_2" {
  count = var.nat_gateway_count > 1 ? 1 : 0

  allocation_id = aws_eip.nat[1].id
  subnet_id     = var.public_subnet_ids[2] # AZ 1c
  depends_on    = [var.internet_gateway_id]

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-nat-gateway-2"
    Zone = "1c"
  })
}

# Private Route Tables
# Route table for AZ 1a and 1b (uses first NAT gateway)
resource "aws_route_table" "private_1" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_1.id
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-private-rt-1"
    Type = "private"
    Zone = "1a-1b"
  })
}

# Route table for AZ 1c (uses second NAT gateway)
resource "aws_route_table" "private_2" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_gateway_count > 1 ? aws_nat_gateway.nat_2[0].id : aws_nat_gateway.nat_1.id
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-private-rt-2"
    Type = "private"
    Zone = "1c"
  })
}

# Route Table Associations - Private App Subnets
# AZ 1a and 1b use first route table
resource "aws_route_table_association" "private_app_1a" {
  subnet_id      = var.private_app_subnet_ids[0]
  route_table_id = aws_route_table.private_1.id
}

resource "aws_route_table_association" "private_app_1b" {
  subnet_id      = var.private_app_subnet_ids[1]
  route_table_id = aws_route_table.private_1.id
}

# AZ 1c uses second route table
resource "aws_route_table_association" "private_app_1c" {
  subnet_id      = var.private_app_subnet_ids[2]
  route_table_id = aws_route_table.private_2.id
}

# Route Table Associations - Private DB Subnets
# AZ 1a and 1b use first route table
resource "aws_route_table_association" "private_db_1a" {
  subnet_id      = var.private_db_subnet_ids[0]
  route_table_id = aws_route_table.private_1.id
}

resource "aws_route_table_association" "private_db_1b" {
  subnet_id      = var.private_db_subnet_ids[1]
  route_table_id = aws_route_table.private_1.id
}

# AZ 1c uses second route table
resource "aws_route_table_association" "private_db_1c" {
  subnet_id      = var.private_db_subnet_ids[2]
  route_table_id = aws_route_table.private_2.id
}

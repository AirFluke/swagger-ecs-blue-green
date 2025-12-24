resource "aws_vpc" "swiggy-clone-vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support = var.enable_dns_support

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.swiggy-clone-vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id                  = aws_vpc.swiggy-clone-vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip

  tags = {
    Name = "${var.project_name}-${each.key}"
    Type = "public"
  }
}

resource "aws_subnet" "private" {
  for_each = var.private_subnets

  vpc_id                  = aws_vpc.swiggy-clone-vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-${each.key}"
    Type = "private"
  }
}

resource "aws_eip" "nat" {
  for_each = var.enable_nat_gateway ? (var.single_nat_gateway ? { for k in [element(keys(var.public_subnets), 0)] : "single" => k } : { for k, v in var.public_subnets : k => k }) : {}

  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip-${each.key}"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Create NAT Gateways (using public subnet keys)
resource "aws_nat_gateway" "nat" {
  for_each = var.enable_nat_gateway ? (var.single_nat_gateway ? { for k in [element(keys(var.public_subnets), 0)] : "single" => k } : { for k, v in var.public_subnets : k => k }) : {}

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.value].id

  tags = {
    Name = "${var.project_name}-nat-${each.key}"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Create a local map to link private subnets to NAT gateways
locals {
  # Map private subnet keys to their corresponding public subnet keys
  # Assumes: "private_1" maps to "public_1", "private_2" maps to "public_2", etc.
  private_to_nat_map = var.single_nat_gateway ? {
    for k in keys(var.private_subnets) : k => "single"
  } : {
    for k in keys(var.private_subnets) : k => replace(k, "private", "public")
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.swiggy-clone-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}


# Private Route Tables
resource "aws_route_table" "private" {
  for_each = var.enable_nat_gateway ? (var.single_nat_gateway ? { "single" = "single" } : { for k, v in var.private_subnets : k => k }) : { "default" = "default" }

  vpc_id = aws_vpc.swiggy-clone-vpc.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.nat["single"].id : aws_nat_gateway.nat[local.private_to_nat_map[each.key]].id
    }
  }

  tags = {
    Name = "${var.project_name}-private-rt-${each.key}"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = var.single_nat_gateway ? aws_route_table.private["single"].id : aws_route_table.private[each.key].id
}

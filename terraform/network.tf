# Production VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Public subnets
resource "aws_subnet" "public_subnet_1" {
  cidr_block        = var.public_subnet_1_cidr
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zones[0]
}
resource "aws_subnet" "public_subnet_2" {
  cidr_block        = var.public_subnet_2_cidr
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zones[1]
}

# Private subnets
resource "aws_subnet" "private_subnet_1" {
  cidr_block        = var.private_subnet_1_cidr
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zones[0]
}

resource "aws_subnet" "private_subnet_2" {
  cidr_block        = var.private_subnet_2_cidr
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.availability_zones[1]
}

# Route tables for the subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
}
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
}

# Associate the newly created route tables to the subnets
resource "aws_route_table_association" "public_route_1_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet_1.id
}
resource "aws_route_table_association" "public_route_2_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet_2.id
}
resource "aws_route_table_association" "private_route_1_association" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet_1.id
}
resource "aws_route_table_association" "private_route_2_association" {
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet_2.id
}

# Elastic IP
resource "aws_eip" "nat_gateway_elastic_ip" {
  vpc                       = true
  associate_with_private_ip = "10.0.0.5"
  depends_on                = [aws_internet_gateway.internet_gateway]
}

# NAT gateway
resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.nat_gateway_elastic_ip.id
  subnet_id     = aws_subnet.public_subnet_1.id
  depends_on    = [aws_eip.nat_gateway_elastic_ip]
}
resource "aws_route" "nat_gateway_route" {
  route_table_id         = aws_route_table.private_route_table.id
  nat_gateway_id         = aws_nat_gateway.nat-gateway.id
  destination_cidr_block = "0.0.0.0/0"
}

# Internet Gateway for the public subnet
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
}

# Route the public subnet traffic through the Internet Gateway
resource "aws_route" "public_internet_gateway_route" {
  route_table_id         = aws_route_table.public_route_table.id
  gateway_id             = aws_internet_gateway.internet_gateway.id
  destination_cidr_block = "0.0.0.0/0"
}


#######################
# VPC Endpoint for SSM
#######################
data "aws_vpc_endpoint_service" "ssm" {
  service = "ssm"
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id             = aws_vpc.vpc.id
  service_name       = data.aws_vpc_endpoint_service.ssm.service_name
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.ecs_secuirity_group.id]
  subnet_ids         = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
}

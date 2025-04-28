########################################
# VPC
########################################

resource "aws_vpc" "vpc_internship_dinh" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc_internship_dinh"
  }
}

########################################
# Subnets
########################################

# Public Subnets
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.vpc_internship_dinh.id
  cidr_block              = var.public_subnet_cidr_a
  availability_zone       = var.availability_zone_a
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_internship_dinh_a"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.vpc_internship_dinh.id
  cidr_block              = var.public_subnet_cidr_b
  availability_zone       = var.availability_zone_b
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_internship_dinh_b"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.vpc_internship_dinh.id
  cidr_block        = var.private_subnet_cidr_a
  availability_zone = var.availability_zone_a

  tags = {
    Name = "private_subnet_internship_dinh_a"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.vpc_internship_dinh.id
  cidr_block        = var.private_subnet_cidr_b
  availability_zone = var.availability_zone_b

  tags = {
    Name = "private_subnet_internship_dinh_b"
  }
}

########################################
# Internet Gateway
########################################

resource "aws_internet_gateway" "igw_internship_dinh" {
  vpc_id = aws_vpc.vpc_internship_dinh.id

  tags = {
    Name = "igw_internship_dinh"
  }
}

########################################
# NAT Gateway (only one, in public subnet A)
########################################

resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "nat_eip_internship_dinh"
  }
}

resource "aws_nat_gateway" "nat_internship_dinh" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_a.id

  tags = {
    Name = "nat_gateway_internship_dinh"
  }
}

########################################
# Route Tables and Associations
########################################

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc_internship_dinh.id

  tags = {
    Name = "public_rt_internship_dinh"
  }
}

resource "aws_route" "public_rt_default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_internship_dinh.id
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}

# Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc_internship_dinh.id

  tags = {
    Name = "private_rt_internship_dinh"
  }
}

resource "aws_route" "private_rt_default_route" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_internship_dinh.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_rt.id
}

########################################
# Security Groups
########################################

# ALB Security Group
resource "aws_security_group" "alb_internship_dinh" {
  name        = "sg_alb_internship_dinh"
  description = "Allow HTTP inbound from the world"
  vpc_id      = aws_vpc.vpc_internship_dinh.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_alb_internship_dinh"
  }
}

# EC2 Web Security Group
resource "aws_security_group" "web_internship_dinh" {
  name        = "sg_web_internship_dinh"
  description = "Allow HTTP only from ALB"
  vpc_id      = aws_vpc.vpc_internship_dinh.id

  ingress {
    description              = "Allow HTTP from ALB"
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    security_groups          = [aws_security_group.alb_internship_dinh.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_web_internship_dinh"
  }
}

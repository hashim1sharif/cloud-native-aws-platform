# Creates the VPC for the project environment
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

# Creates public subnet 1
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 0)
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${var.name_prefix}-public-subnet-1"
  }
}

# Creates public subnet 2
resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "${var.name_prefix}-public-subnet-2"
  }
}

# Creates private application subnet 1
resource "aws_subnet" "private_app_subnet_1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 10)
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${var.name_prefix}-private-app-subnet-1"
  }
}

# Creates private application subnet 2
resource "aws_subnet" "private_app_subnet_2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 11)
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "${var.name_prefix}-private-app-subnet-2"
  }
}

# Creates private database subnet 1
resource "aws_subnet" "private_db_subnet_1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 20)
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${var.name_prefix}-private-db-subnet-1"
  }
}

# Creates private database subnet 2
resource "aws_subnet" "private_db_subnet_2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 21)
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "${var.name_prefix}-private-db-subnet-2"
  }
}

# Creates an Internet Gateway for the VPC
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.name_prefix}-internet-gateway"
  }
}

# Creates an Elastic IP for the NAT Gateway
resource "aws_eip" "elastic_ip" {
  domain = "vpc"

  tags = {
    Name = "${var.name_prefix}-nat-elastic-ip"
  }
}

# Creates the NAT Gateway in public subnet 1
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = aws_subnet.public_subnet_1.id

  depends_on = [
    aws_internet_gateway.internet_gateway
  ]

  tags = {
    Name = "${var.name_prefix}-nat-gateway"
  }
}

# Creates the public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "${var.name_prefix}-public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_1_route_table_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_route_table_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Creates the private application route table
resource "aws_route_table" "private_app_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "${var.name_prefix}-private-app-route-table"
  }
}

resource "aws_route_table_association" "private_app_subnet_1_route_table_association" {
  subnet_id      = aws_subnet.private_app_subnet_1.id
  route_table_id = aws_route_table.private_app_route_table.id
}

resource "aws_route_table_association" "private_app_subnet_2_route_table_association" {
  subnet_id      = aws_subnet.private_app_subnet_2.id
  route_table_id = aws_route_table.private_app_route_table.id
}

# Creates the isolated private database route table
resource "aws_route_table" "private_db_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.name_prefix}-private-db-route-table"
  }
}

resource "aws_route_table_association" "private_db_subnet_1_route_table_association" {
  subnet_id      = aws_subnet.private_db_subnet_1.id
  route_table_id = aws_route_table.private_db_route_table.id
}

resource "aws_route_table_association" "private_db_subnet_2_route_table_association" {
  subnet_id      = aws_subnet.private_db_subnet_2.id
  route_table_id = aws_route_table.private_db_route_table.id
}

# creating a VPC for the project environment


data "aws_availability_zones" "availability_zones" {
  state = "available"

}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.project_environment_name}-vpc"
  }
}

# creating an internet gateway for the VPC
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${local.project_environment_name}-internet-gateway"
  }
}


# creating an subnets for the VPC
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 0)
  availability_zone = data.aws_availability_zones.availability_zones.names[0]

  tags = {
    Name = "${local.project_environment_name}-public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone = data.aws_availability_zones.availability_zones.names[1]

  tags = {
    Name = "${local.project_environment_name}-public-subnet-2"
  }
}

resource "aws_subnet" "private_app_subnet_1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 10)
  availability_zone = data.aws_availability_zones.availability_zones.names[0]

  tags = {
    Name = "${local.project_environment_name}-private-app-subnet-1"
  }
}

resource "aws_subnet" "private_app_subnet_2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 11)
  availability_zone = data.aws_availability_zones.availability_zones.names[1]

  tags = {
    Name = "${local.project_environment_name}-private-app-subnet-2"
  }
}

resource "aws_subnet" "private_db_subnet_1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 20)
  availability_zone = data.aws_availability_zones.availability_zones.names[0]

  tags = {
    Name = "${local.project_environment_name}-private-db-subnet-1"
  }
}

resource "aws_subnet" "private_db_subnet_2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 21)
  availability_zone = data.aws_availability_zones.availability_zones.names[1]

  tags = {
    Name = "${local.project_environment_name}-private-db-subnet-2"
  }
}

# creating a route table for the public subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "${local.project_environment_name}-public-route-table"
  }
}

# associating the public subnet1 with the public route table
resource "aws_route_table_association" "public_subnet_1_route_table_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

# associating the public subnet2 with the public route table
resource "aws_route_table_association" "public_subnet_2_route_table_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}
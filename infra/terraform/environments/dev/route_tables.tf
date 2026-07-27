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


# Creating a route table for the private application subnets
resource "aws_route_table" "private_app_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "${local.project_environment_name}-private-app-route-table"
  }
}

# Associating private application subnet 1 with the private route table
resource "aws_route_table_association" "private_app_subnet_1_route_table_association" {
  subnet_id      = aws_subnet.private_app_subnet_1.id
  route_table_id = aws_route_table.private_app_route_table.id
}

# Associating private application subnet 2 with the private route table
resource "aws_route_table_association" "private_app_subnet_2_route_table_association" {
  subnet_id      = aws_subnet.private_app_subnet_2.id
  route_table_id = aws_route_table.private_app_route_table.id
}

# Creating an isolated route table for the private database subnets
resource "aws_route_table" "private_db_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${local.project_environment_name}-private-db-route-table"
  }
}

# Associating private database subnet 1 with the database route table
resource "aws_route_table_association" "private_db_subnet_1_route_table_association" {
  subnet_id      = aws_subnet.private_db_subnet_1.id
  route_table_id = aws_route_table.private_db_route_table.id
}

# Associating private database subnet 2 with the database route table
resource "aws_route_table_association" "private_db_subnet_2_route_table_association" {
  subnet_id      = aws_subnet.private_db_subnet_2.id
  route_table_id = aws_route_table.private_db_route_table.id
}
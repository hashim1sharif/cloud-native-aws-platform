resource "aws_eip" "elastic_ip" {
  domain = "vpc"

  tags = {
    Name = "${local.project_environment_name}-nat-elastic-ip"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = aws_subnet.public_subnet_1.id

  depends_on = [
    aws_internet_gateway.internet_gateway
  ]

  tags = {
    Name = "${local.project_environment_name}-nat-gateway"
  }
}
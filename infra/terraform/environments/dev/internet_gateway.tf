# creating an internet gateway for the VPC
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${local.project_environment_name}-internet-gateway"
  }
}

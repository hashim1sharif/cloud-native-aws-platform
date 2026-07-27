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
output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]
}

output "private_app_subnet_ids" {
  description = "IDs of the private application subnets."
  value = [
    aws_subnet.private_app_subnet_1.id,
    aws_subnet.private_app_subnet_2.id
  ]
}

output "private_db_subnet_ids" {
  description = "IDs of the private database subnets."
  value = [
    aws_subnet.private_db_subnet_1.id,
    aws_subnet.private_db_subnet_2.id
  ]
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway."
  value       = aws_internet_gateway.internet_gateway.id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway."
  value       = aws_nat_gateway.nat_gateway.id
}

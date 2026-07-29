moved {
  from = aws_vpc.vpc
  to   = module.network.aws_vpc.vpc
}

moved {
  from = aws_subnet.public_subnet_1
  to   = module.network.aws_subnet.public_subnet_1
}

moved {
  from = aws_subnet.public_subnet_2
  to   = module.network.aws_subnet.public_subnet_2
}

moved {
  from = aws_subnet.private_app_subnet_1
  to   = module.network.aws_subnet.private_app_subnet_1
}

moved {
  from = aws_subnet.private_app_subnet_2
  to   = module.network.aws_subnet.private_app_subnet_2
}

moved {
  from = aws_subnet.private_db_subnet_1
  to   = module.network.aws_subnet.private_db_subnet_1
}

moved {
  from = aws_subnet.private_db_subnet_2
  to   = module.network.aws_subnet.private_db_subnet_2
}

moved {
  from = aws_internet_gateway.internet_gateway
  to   = module.network.aws_internet_gateway.internet_gateway
}

moved {
  from = aws_eip.elastic_ip
  to   = module.network.aws_eip.elastic_ip
}

moved {
  from = aws_nat_gateway.nat_gateway
  to   = module.network.aws_nat_gateway.nat_gateway
}

moved {
  from = aws_route_table.public_route_table
  to   = module.network.aws_route_table.public_route_table
}

moved {
  from = aws_route_table.private_app_route_table
  to   = module.network.aws_route_table.private_app_route_table
}

moved {
  from = aws_route_table.private_db_route_table
  to   = module.network.aws_route_table.private_db_route_table
}

moved {
  from = aws_route_table_association.public_subnet_1_route_table_association
  to   = module.network.aws_route_table_association.public_subnet_1_route_table_association
}

moved {
  from = aws_route_table_association.public_subnet_2_route_table_association
  to   = module.network.aws_route_table_association.public_subnet_2_route_table_association
}

moved {
  from = aws_route_table_association.private_app_subnet_1_route_table_association
  to   = module.network.aws_route_table_association.private_app_subnet_1_route_table_association
}

moved {
  from = aws_route_table_association.private_app_subnet_2_route_table_association
  to   = module.network.aws_route_table_association.private_app_subnet_2_route_table_association
}

moved {
  from = aws_route_table_association.private_db_subnet_1_route_table_association
  to   = module.network.aws_route_table_association.private_db_subnet_1_route_table_association
}

moved {
  from = aws_route_table_association.private_db_subnet_2_route_table_association
  to   = module.network.aws_route_table_association.private_db_subnet_2_route_table_association
}

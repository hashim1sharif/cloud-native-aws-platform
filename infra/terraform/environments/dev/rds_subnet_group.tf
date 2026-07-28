# Defines the private subnets available to the RDS database
resource "aws_db_subnet_group" "db_subnet_group" {
  name = "${local.project_environment_name}-db-subnet-group"

  subnet_ids = [
    aws_subnet.private_db_subnet_1.id,
    aws_subnet.private_db_subnet_2.id
  ]
}
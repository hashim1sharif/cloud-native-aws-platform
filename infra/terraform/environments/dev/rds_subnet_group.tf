# Defines the private subnets available to the RDS database
resource "aws_db_subnet_group" "db_subnet_group" {
  name = "${local.project_environment_name}-db-subnet-group"

  subnet_ids = [
    module.network.private_db_subnet_ids[0],
    module.network.private_db_subnet_ids[1]
  ]
}
# Defines the private subnets available to the RDS database
resource "aws_db_subnet_group" "db_subnet_group" {
  name = "${var.name_prefix}-db-subnet-group"

  subnet_ids = var.private_db_subnet_ids
}

# Creates the private PostgreSQL database for the application
resource "aws_db_instance" "postgres_db_instance" {
  identifier = "${var.name_prefix}-postgres"

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  storage_encrypted = var.storage_encrypted

  db_name  = var.database_name
  username = var.master_username

  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [var.database_security_group_id]
  publicly_accessible    = var.publicly_accessible

  skip_final_snapshot = var.skip_final_snapshot
}

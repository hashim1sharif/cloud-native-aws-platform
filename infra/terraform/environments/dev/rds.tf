# Creates the private PostgreSQL database for the application
resource "aws_db_instance" "postgres_db_instance" {
  identifier = "${local.project_environment_name}-postgres"

  engine         = "postgres"
  engine_version = "16"
  instance_class = "db.t4g.micro"

  allocated_storage = 20
  storage_encrypted = true

  db_name  = "devops_tasks"
  username = "postgres"

  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [module.security.database_security_group_id]
  publicly_accessible    = false

  skip_final_snapshot = true
}
module "rds" {
  source = "../../modules/rds"

  name_prefix                = local.project_environment_name
  private_db_subnet_ids      = module.network.private_db_subnet_ids
  database_security_group_id = module.security.database_security_group_id

  engine              = "postgres"
  engine_version      = "16"
  instance_class      = "db.t4g.micro"
  allocated_storage   = 20
  storage_encrypted   = true
  database_name       = "devops_tasks"
  master_username     = "postgres"
  publicly_accessible = false
  skip_final_snapshot = true
}

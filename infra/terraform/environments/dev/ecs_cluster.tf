module "ecs" {
  source = "../../modules/ecs"

  name_prefix         = local.project_environment_name
  aws_region          = var.aws_region
  container_image_tag = var.container_image_tag

  frontend_repository_url = module.ecr.frontend_repository_url
  backend_repository_url  = module.ecr.backend_repository_url

  private_app_subnet_ids     = module.network.private_app_subnet_ids
  frontend_security_group_id = module.security.frontend_security_group_id
  backend_security_group_id  = module.security.backend_security_group_id

  frontend_target_group_arn = module.alb.frontend_target_group_arn
  backend_target_group_arn  = module.alb.backend_target_group_arn
  load_balancer_dns_name    = "https://${local.application_domain_name}"

  database_address       = module.rds.database_address
  database_port          = module.rds.database_port
  database_name          = module.rds.database_name
  master_user_secret_arn = module.rds.master_user_secret_arn

  depends_on = [
    module.alb
  ]
}

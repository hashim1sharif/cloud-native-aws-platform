# Network

module "network" {
  source = "../../modules/network"

  name_prefix        = local.project_environment_name
  vpc_cidr           = var.vpc_cidr
  availability_zones = data.aws_availability_zones.availability_zones.names
}


# Security groups

module "security" {
  source = "../../modules/security"

  name_prefix = local.project_environment_name
  vpc_id      = module.network.vpc_id
}


# Container repositories

module "ecr" {
  source = "../../modules/ecr"

  name_prefix                    = local.project_environment_name
  untagged_image_expiration_days = 14
}


# Database

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


# TLS certificate

module "acm" {
  source = "../../modules/acm"

  domain_name    = local.application_domain_name
  hosted_zone_id = data.aws_route53_zone.primary_hosted_zone.zone_id
  tags           = local.common_tags
}


# Application Load Balancer

module "alb" {
  source = "../../modules/alb"

  name_prefix           = local.project_environment_name
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  certificate_arn       = module.acm.certificate_arn
}


# ECS cluster and services

module "ecs" {
  source = "../../modules/ecs"

  name_prefix = local.project_environment_name
  aws_region  = var.aws_region

  frontend_image_tag = var.frontend_image_tag
  backend_image_tag  = var.backend_image_tag

  frontend_repository_url = module.ecr.frontend_repository_url
  backend_repository_url  = module.ecr.backend_repository_url

  public_subnet_ids          = module.network.public_subnet_ids
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


# DNS

module "route53" {
  source = "../../modules/route53"

  hosted_zone_id         = data.aws_route53_zone.primary_hosted_zone.zone_id
  domain_name            = local.application_domain_name
  load_balancer_dns_name = module.alb.load_balancer_dns_name
  load_balancer_zone_id  = module.alb.load_balancer_zone_id
}
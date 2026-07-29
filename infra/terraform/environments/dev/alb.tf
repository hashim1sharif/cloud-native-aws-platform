module "alb" {
  source = "../../modules/alb"

  name_prefix           = local.project_environment_name
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  certificate_arn       = module.acm.certificate_arn
}

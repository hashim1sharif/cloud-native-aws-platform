module "security" {
  source = "../../modules/security"

  name_prefix = local.project_environment_name
  vpc_id      = module.network.vpc_id
}

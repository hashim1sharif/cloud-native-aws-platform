module "ecr" {
  source = "../../modules/ecr"

  name_prefix                    = local.project_environment_name
  untagged_image_expiration_days = 14
}

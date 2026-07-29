module "network" {
  source = "../../modules/network"

  name_prefix        = local.project_environment_name
  vpc_cidr           = var.vpc_cidr
  availability_zones = data.aws_availability_zones.availability_zones.names
}

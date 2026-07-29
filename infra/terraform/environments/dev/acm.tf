module "acm" {
  source = "../../modules/acm"

  domain_name    = local.application_domain_name
  hosted_zone_id = data.aws_route53_zone.primary_hosted_zone.zone_id
  tags           = local.common_tags
}

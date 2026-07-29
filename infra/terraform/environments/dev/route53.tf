module "route53" {
  source = "../../modules/route53"

  hosted_zone_id         = data.aws_route53_zone.primary_hosted_zone.zone_id
  domain_name            = local.application_domain_name
  load_balancer_dns_name = module.alb.load_balancer_dns_name
  load_balancer_zone_id  = module.alb.load_balancer_zone_id
}

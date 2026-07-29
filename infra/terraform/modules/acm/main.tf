# Requests a public TLS certificate for the application domain
resource "aws_acm_certificate" "application_certificate" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# Creates the DNS record required by ACM to validate the certificate
resource "aws_route53_record" "certificate_validation_record" {
  for_each = {
    for validation_option in aws_acm_certificate.application_certificate.domain_validation_options :
    validation_option.domain_name => {
      name   = validation_option.resource_record_name
      type   = validation_option.resource_record_type
      record = validation_option.resource_record_value
    }
  }

  zone_id = var.hosted_zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

# Waits until ACM confirms that DNS validation has succeeded
resource "aws_acm_certificate_validation" "application_certificate_validation" {
  certificate_arn = aws_acm_certificate.application_certificate.arn

  validation_record_fqdns = [
    for validation_record in aws_route53_record.certificate_validation_record :
    validation_record.fqdn
  ]
}

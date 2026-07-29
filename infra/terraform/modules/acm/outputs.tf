output "certificate_arn" {
  description = "ARN of the validated ACM certificate."
  value       = aws_acm_certificate_validation.application_certificate_validation.certificate_arn
}

output "certificate_domain_name" {
  description = "Domain name protected by the ACM certificate."
  value       = aws_acm_certificate.application_certificate.domain_name
}

output "validation_record_fqdns" {
  description = "DNS records used to validate the ACM certificate."
  value = [
    for validation_record in aws_route53_record.certificate_validation_record :
    validation_record.fqdn
  ]
}

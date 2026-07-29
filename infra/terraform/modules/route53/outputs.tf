output "application_domain_name" {
  description = "Domain name pointing to the Application Load Balancer."
  value       = aws_route53_record.application_alias_record.fqdn
}

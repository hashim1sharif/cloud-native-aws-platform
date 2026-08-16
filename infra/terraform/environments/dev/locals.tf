locals {
  project_environment_name = "${var.project_name}-${var.environment}"
  application_domain_name  = "${var.application_subdomain}.${var.hosted_zone_name}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Repository  = "cloud-native-aws-platform"
  }
}

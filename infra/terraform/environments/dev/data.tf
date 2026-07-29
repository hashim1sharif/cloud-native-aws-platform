data "aws_availability_zones" "availability_zones" {
  state = "available"
}
# Reads the existing public Route 53 hosted zone
data "aws_route53_zone" "primary_hosted_zone" {
  name         = var.hosted_zone_name
  private_zone = false
}

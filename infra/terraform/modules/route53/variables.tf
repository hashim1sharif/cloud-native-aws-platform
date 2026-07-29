variable "hosted_zone_id" {
  description = "ID of the existing Route 53 hosted zone."
  type        = string

  validation {
    condition     = trimspace(var.hosted_zone_id) != ""
    error_message = "The hosted zone ID must not be empty."
  }
}

variable "domain_name" {
  description = "Fully qualified domain name for the application."
  type        = string

  validation {
    condition     = trimspace(var.domain_name) != ""
    error_message = "The domain name must not be empty."
  }
}

variable "load_balancer_dns_name" {
  description = "DNS name of the Application Load Balancer."
  type        = string

  validation {
    condition     = trimspace(var.load_balancer_dns_name) != ""
    error_message = "The load balancer DNS name must not be empty."
  }
}

variable "load_balancer_zone_id" {
  description = "Route 53 hosted zone ID of the Application Load Balancer."
  type        = string

  validation {
    condition     = trimspace(var.load_balancer_zone_id) != ""
    error_message = "The load balancer zone ID must not be empty."
  }
}

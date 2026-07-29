variable "domain_name" {
  description = "Fully qualified domain name protected by the ACM certificate."
  type        = string

  validation {
    condition     = trimspace(var.domain_name) != ""
    error_message = "The domain name must not be empty."
  }
}

variable "hosted_zone_id" {
  description = "ID of the Route 53 hosted zone used for DNS validation."
  type        = string

  validation {
    condition     = trimspace(var.hosted_zone_id) != ""
    error_message = "The hosted zone ID must not be empty."
  }
}

variable "tags" {
  description = "Tags applied to the ACM certificate."
  type        = map(string)
  default     = {}
}

variable "name_prefix" {
  description = "Name prefix used for the ECR repositories."
  type        = string

  validation {
    condition     = trimspace(var.name_prefix) != ""
    error_message = "The name prefix must not be empty."
  }
}

variable "untagged_image_expiration_days" {
  description = "Number of days before untagged container images are removed."
  type        = number
  default     = 14

  validation {
    condition     = var.untagged_image_expiration_days > 0
    error_message = "The expiration period must be greater than zero."
  }
}

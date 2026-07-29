variable "name_prefix" {
  description = "Name prefix used for all security resources."
  type        = string

  validation {
    condition     = trimspace(var.name_prefix) != ""
    error_message = "The name prefix must not be empty."
  }
}

variable "vpc_id" {
  description = "ID of the VPC where the security groups are created."
  type        = string

  validation {
    condition     = trimspace(var.vpc_id) != ""
    error_message = "The VPC ID must not be empty."
  }
}

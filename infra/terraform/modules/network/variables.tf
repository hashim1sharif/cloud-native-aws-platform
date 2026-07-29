variable "name_prefix" {
  description = "Name prefix used for all network resources."
  type        = string

  validation {
    condition     = trimspace(var.name_prefix) != ""
    error_message = "The name prefix must not be empty."
  }
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block assigned to the VPC."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "The VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "Availability Zones used for the network subnets."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least two Availability Zones must be provided."
  }
}

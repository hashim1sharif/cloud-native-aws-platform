variable "aws_account_id" {
  type = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "The AWS account ID must contain exactly 12 digits."
  }
}

variable "aws_region" {
  type = string

  validation {
    condition     = trimspace(var.aws_region) != ""
    error_message = "The AWS Region must not be empty."
  }
}

variable "environment" {
  type = string

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "The environment must be dev, test, or prod."
  }
}

variable "project_name" {
  type = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "The project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "vpc_cidr" {
  type = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "The VPC CIDR must be a valid IPv4 CIDR block."
  }
}
variable "container_image_tag" {
  type = string

  validation {
    condition     = trimspace(var.container_image_tag) != ""
    error_message = "The container image tag must not be empty."
  }
}
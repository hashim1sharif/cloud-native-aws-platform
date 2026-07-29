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
variable "frontend_image_tag" {
  description = "Container image tag deployed by the frontend ECS service."
  type        = string

  validation {
    condition     = trimspace(var.frontend_image_tag) != ""
    error_message = "The frontend image tag must not be empty."
  }
}

variable "backend_image_tag" {
  description = "Container image tag deployed by the backend ECS service."
  type        = string

  validation {
    condition     = trimspace(var.backend_image_tag) != ""
    error_message = "The backend image tag must not be empty."
  }
}
variable "hosted_zone_name" {
  description = "Name of the existing public Route 53 hosted zone."
  type        = string

  validation {
    condition     = trimspace(var.hosted_zone_name) != ""
    error_message = "The hosted zone name must not be empty."
  }
}

variable "application_subdomain" {
  description = "Subdomain used by the task management application."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.application_subdomain))
    error_message = "The application subdomain may contain only lowercase letters, numbers and hyphens."
  }
}

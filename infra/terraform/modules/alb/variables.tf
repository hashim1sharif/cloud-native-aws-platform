variable "name_prefix" {
  description = "Name prefix used for the ALB resources."
  type        = string

  validation {
    condition     = trimspace(var.name_prefix) != ""
    error_message = "The name prefix must not be empty."
  }
}

variable "vpc_id" {
  description = "ID of the VPC where the target groups are created."
  type        = string

  validation {
    condition     = trimspace(var.vpc_id) != ""
    error_message = "The VPC ID must not be empty."
  }
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets used by the Application Load Balancer."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "At least two public subnet IDs must be provided."
  }
}

variable "alb_security_group_id" {
  description = "ID of the security group attached to the Application Load Balancer."
  type        = string

  validation {
    condition     = trimspace(var.alb_security_group_id) != ""
    error_message = "The ALB security group ID must not be empty."
  }
}

variable "certificate_arn" {
  description = "ARN of the validated ACM certificate used by the HTTPS listener."
  type        = string

  validation {
    condition     = trimspace(var.certificate_arn) != ""
    error_message = "The ACM certificate ARN must not be empty."
  }
}

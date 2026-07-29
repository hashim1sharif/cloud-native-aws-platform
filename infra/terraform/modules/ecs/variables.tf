variable "name_prefix" {
  description = "Name prefix used for ECS, IAM and CloudWatch resources."
  type        = string

  validation {
    condition     = trimspace(var.name_prefix) != ""
    error_message = "The name prefix must not be empty."
  }
}

variable "aws_region" {
  description = "AWS Region used by the CloudWatch log configuration."
  type        = string

  validation {
    condition     = trimspace(var.aws_region) != ""
    error_message = "The AWS Region must not be empty."
  }
}

variable "frontend_image_tag" {
  description = "Container image tag used by the frontend ECS task."
  type        = string

  validation {
    condition     = trimspace(var.frontend_image_tag) != ""
    error_message = "The frontend image tag must not be empty."
  }
}

variable "backend_image_tag" {
  description = "Container image tag used by the backend ECS task."
  type        = string

  validation {
    condition     = trimspace(var.backend_image_tag) != ""
    error_message = "The backend image tag must not be empty."
  }
}

variable "frontend_repository_url" {
  description = "URL of the frontend ECR repository."
  type        = string

  validation {
    condition     = trimspace(var.frontend_repository_url) != ""
    error_message = "The frontend repository URL must not be empty."
  }
}

variable "backend_repository_url" {
  description = "URL of the backend ECR repository."
  type        = string

  validation {
    condition     = trimspace(var.backend_repository_url) != ""
    error_message = "The backend repository URL must not be empty."
  }
}

variable "private_app_subnet_ids" {
  description = "IDs of the private application subnets used by ECS services."
  type        = list(string)

  validation {
    condition     = length(var.private_app_subnet_ids) >= 2
    error_message = "At least two private application subnet IDs must be provided."
  }
}

variable "frontend_security_group_id" {
  description = "ID of the frontend ECS security group."
  type        = string

  validation {
    condition     = trimspace(var.frontend_security_group_id) != ""
    error_message = "The frontend security group ID must not be empty."
  }
}

variable "backend_security_group_id" {
  description = "ID of the backend ECS security group."
  type        = string

  validation {
    condition     = trimspace(var.backend_security_group_id) != ""
    error_message = "The backend security group ID must not be empty."
  }
}

variable "frontend_target_group_arn" {
  description = "ARN of the frontend ALB target group."
  type        = string

  validation {
    condition     = trimspace(var.frontend_target_group_arn) != ""
    error_message = "The frontend target group ARN must not be empty."
  }
}

variable "backend_target_group_arn" {
  description = "ARN of the backend ALB target group."
  type        = string

  validation {
    condition     = trimspace(var.backend_target_group_arn) != ""
    error_message = "The backend target group ARN must not be empty."
  }
}

variable "load_balancer_dns_name" {
  description = "Allowed browser origin for backend CORS requests."
  type        = string

  validation {
    condition     = can(regex("^https?://", var.load_balancer_dns_name))
    error_message = "The CORS origin must begin with http:// or https://."
  }
}

variable "database_address" {
  description = "DNS address of the PostgreSQL database."
  type        = string

  validation {
    condition     = trimspace(var.database_address) != ""
    error_message = "The database address must not be empty."
  }
}

variable "database_port" {
  description = "Port used by the PostgreSQL database."
  type        = number

  validation {
    condition     = var.database_port > 0 && var.database_port <= 65535
    error_message = "The database port must be between 1 and 65535."
  }
}

variable "database_name" {
  description = "Name of the PostgreSQL database."
  type        = string

  validation {
    condition     = trimspace(var.database_name) != ""
    error_message = "The database name must not be empty."
  }
}

variable "master_user_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the database credentials."
  type        = string

  validation {
    condition     = trimspace(var.master_user_secret_arn) != ""
    error_message = "The master user secret ARN must not be empty."
  }
}

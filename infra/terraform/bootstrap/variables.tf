variable "aws_account_id" {
  type = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "The AWS account ID must contain exactly 12 digits."
  }
}

variable "aws_region" {
  type = string
}

variable "state_bucket_name" {
  type = string
}

variable "github_oidc_subject" {
  type = string

  validation {
    condition     = trimspace(var.github_oidc_subject) != ""
    error_message = "The GitHub OIDC subject must not be empty."
  }
}
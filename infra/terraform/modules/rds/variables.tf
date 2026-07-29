variable "name_prefix" {
  description = "Name prefix used for the RDS resources."
  type        = string

  validation {
    condition     = trimspace(var.name_prefix) != ""
    error_message = "The name prefix must not be empty."
  }
}

variable "private_db_subnet_ids" {
  description = "IDs of the private subnets used by the RDS subnet group."
  type        = list(string)

  validation {
    condition     = length(var.private_db_subnet_ids) >= 2
    error_message = "At least two private database subnet IDs must be provided."
  }
}

variable "database_security_group_id" {
  description = "ID of the security group attached to the RDS database."
  type        = string

  validation {
    condition     = trimspace(var.database_security_group_id) != ""
    error_message = "The database security group ID must not be empty."
  }
}

variable "engine" {
  description = "Database engine used by the RDS instance."
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "PostgreSQL engine version."
  type        = string
  default     = "16"
}

variable "instance_class" {
  description = "Instance class used by the RDS database."
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "Storage allocated to the database in GiB."
  type        = number
  default     = 20

  validation {
    condition     = var.allocated_storage > 0
    error_message = "Allocated storage must be greater than zero."
  }
}

variable "storage_encrypted" {
  description = "Whether the RDS storage is encrypted."
  type        = bool
  default     = true
}

variable "database_name" {
  description = "Name of the initial PostgreSQL database."
  type        = string
  default     = "devops_tasks"

  validation {
    condition     = trimspace(var.database_name) != ""
    error_message = "The database name must not be empty."
  }
}

variable "master_username" {
  description = "Master username for the PostgreSQL database."
  type        = string
  default     = "postgres"

  validation {
    condition     = trimspace(var.master_username) != ""
    error_message = "The master username must not be empty."
  }
}

variable "publicly_accessible" {
  description = "Whether the RDS database is publicly accessible."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Whether Terraform skips the final snapshot when deleting the database."
  type        = bool
  default     = true
}

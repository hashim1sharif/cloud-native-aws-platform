output "database_address" {
  description = "DNS address of the PostgreSQL database."
  value       = aws_db_instance.postgres_db_instance.address
}

output "database_port" {
  description = "Port used by the PostgreSQL database."
  value       = aws_db_instance.postgres_db_instance.port
}

output "database_name" {
  description = "Name of the initial PostgreSQL database."
  value       = aws_db_instance.postgres_db_instance.db_name
}

output "master_user_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret containing the database credentials."
  value       = aws_db_instance.postgres_db_instance.master_user_secret[0].secret_arn
}

output "database_instance_id" {
  description = "ID of the RDS database instance."
  value       = aws_db_instance.postgres_db_instance.id
}

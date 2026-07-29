output "alb_security_group_id" {
  description = "ID of the Application Load Balancer security group."
  value       = aws_security_group.alb_security_group.id
}

output "frontend_security_group_id" {
  description = "ID of the frontend ECS service security group."
  value       = aws_security_group.frontend_security_group.id
}

output "backend_security_group_id" {
  description = "ID of the backend ECS service security group."
  value       = aws_security_group.backend_security_group.id
}

output "database_security_group_id" {
  description = "ID of the database security group."
  value       = aws_security_group.database_security_group.id
}

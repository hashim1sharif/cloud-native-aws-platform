output "frontend_repository_url" {
  description = "URL of the frontend ECR repository."
  value       = aws_ecr_repository.frontend_ecr_repository.repository_url
}

output "backend_repository_url" {
  description = "URL of the backend ECR repository."
  value       = aws_ecr_repository.backend_ecr_repository.repository_url
}

output "frontend_repository_name" {
  description = "Name of the frontend ECR repository."
  value       = aws_ecr_repository.frontend_ecr_repository.name
}

output "backend_repository_name" {
  description = "Name of the backend ECR repository."
  value       = aws_ecr_repository.backend_ecr_repository.name
}

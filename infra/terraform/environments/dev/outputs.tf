output "frontend_repository_url" {
  value = module.ecr.frontend_repository_url
}

output "backend_repository_url" {
  value = module.ecr.backend_repository_url
}

output "frontend_repository_name" {
  value = module.ecr.frontend_repository_name
}

output "backend_repository_name" {
  value = module.ecr.backend_repository_name
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "frontend_service_name" {
  value = module.ecs.frontend_service_name
}

output "backend_service_name" {
  value = module.ecs.backend_service_name
}

output "application_url" {
  value = "https://${local.application_domain_name}"
}

output "github_actions_deploy_role_arn" {
  value = aws_iam_role.github_actions_deploy.arn
}

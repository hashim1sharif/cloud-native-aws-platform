# Stores logs from the frontend ECS service
resource "aws_cloudwatch_log_group" "frontend_log_group" {
  name              = "/ecs/${local.project_environment_name}/frontend"
  retention_in_days = 14
}

# Stores logs from the backend ECS service
resource "aws_cloudwatch_log_group" "backend_log_group" {
  name              = "/ecs/${local.project_environment_name}/backend"
  retention_in_days = 14
}
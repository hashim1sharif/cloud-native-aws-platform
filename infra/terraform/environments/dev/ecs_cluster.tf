# Provides the ECS cluster where the application containers will run
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${local.project_environment_name}-ecs-cluster"
}
# Runs the frontend container in the private application subnets
resource "aws_ecs_service" "frontend_service" {
  name            = "${local.project_environment_name}-frontend-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.frontend_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  # Gives new tasks time to start before ECS evaluates ALB health checks
  health_check_grace_period_seconds = 60

  network_configuration {
    subnets = [
      module.network.private_app_subnet_ids[0],
      module.network.private_app_subnet_ids[1]
    ]

    security_groups = [
      module.security.frontend_security_group_id
    ]

    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = module.alb.frontend_target_group_arn
    container_name   = "frontend"
    container_port   = 80
  }

  depends_on = [
    module.alb,
    aws_iam_role_policy_attachment.ecs_task_execution_role_policy_attachment
  ]
}

# Runs the backend container in the private application subnets
resource "aws_ecs_service" "backend_service" {
  name            = "${local.project_environment_name}-backend-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.backend_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  # Gives the backend time to retrieve secrets and connect to RDS
  health_check_grace_period_seconds = 60

  network_configuration {
    subnets = [
      module.network.private_app_subnet_ids[0],
      module.network.private_app_subnet_ids[1]
    ]

    security_groups = [
      module.security.backend_security_group_id
    ]

    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = module.alb.backend_target_group_arn
    container_name   = "backend"
    container_port   = 5000
  }

  depends_on = [
    module.alb,
    aws_iam_role_policy_attachment.ecs_task_execution_role_policy_attachment,
    aws_iam_role_policy.ecs_task_execution_secrets_policy
  ]
}
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
      aws_subnet.private_app_subnet_1.id,
      aws_subnet.private_app_subnet_2.id
    ]

    security_groups = [
      aws_security_group.frontend_security_group.id
    ]

    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend_target_group.arn
    container_name   = "frontend"
    container_port   = 80
  }

  depends_on = [
    aws_lb_listener.http_listener,
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
      aws_subnet.private_app_subnet_1.id,
      aws_subnet.private_app_subnet_2.id
    ]

    security_groups = [
      aws_security_group.backend_security_group.id
    ]

    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend_target_group.arn
    container_name   = "backend"
    container_port   = 5000
  }

  depends_on = [
    aws_lb_listener_rule.backend_api_listener_rule,
    aws_iam_role_policy_attachment.ecs_task_execution_role_policy_attachment,
    aws_iam_role_policy.ecs_task_execution_secrets_policy
  ]
}
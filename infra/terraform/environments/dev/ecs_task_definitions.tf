# Defines the Fargate task for the frontend container
resource "aws_ecs_task_definition" "frontend_task_definition" {
  family                   = "${local.project_environment_name}-frontend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = "${aws_ecr_repository.frontend_ecr_repository.repository_url}:${var.container_image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.frontend_log_group.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "frontend"
        }
      }
    }
  ])
}

# Defines the Fargate task for the backend container
resource "aws_ecs_task_definition" "backend_task_definition" {
  family                   = "${local.project_environment_name}-backend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = "${aws_ecr_repository.backend_ecr_repository.repository_url}:${var.container_image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = 5000
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "PORT"
          value = "5000"
        },
        {
          name  = "DB_HOST"
          value = aws_db_instance.postgres_db_instance.address
        },
        {
          name  = "DB_PORT"
          value = tostring(aws_db_instance.postgres_db_instance.port)
        },
        {
          name  = "DB_NAME"
          value = aws_db_instance.postgres_db_instance.db_name
        },
        {
          name  = "CORS_ORIGIN"
          value = "http://${aws_lb.application_load_balancer.dns_name}"
        }
      ]

      secrets = [
        {
          name      = "DB_USER"
          valueFrom = "${aws_db_instance.postgres_db_instance.master_user_secret[0].secret_arn}:username::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${aws_db_instance.postgres_db_instance.master_user_secret[0].secret_arn}:password::"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.backend_log_group.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "backend"
        }
      }
    }
  ])
}
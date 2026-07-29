# Stores logs from the frontend ECS service
resource "aws_cloudwatch_log_group" "frontend_log_group" {
  name              = "/ecs/${var.name_prefix}/frontend"
  retention_in_days = 14
}

# Stores logs from the backend ECS service
resource "aws_cloudwatch_log_group" "backend_log_group" {
  name              = "/ecs/${var.name_prefix}/backend"
  retention_in_days = 14
}

# Provides the ECS cluster where the application containers will run
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.name_prefix}-ecs-cluster"
}

# Allows Amazon ECS tasks to assume the task execution role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.name_prefix}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Gives ECS permission to pull ECR images and send logs to CloudWatch
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Allows ECS to inject the RDS-managed credentials into the backend container
resource "aws_iam_role_policy" "ecs_task_execution_secrets_policy" {
  name = "${var.name_prefix}-ecs-secrets-access"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = [
          var.master_user_secret_arn
        ]
      }
    ]
  })
}

# Defines the Fargate task for the frontend container
resource "aws_ecs_task_definition" "frontend_task_definition" {
  family                   = "${var.name_prefix}-frontend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = "${var.frontend_repository_url}:${var.frontend_image_tag}"
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
  family                   = "${var.name_prefix}-backend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = "${var.backend_repository_url}:${var.backend_image_tag}"
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
          value = var.database_address
        },
        {
          name  = "DB_PORT"
          value = tostring(var.database_port)
        },
        {
          name  = "DB_NAME"
          value = var.database_name
        },
        {
          name  = "DB_SSL"
          value = "true"
        },
        {
          name  = "CORS_ORIGIN"
          value = var.load_balancer_dns_name
        }
      ]

      secrets = [
        {
          name      = "DB_USER"
          valueFrom = "${var.master_user_secret_arn}:username::"
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = "${var.master_user_secret_arn}:password::"
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

# Runs the frontend container in the private application subnets
resource "aws_ecs_service" "frontend_service" {
  name            = "${var.name_prefix}-frontend-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.frontend_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }

  health_check_grace_period_seconds = 60

  network_configuration {
    subnets = var.private_app_subnet_ids

    security_groups = [
      var.frontend_security_group_id
    ]

    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.frontend_target_group_arn
    container_name   = "frontend"
    container_port   = 80
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_task_execution_role_policy_attachment
  ]
}

# Runs the backend container in the private application subnets
resource "aws_ecs_service" "backend_service" {
  name            = "${var.name_prefix}-backend-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.backend_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }

  health_check_grace_period_seconds = 60

  network_configuration {
    subnets = var.private_app_subnet_ids

    security_groups = [
      var.backend_security_group_id
    ]

    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.backend_target_group_arn
    container_name   = "backend"
    container_port   = 5000
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_task_execution_role_policy_attachment,
    aws_iam_role_policy.ecs_task_execution_secrets_policy
  ]
}

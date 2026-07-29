# Provides the public entry point for the application
resource "aws_lb" "application_load_balancer" {
  name               = "${local.project_environment_name}-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb_security_group.id
  ]

  subnets = [
    module.network.public_subnet_ids[0],
    module.network.public_subnet_ids[1]
  ]
}

# Routes frontend traffic to ECS tasks running on port 80
resource "aws_lb_target_group" "frontend_target_group" {
  name        = "${local.project_environment_name}-frontend-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.network.vpc_id

  health_check {
    path    = "/"
    matcher = "200"
  }
}

# Routes API traffic to backend ECS tasks running on port 5000
resource "aws_lb_target_group" "backend_target_group" {
  name        = "${local.project_environment_name}-backend-tg"
  port        = 5000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.network.vpc_id

  health_check {
    path    = "/health"
    matcher = "200"
  }
}

# Listens for public HTTP traffic and sends unmatched requests to the frontend
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_target_group.arn
  }
}

# Sends API requests to the backend target group
resource "aws_lb_listener_rule" "backend_api_listener_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}
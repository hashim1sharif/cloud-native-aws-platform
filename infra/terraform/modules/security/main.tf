# Controls public traffic entering the Application Load Balancer
resource "aws_security_group" "alb_security_group" {
  name        = "${var.name_prefix}-alb-security-group"
  description = "Controls public traffic entering the Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-alb-security-group"
  }
}

# Controls traffic reaching the frontend ECS service
resource "aws_security_group" "frontend_security_group" {
  name        = "${var.name_prefix}-frontend-security-group"
  description = "Controls traffic reaching the frontend ECS service"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-frontend-security-group"
  }
}

# Controls traffic reaching the backend ECS service
resource "aws_security_group" "backend_security_group" {
  name        = "${var.name_prefix}-backend-security-group"
  description = "Controls traffic reaching the backend ECS service"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-backend-security-group"
  }
}

# Controls PostgreSQL traffic reaching the RDS database
resource "aws_security_group" "database_security_group" {
  name        = "${var.name_prefix}-database-security-group"
  description = "Controls PostgreSQL traffic reaching the RDS database"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name_prefix}-database-security-group"
  }
}

# Allows public HTTP traffic from the internet to the ALB
resource "aws_vpc_security_group_ingress_rule" "alb_http_ingress" {
  security_group_id = aws_security_group.alb_security_group.id
  description       = "Allow public HTTP traffic to the ALB"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

# Allows the ALB to reach the frontend ECS service on port 8080
resource "aws_vpc_security_group_ingress_rule" "frontend_from_alb_ingress" {
  security_group_id = aws_security_group.frontend_security_group.id
  description       = "Allow HTTP traffic from the ALB to the frontend"

  referenced_security_group_id = aws_security_group.alb_security_group.id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
}

# Allows the ALB to reach the backend ECS service on port 5000
resource "aws_vpc_security_group_ingress_rule" "backend_from_alb_ingress" {
  security_group_id = aws_security_group.backend_security_group.id
  description       = "Allow API traffic from the ALB to the backend"

  referenced_security_group_id = aws_security_group.alb_security_group.id
  from_port                    = 5000
  to_port                      = 5000
  ip_protocol                  = "tcp"
}

# Allows only the backend ECS service to connect to PostgreSQL
resource "aws_vpc_security_group_ingress_rule" "database_from_backend_ingress" {
  security_group_id = aws_security_group.database_security_group.id
  description       = "Allow PostgreSQL traffic from the backend"

  referenced_security_group_id = aws_security_group.backend_security_group.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

# Allows the ALB to send HTTP traffic to the frontend ECS service
resource "aws_vpc_security_group_egress_rule" "alb_to_frontend_egress" {
  security_group_id = aws_security_group.alb_security_group.id
  description       = "Allow HTTP traffic from the ALB to the frontend"

  referenced_security_group_id = aws_security_group.frontend_security_group.id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
}

# Allows the ALB to send API traffic to the backend ECS service
resource "aws_vpc_security_group_egress_rule" "alb_to_backend_egress" {
  security_group_id = aws_security_group.alb_security_group.id
  description       = "Allow API traffic from the ALB to the backend"

  referenced_security_group_id = aws_security_group.backend_security_group.id
  from_port                    = 5000
  to_port                      = 5000
  ip_protocol                  = "tcp"
}

# Allows the frontend ECS service to make required outbound connections
resource "aws_vpc_security_group_egress_rule" "frontend_all_egress" {
  security_group_id = aws_security_group.frontend_security_group.id
  description       = "Allow required outbound traffic from the frontend"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

# Allows the backend ECS service to reach the database and external services
resource "aws_vpc_security_group_egress_rule" "backend_all_egress" {
  security_group_id = aws_security_group.backend_security_group.id
  description       = "Allow required outbound traffic from the backend"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

# Allows public HTTPS traffic from the internet to the ALB
resource "aws_vpc_security_group_ingress_rule" "alb_https_ingress" {
  security_group_id = aws_security_group.alb_security_group.id
  description       = "Allow public HTTPS traffic to the ALB"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

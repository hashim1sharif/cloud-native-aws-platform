moved {
  from = aws_vpc.vpc
  to   = module.network.aws_vpc.vpc
}

moved {
  from = aws_subnet.public_subnet_1
  to   = module.network.aws_subnet.public_subnet_1
}

moved {
  from = aws_subnet.public_subnet_2
  to   = module.network.aws_subnet.public_subnet_2
}

moved {
  from = aws_subnet.private_app_subnet_1
  to   = module.network.aws_subnet.private_app_subnet_1
}

moved {
  from = aws_subnet.private_app_subnet_2
  to   = module.network.aws_subnet.private_app_subnet_2
}

moved {
  from = aws_subnet.private_db_subnet_1
  to   = module.network.aws_subnet.private_db_subnet_1
}

moved {
  from = aws_subnet.private_db_subnet_2
  to   = module.network.aws_subnet.private_db_subnet_2
}

moved {
  from = aws_internet_gateway.internet_gateway
  to   = module.network.aws_internet_gateway.internet_gateway
}

moved {
  from = aws_eip.elastic_ip
  to   = module.network.aws_eip.elastic_ip
}

moved {
  from = aws_nat_gateway.nat_gateway
  to   = module.network.aws_nat_gateway.nat_gateway
}

moved {
  from = aws_route_table.public_route_table
  to   = module.network.aws_route_table.public_route_table
}

moved {
  from = aws_route_table.private_app_route_table
  to   = module.network.aws_route_table.private_app_route_table
}

moved {
  from = aws_route_table.private_db_route_table
  to   = module.network.aws_route_table.private_db_route_table
}

moved {
  from = aws_route_table_association.public_subnet_1_route_table_association
  to   = module.network.aws_route_table_association.public_subnet_1_route_table_association
}

moved {
  from = aws_route_table_association.public_subnet_2_route_table_association
  to   = module.network.aws_route_table_association.public_subnet_2_route_table_association
}

moved {
  from = aws_route_table_association.private_app_subnet_1_route_table_association
  to   = module.network.aws_route_table_association.private_app_subnet_1_route_table_association
}

moved {
  from = aws_route_table_association.private_app_subnet_2_route_table_association
  to   = module.network.aws_route_table_association.private_app_subnet_2_route_table_association
}

moved {
  from = aws_route_table_association.private_db_subnet_1_route_table_association
  to   = module.network.aws_route_table_association.private_db_subnet_1_route_table_association
}

moved {
  from = aws_route_table_association.private_db_subnet_2_route_table_association
  to   = module.network.aws_route_table_association.private_db_subnet_2_route_table_association
}

# Security module migration
moved {
  from = aws_security_group.alb_security_group
  to   = module.security.aws_security_group.alb_security_group
}

moved {
  from = aws_security_group.frontend_security_group
  to   = module.security.aws_security_group.frontend_security_group
}

moved {
  from = aws_security_group.backend_security_group
  to   = module.security.aws_security_group.backend_security_group
}

moved {
  from = aws_security_group.database_security_group
  to   = module.security.aws_security_group.database_security_group
}

moved {
  from = aws_vpc_security_group_ingress_rule.alb_http_ingress
  to   = module.security.aws_vpc_security_group_ingress_rule.alb_http_ingress
}

moved {
  from = aws_vpc_security_group_ingress_rule.frontend_from_alb_ingress
  to   = module.security.aws_vpc_security_group_ingress_rule.frontend_from_alb_ingress
}

moved {
  from = aws_vpc_security_group_ingress_rule.backend_from_alb_ingress
  to   = module.security.aws_vpc_security_group_ingress_rule.backend_from_alb_ingress
}

moved {
  from = aws_vpc_security_group_ingress_rule.database_from_backend_ingress
  to   = module.security.aws_vpc_security_group_ingress_rule.database_from_backend_ingress
}

moved {
  from = aws_vpc_security_group_egress_rule.alb_to_frontend_egress
  to   = module.security.aws_vpc_security_group_egress_rule.alb_to_frontend_egress
}

moved {
  from = aws_vpc_security_group_egress_rule.alb_to_backend_egress
  to   = module.security.aws_vpc_security_group_egress_rule.alb_to_backend_egress
}

moved {
  from = aws_vpc_security_group_egress_rule.frontend_all_egress
  to   = module.security.aws_vpc_security_group_egress_rule.frontend_all_egress
}

moved {
  from = aws_vpc_security_group_egress_rule.backend_all_egress
  to   = module.security.aws_vpc_security_group_egress_rule.backend_all_egress
}

# ECR module migration
moved {
  from = aws_ecr_repository.frontend_ecr_repository
  to   = module.ecr.aws_ecr_repository.frontend_ecr_repository
}

moved {
  from = aws_ecr_repository.backend_ecr_repository
  to   = module.ecr.aws_ecr_repository.backend_ecr_repository
}

moved {
  from = aws_ecr_lifecycle_policy.frontend_ecr_lifecycle_policy
  to   = module.ecr.aws_ecr_lifecycle_policy.frontend_ecr_lifecycle_policy
}

moved {
  from = aws_ecr_lifecycle_policy.backend_ecr_lifecycle_policy
  to   = module.ecr.aws_ecr_lifecycle_policy.backend_ecr_lifecycle_policy
}

# RDS module migration
moved {
  from = aws_db_subnet_group.db_subnet_group
  to   = module.rds.aws_db_subnet_group.db_subnet_group
}

moved {
  from = aws_db_instance.postgres_db_instance
  to   = module.rds.aws_db_instance.postgres_db_instance
}

# ALB module migration
moved {
  from = aws_lb.application_load_balancer
  to   = module.alb.aws_lb.application_load_balancer
}

moved {
  from = aws_lb_target_group.frontend_target_group
  to   = module.alb.aws_lb_target_group.frontend_target_group
}

moved {
  from = aws_lb_target_group.backend_target_group
  to   = module.alb.aws_lb_target_group.backend_target_group
}

moved {
  from = aws_lb_listener.http_listener
  to   = module.alb.aws_lb_listener.http_listener
}

moved {
  from = aws_lb_listener_rule.backend_api_listener_rule
  to   = module.alb.aws_lb_listener_rule.backend_api_listener_rule
}

# ECS module migration
moved {
  from = aws_cloudwatch_log_group.frontend_log_group
  to   = module.ecs.aws_cloudwatch_log_group.frontend_log_group
}

moved {
  from = aws_cloudwatch_log_group.backend_log_group
  to   = module.ecs.aws_cloudwatch_log_group.backend_log_group
}

moved {
  from = aws_ecs_cluster.ecs_cluster
  to   = module.ecs.aws_ecs_cluster.ecs_cluster
}

moved {
  from = aws_iam_role.ecs_task_execution_role
  to   = module.ecs.aws_iam_role.ecs_task_execution_role
}

moved {
  from = aws_iam_role_policy_attachment.ecs_task_execution_role_policy_attachment
  to   = module.ecs.aws_iam_role_policy_attachment.ecs_task_execution_role_policy_attachment
}

moved {
  from = aws_iam_role_policy.ecs_task_execution_secrets_policy
  to   = module.ecs.aws_iam_role_policy.ecs_task_execution_secrets_policy
}

moved {
  from = aws_ecs_task_definition.frontend_task_definition
  to   = module.ecs.aws_ecs_task_definition.frontend_task_definition
}

moved {
  from = aws_ecs_task_definition.backend_task_definition
  to   = module.ecs.aws_ecs_task_definition.backend_task_definition
}

moved {
  from = aws_ecs_service.frontend_service
  to   = module.ecs.aws_ecs_service.frontend_service
}

moved {
  from = aws_ecs_service.backend_service
  to   = module.ecs.aws_ecs_service.backend_service
}

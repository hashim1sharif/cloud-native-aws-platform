# AWS Environment Plan

## Purpose

This document describes the planned AWS environment for the Task Management Platform.

The application currently runs locally with Docker Compose. It consists of a React frontend, an Express backend, and a PostgreSQL database.

The next phase is to deploy the frontend and backend containers to Amazon ECS Fargate. The local PostgreSQL container will be replaced by Amazon RDS PostgreSQL.

The first deployment will be a development environment. The infrastructure will follow production-style networking and security principles, while keeping the initial running costs controlled.

This is a working design document. Some settings may change while the infrastructure is being built and tested.

## Project Information

- Project name: `task-management`
- Environment: `dev`
- Resource prefix: `task-management-dev`
- AWS Region: `eu-west-1`
- Availability Zones: Two
- Infrastructure management: Terraform
- Deployment automation: GitHub Actions

Terraform will select two available Availability Zones in the configured AWS Region. The exact zone names will not be hardcoded at this stage.

## Resource Naming

Resources will use a consistent naming structure.

Examples:

- VPC: `task-management-dev-vpc`
- Internet Gateway: `task-management-dev-igw`
- NAT Gateway: `task-management-dev-nat`
- Application Load Balancer: `task-management-dev-alb`
- ECS cluster: `task-management-dev-cluster`
- Frontend ECS service: `task-management-dev-frontend`
- Backend ECS service: `task-management-dev-backend`
- RDS database: `task-management-dev-db`
- Frontend ECR repository: `task-management-frontend`
- Backend ECR repository: `task-management-backend`

The environment name is included in infrastructure resource names so that another environment, such as `test` or `prod`, can be added later.


# Cloud-Native AWS Platform

[![Infrastructure Deployment](https://github.com/hashim1sharif/cloud-native-aws-platform/actions/workflows/infrastructure-deployment.yml/badge.svg)](https://github.com/hashim1sharif/cloud-native-aws-platform/actions/workflows/infrastructure-deployment.yml)
[![Application Deployment](https://github.com/hashim1sharif/cloud-native-aws-platform/actions/workflows/application-deployment.yml/badge.svg)](https://github.com/hashim1sharif/cloud-native-aws-platform/actions/workflows/application-deployment.yml)
[![Infrastructure Destroy](https://github.com/hashim1sharif/cloud-native-aws-platform/actions/workflows/terraform-destroy.yml/badge.svg)](https://github.com/hashim1sharif/cloud-native-aws-platform/actions/workflows/terraform-destroy.yml)

A containerized three-tier application deployed on AWS ECS Fargate with Terraform and automated through GitHub Actions.

**Application:** React frontend → Express API → PostgreSQL  
**Platform:** ECS Fargate, ALB, RDS, ECR, Route 53, ACM  
**Automation:** Terraform, GitHub Actions, GitHub OIDC

**Live application:** https://tasks.hashim-next-gen.com

> The development environment may be stopped when it is not in use to reduce AWS costs.

## Application overview

The application is a task-management platform where users can create, view, and delete tasks through a web interface.

It has three layers:

- **Frontend:** React and Vite, served by Nginx
- **Backend:** Node.js and Express REST API
- **Database:** PostgreSQL on Amazon RDS

The frontend and backend are built as separate Docker images and stored in separate Amazon ECR repositories.

### Why this application?

I chose a task-management application because it is simple to understand while still representing a realistic three-tier workload.

It requires:

- A separate frontend and backend
- Persistent database storage
- Container networking
- Secure database access
- Load balancing
- HTTPS
- Secrets management
- Logging
- Infrastructure as Code
- Automated deployments

The application is intentionally simple so the main focus of the project remains on AWS infrastructure, containerization, security, networking, and deployment automation.

### Why Amazon ECS Fargate?

I chose Amazon ECS Fargate because it provides container orchestration without requiring me to manage the underlying EC2 hosts.

With Fargate:

- I do not patch or maintain EC2 container hosts
- The frontend and backend run as separate services
- Each service can be deployed and scaled independently
- It integrates with Amazon ECR, ALB, IAM, CloudWatch, and RDS
- It reduces infrastructure maintenance

A normal virtual machine could run the application, but it would require operating-system maintenance, Docker host management, capacity planning, and server administration.

Vercel or Netlify could host the frontend, but they would not demonstrate the complete AWS platform used in this project, including ECS, ECR, private backend networking, RDS, IAM, ALB routing, Route 53, ACM, Terraform, and GitHub OIDC.

### Expected users

This is a development and portfolio environment intended for a small workload.

A reasonable first estimate is **10 to 50 users**, not all active at the same time. This is not a tested capacity limit.

The current design uses:

```text
Frontend service: 1 ECS task
Backend service:  1 ECS task
Database:         db.t4g.micro
```

Before production use, I would run load tests, add CloudWatch alarms, configure ECS Service Auto Scaling, and review the RDS instance size.

## Architecture

![AWS architecture diagram](docs/architecture-diagram.gif)

### Network design

- The frontend service runs in public subnets
- Frontend tasks receive public IP addresses
- The ALB forwards frontend traffic to container port `8080`
- The frontend accepts port `8080` only from the ALB security group
- The backend service runs in private application subnets without public IP addresses
- The ALB forwards `/api/*` and `/health` traffic to backend port `5000`
- The backend target group uses `/health` to verify that the backend is responding before receiving traffic
- Private application subnets use a NAT Gateway for outbound access
- Amazon RDS runs in private database subnets
- The database accepts port `5432` only from the backend security group

## Infrastructure

- Multi-AZ VPC design across two Availability Zones
- Public subnets for the ALB and frontend service
- Private application subnets for the backend service
- Private database subnets for Amazon RDS
- Internet-facing Application Load Balancer
- HTTP port `80` redirects to HTTPS port `443`
- HTTPS listener routes `/` to the frontend
- HTTPS listener routes `/api/*` and `/health` to the backend
- Security groups restrict traffic between application layers
- Route 53 and ACM provide DNS and HTTPS
- CloudWatch log groups capture frontend and backend logs

## Docker

- Separate Docker images are built for the frontend and backend
- Multi-stage Dockerfiles separate build dependencies from runtime images
- The backend runs as the non-root `node` user
- The frontend uses the `nginx-unprivileged` runtime image
- The frontend listens on port `8080`
- The backend listens on port `5000`
- Images are pushed to separate immutable Amazon ECR repositories

## Terraform

- Infrastructure is split into reusable Terraform modules
- All development modules are called from a single `main.tf`
- Terraform provisions networking, security groups, ECR, ECS, RDS, ALB, ACM, Route 53, and IAM
- Terraform state is stored remotely in Amazon S3
- Native S3 state locking protects against concurrent state changes
- Bootstrap resources are kept separate from the development environment
- ECS services are initially created with zero running tasks so the infrastructure can be provisioned before application images exist

### Terraform modules

| Module     | Responsibility                                                |
| ---------- | ------------------------------------------------------------- |
| `network`  | VPC, subnets, route tables, Internet Gateway, and NAT Gateway |
| `security` | Security groups and traffic rules                             |
| `ecr`      | Frontend and backend repositories                             |
| `rds`      | PostgreSQL database and database subnet group                 |
| `alb`      | Load balancer, listeners, target groups, and routing          |
| `ecs`      | Cluster, task definitions, services, IAM role, and log groups |
| `acm`      | TLS certificate and DNS validation                            |
| `route53`  | DNS alias record                                              |

## Security

- Public HTTP traffic is redirected to HTTPS
- The ALB is the only component that accepts public inbound traffic
- The frontend accepts port `8080` only from the ALB security group
- The backend has no public IP address
- Amazon RDS is not publicly accessible
- The database accepts PostgreSQL traffic only from the backend security group
- Database credentials are managed through AWS Secrets Manager
- GitHub Actions uses OIDC instead of permanent AWS access keys
- Separate IAM roles are used for infrastructure and application deployment
- GitHub OIDC trust policies are scoped to the repository and `main` branch
- Docker images use immutable deployment-specific tags based on the Git commit SHA
- Backend containers run as a non-root user
- Frontend containers use an unprivileged Nginx runtime image
- Local secret files remain outside Git

## Deployment automation

Infrastructure provisioning and application deployment are intentionally separated into two GitHub Actions workflows.

```text
Push to main
     │
     ▼
Infrastructure Deployment
     │
     ├── Terraform Init
     ├── Terraform Plan
     └── Terraform Apply
     │
     ▼
Infrastructure deployment succeeds
     │
     ▼
Application Deployment
     │
     ├── Build frontend and backend images
     ├── Push images to Amazon ECR
     ├── Create new ECS task-definition revisions
     ├── Update ECS services
     └── Start the application tasks
```

### Infrastructure Deployment

A push to `main` automatically starts the infrastructure workflow.

```text
Checkout
→ Configure AWS credentials with GitHub OIDC
→ Terraform Init
→ Terraform Plan
→ Terraform Apply
```

Workflow: [`.github/workflows/infrastructure-deployment.yml`](.github/workflows/infrastructure-deployment.yml)

### Application Deployment

The application workflow starts automatically after **Infrastructure Deployment** completes successfully.

It:

1. Checks out the same Git commit used by the infrastructure deployment
2. Authenticates to AWS through GitHub OIDC
3. Builds the backend and frontend Docker images
4. Tags the images using the Git commit SHA and workflow attempt
5. Pushes both images to separate immutable Amazon ECR repositories
6. Creates new ECS task-definition revisions using the new images
7. Updates both ECS services
8. Sets the frontend and backend services to one running task

Example image tags:

```text
task-management-dev-backend:<commit-sha>-1
task-management-dev-frontend:<commit-sha>-1
```

This provides traceability between the source commit, Docker image, and ECS deployment.

Workflow: [`.github/workflows/application-deployment.yml`](.github/workflows/application-deployment.yml)

### Infrastructure Destroy

Destroying the development environment is intentionally kept separate and manual.

The workflow authenticates to AWS with GitHub OIDC, initializes Terraform, and destroys the development environment.

Workflow: [`.github/workflows/terraform-destroy.yml`](.github/workflows/terraform-destroy.yml)

## AWS Well-Architected considerations

The platform design applies principles from the six pillars of the AWS Well-Architected Framework:

- **Operational Excellence:** Infrastructure as Code, automated deployments, CloudWatch logging, and repeatable workflows
- **Security:** GitHub OIDC, IAM roles, Secrets Manager, security groups, private backend networking, and private RDS
- **Reliability:** Multi-AZ networking, ALB health checks, managed AWS services, and separate frontend/backend services
- **Performance Efficiency:** ECS Fargate services can be deployed and scaled independently
- **Cost Optimization:** The development environment can be destroyed when it is not needed, and small development-sized resources are used
- **Sustainability:** Managed services and right-sized resources reduce unnecessary infrastructure and server management

## Deployment overview

### First deployment

The bootstrap resources must exist before the automated development deployment.

```text
Push to main
     ↓
Infrastructure Deployment
     ↓
Terraform creates the AWS infrastructure
     ↓
ECS services are created with zero running tasks
     ↓
Application Deployment starts automatically
     ↓
Frontend and backend images are built
     ↓
Images are pushed to Amazon ECR
     ↓
New ECS task definitions are deployed
     ↓
ECS services scale from 0 to 1
     ↓
Application available through HTTPS
```

Terraform creates the ECS services with zero running tasks so infrastructure provisioning does not depend on application images already existing in ECR.

The application workflow then owns the application release by building and deploying the actual container images.

### Later infrastructure changes

Update the Terraform code and merge the change into `main`.

The infrastructure workflow applies the change first. After it succeeds, the application deployment workflow runs automatically.

### Later application changes

Update the application code and merge the change into `main`.

The infrastructure workflow runs first and normally reports no infrastructure changes. After it succeeds, the application workflow builds and deploys the new container images.

## Health checks

The Application Load Balancer uses health checks to verify that the application is responding before routing user traffic to an ECS task.

The frontend target group checks:

```text
/
```

The backend target group checks:

```text
/health
```

A running container is not automatically a healthy application. The ALB health checks prevent traffic from being routed to targets that are not responding correctly.

## Repository structure

```text
cloud-native-aws-platform/
├── .github/
│   └── workflows/
│       ├── infrastructure-deployment.yml
│       ├── application-deployment.yml
│       └── terraform-destroy.yml
├── backend/
│   ├── src/
│   ├── Dockerfile
│   └── package.json
├── frontend/
│   ├── src/
│   ├── Dockerfile
│   └── package.json
├── infra/
│   └── terraform/
│       ├── bootstrap/
│       ├── environments/
│       │   └── dev/
│       └── modules/
│           ├── acm/
│           ├── alb/
│           ├── ecr/
│           ├── ecs/
│           ├── network/
│           ├── rds/
│           ├── route53/
│           └── security/
├── docs/
│   ├── architecture-diagram.gif
│   ├── SCREENSHOTS.md
│   ├── aws-environment-plan.md
│   └── screenshots/
├── docker-compose.yaml
└── README.md
```

## Technology stack

| Area                   | Technology                                                                        |
| ---------------------- | --------------------------------------------------------------------------------- |
| Frontend               | React, Vite, Nginx                                                                |
| Backend                | Node.js, Express                                                                  |
| Database               | Amazon RDS for PostgreSQL                                                         |
| Containers             | Docker                                                                            |
| Container platform     | Amazon ECS Fargate                                                                |
| Container registry     | Amazon ECR                                                                        |
| Infrastructure as Code | Terraform                                                                         |
| Networking             | Amazon VPC, subnets, route tables, Internet Gateway, NAT Gateway, security groups |
| Traffic management     | Application Load Balancer                                                         |
| DNS and HTTPS          | Amazon Route 53, AWS Certificate Manager                                          |
| Secrets                | AWS Secrets Manager                                                               |
| Logging                | Amazon CloudWatch Logs                                                            |
| CI/CD                  | GitHub Actions                                                                    |
| AWS authentication     | GitHub OIDC and IAM                                                               |

## Local development

### Requirements

- Git
- Docker Desktop
- Docker Compose

Start the application:

```bash
docker compose up --build
```

Stop the application:

```bash
docker compose down
```

## Terraform commands

Open the development environment:

```bash
cd infra/terraform/environments/dev
```

Initialize Terraform:

```bash
terraform init
```

Review the infrastructure:

```bash
terraform plan
```

Create or update the infrastructure:

```bash
terraform apply
```

Destroy the development environment manually:

```bash
terraform destroy
```

For the automated project workflow, infrastructure destruction is normally performed through **Infrastructure Destroy** in GitHub Actions.

## Project evidence

### AWS network

The VPC contains public, private application, and private database subnets across two Availability Zones.

![VPC resource map](docs/screenshots/06-vpc-resource-map.png)

### Application Load Balancer

Port `80` redirects to HTTPS on port `443`.

The HTTPS listener sends normal application traffic to the frontend and routes `/api/*` and `/health` to the backend.

![Application Load Balancer](docs/screenshots/07-application-load-balancer.png)

### ECS Fargate services

When the development environment is running, both ECS services run one application task.

![ECS cluster services](docs/screenshots/09-ecs-cluster-services.png)

### PostgreSQL database

The development environment uses Amazon RDS for PostgreSQL on a `db.t4g.micro` instance.

![Amazon RDS PostgreSQL](docs/screenshots/11-rds-database.png)

### GitHub Actions

The infrastructure workflow provisions AWS resources with Terraform. After it succeeds, the application workflow builds Docker images, pushes them to Amazon ECR, and deploys them to Amazon ECS.

![GitHub Actions CI](docs/screenshots/15-github-actions-ci.png)

![Terraform deployment](docs/screenshots/16-terraform-deployment-success.png)

### Amazon ECR

The frontend and backend use separate immutable ECR repositories.

![Amazon ECR repositories](docs/screenshots/19-ecr-images.png)

### Live application

When the development environment is running, the application is available through HTTPS.

![Live task management application](docs/screenshots/17-live-application.png)

### API response

The backend API is available through `/api/tasks`.

![Task API response](docs/screenshots/18-api-response.png)

The backend health endpoint is available through `/health`.

The complete screenshot gallery is available in [`docs/SCREENSHOTS.md`](docs/SCREENSHOTS.md).

## Key decisions

- Used separate public, application, and database network layers
- Kept the backend and database without direct public access
- Used one ALB for frontend and backend routing
- Redirected public HTTP traffic to HTTPS
- Routed `/api/*` and `/health` to the backend
- Used ALB health checks for frontend and backend targets
- Used two ECS services for independent deployment
- Used zero-task ECS services during the initial Terraform deployment
- Used immutable deployment-specific image tags for traceable releases
- Ran application containers as non-root users
- Separated infrastructure deployment from application deployment
- Automated application deployment after successful infrastructure deployment
- Kept infrastructure destruction as a separate manual workflow
- Used GitHub OIDC instead of permanent AWS credentials
- Stored Terraform state remotely with S3 locking
- Structured Terraform infrastructure using reusable modules

## Possible improvements

- Add automated tests
- Add image and dependency scanning
- Add CloudWatch alarms and dashboards
- Add ECS Service Auto Scaling
- Add staging and production environments
- Add load testing
- Add database backup and restore testing
- Add AWS cost alerts

## Documentation

- [Screenshot gallery](docs/SCREENSHOTS.md)
- [AWS environment plan](docs/aws-environment-plan.md)

## Author

**Hashim Sharif**

DevOps and cloud engineering portfolio project focused on AWS, Terraform, Docker, networking, security, and CI/CD.

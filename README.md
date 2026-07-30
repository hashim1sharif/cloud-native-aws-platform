# Task Management Platform on AWS

[![Continuous Integration](https://github.com/hashim1sharif/task-management-platform/actions/workflows/ci.yml/badge.svg)](https://github.com/hashim1sharif/task-management-platform/actions/workflows/ci.yml)
[![Deploy development](https://github.com/hashim1sharif/task-management-platform/actions/workflows/deploy-dev.yml/badge.svg)](https://github.com/hashim1sharif/task-management-platform/actions/workflows/deploy-dev.yml)

I built this project to practise moving a three-tier application from a local Docker setup to a complete AWS deployment.

The React frontend and Express backend run as separate containers on Amazon ECS Fargate. The backend stores data in Amazon RDS for PostgreSQL. An Application Load Balancer handles HTTPS traffic and routes browser and API requests to the correct service. Terraform manages the infrastructure, while GitHub Actions builds and deploys new application versions.

**Live environment:** [https://tasks.hashim-next-gen.com](https://tasks.hashim-next-gen.com)

> The development environment may be taken offline when it is not being used to reduce AWS costs.

## Architecture

![AWS architecture diagram](docs/architecture-diagram.gif)

The platform follows a three-tier architecture:

- **Presentation tier:** React and Nginx running in the frontend ECS service
- **Application tier:** Node.js and Express running in the backend ECS service
- **Data tier:** Amazon RDS for PostgreSQL

The Application Load Balancer routes requests as follows:

```text
Browser
  ├── /        → Route 53 → HTTPS ALB → Frontend ECS service
  └── /api/*   → Route 53 → HTTPS ALB → Backend ECS service → RDS PostgreSQL
```

The frontend and backend tasks run in private application subnets. The database runs in private database subnets and accepts PostgreSQL traffic only from the backend security group.

## What I built

- React frontend served by Nginx
- Node.js and Express REST API
- PostgreSQL database on Amazon RDS
- Separate frontend and backend Docker images
- Separate Amazon ECR repositories with immutable image tags
- Two Amazon ECS Fargate services in private subnets
- Internet-facing Application Load Balancer
- Path-based routing for `/api/*`
- HTTPS using Route 53 and AWS Certificate Manager
- CloudWatch log groups for both services
- Reusable Terraform modules
- GitHub Actions for CI and automated deployment
- GitHub OIDC authentication without permanent AWS access keys

## Technology stack

| Area | Technology |
|---|---|
| Frontend | React, Vite, Nginx |
| Backend | Node.js, Express |
| Database | Amazon RDS for PostgreSQL |
| Containers | Docker |
| Container platform | Amazon ECS Fargate |
| Container registry | Amazon ECR |
| Infrastructure as Code | Terraform |
| Networking | Amazon VPC, public and private subnets, NAT Gateway, security groups |
| Traffic management | Application Load Balancer |
| DNS and HTTPS | Route 53, AWS Certificate Manager |
| Logging | Amazon CloudWatch Logs |
| CI/CD | GitHub Actions |
| AWS authentication | GitHub OIDC and IAM |

## Repository structure

```text
task-management-platform/
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── deploy-dev.yml
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
├── docs/
│   ├── architecture-diagram.gif
│   ├── RUNBOOK.md
│   ├── SCREENSHOTS.md
│   ├── aws-environment-plan.md
│   └── screenshots/
├── docker-compose.yml
└── README.md
```

## Infrastructure design

The Terraform code is divided into modules so that each part of the infrastructure has one clear responsibility.

| Module | Responsibility |
|---|---|
| `network` | VPC, subnets, route tables, Internet Gateway and NAT Gateway |
| `security` | Security groups for the ALB, ECS services and database |
| `ecr` | Frontend and backend container repositories |
| `rds` | PostgreSQL database and database subnet group |
| `alb` | Load balancer, listeners, target groups and routing rules |
| `ecs` | Cluster, task definitions, services, IAM roles and log groups |
| `acm` | TLS certificate and DNS validation |
| `route53` | DNS alias record for the application |

Terraform state is stored remotely in Amazon S3. Native S3 state locking is enabled through a lockfile.

## Security choices

- Only the Application Load Balancer is publicly reachable.
- ECS tasks do not receive public IP addresses.
- Amazon RDS is not publicly accessible.
- The frontend accepts traffic only from the ALB.
- The backend accepts application traffic only from the ALB.
- The database accepts port `5432` only from the backend security group.
- Database credentials are stored in AWS Secrets Manager.
- GitHub Actions uses temporary AWS credentials through OIDC.
- Docker images are tagged with the Git commit SHA.
- Sensitive local files such as `terraform.tfvars` and `.env` are not committed.

## CI/CD

### Continuous integration

The CI workflow checks the backend, frontend and Terraform configuration.

```text
Backend:   npm ci → syntax check → Docker build
Frontend:  npm ci → production build → Docker build
Terraform: format check → init without backend → validate
```

Workflow: [`.github/workflows/ci.yml`](.github/workflows/ci.yml)

### Automated deployment

After changes are merged into `main`, the deployment workflow:

1. Authenticates to AWS through GitHub OIDC.
2. Builds the frontend and backend images.
3. Tags both images with the Git commit SHA.
4. Pushes the images to Amazon ECR.
5. Registers new ECS task-definition revisions.
6. Updates the frontend and backend ECS services.

Workflow: [`.github/workflows/deploy-dev.yml`](.github/workflows/deploy-dev.yml)

## Deployment overview

The first deployment is slightly different from later releases because the ECR repositories must exist before the initial images can be pushed.

1. Create the Terraform remote-state infrastructure.
2. Configure `terraform.tfvars`.
3. Initialize the development environment.
4. Create the ECR repositories.
5. Build and push the first frontend and backend images.
6. Apply the remaining AWS infrastructure.
7. Configure the GitHub OIDC deployment role.
8. Verify ECS, the target groups, HTTPS, CloudWatch Logs and the API.

After the environment is running, normal application releases are handled by GitHub Actions.

The full deployment, verification, destroy and recreation commands are documented in [`docs/RUNBOOK.md`](docs/RUNBOOK.md).

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

Initialize the development environment:

```bash
terraform init 
```

Format and validate the configuration:

```bash
terraform fmt 

terraform validate
```

Create a plan:

```bash
terraform  plan 

```

```bash
terraform  apply

```

## Project evidence

### AWS network

![VPC resource map](docs/screenshots/06-vpc-resource-map.png)

### Application Load Balancer

![Application Load Balancer](docs/screenshots/07-application-load-balancer.png)

### ECS Fargate services

![ECS cluster services](docs/screenshots/09-ecs-cluster-services.png)

### PostgreSQL database

![Amazon RDS PostgreSQL](docs/screenshots/11-rds-database.png)

### Continuous integration

![GitHub Actions CI](docs/screenshots/15-github-actions-ci.png)

### Automated deployment

![GitHub Actions deployment](docs/screenshots/16-github-actions-deployment.png)

### Live application

![Live task management application](docs/screenshots/17-live-application.png)

### API response

![Task API response](docs/screenshots/18-api-response.png)

The complete screenshot gallery is available in [`docs/SCREENSHOTS.md`](docs/SCREENSHOTS.md).

## What I learned

This project helped me understand how the different parts of an AWS container platform work together. The main lessons were:

- separating public, application and database network layers;
- routing website and API traffic to separate ECS services;
- handling the first deployment before container images exist in ECR;
- using immutable image tags for traceable releases;
- keeping Terraform responsible for infrastructure while GitHub Actions handles application releases;
- using OIDC instead of storing permanent AWS credentials in GitHub.

## Possible improvements

- Add backend unit and integration tests
- Add frontend tests and linting
- Add CloudWatch alarms and dashboards
- Add vulnerability scanning for images and dependencies
- Add separate staging and production environments
- Add production approval and rollback controls
- Add database restore testing

## Documentation

- [Deployment and operations runbook](docs/RUNBOOK.md)
- [Complete screenshot gallery](docs/SCREENSHOTS.md)
- [AWS environment plan](docs/aws-environment-plan.md)

## Author

**Hashim Sharif**

This is a practical DevOps and cloud engineering portfolio project focused on AWS, Terraform, Docker, networking and CI/CD.

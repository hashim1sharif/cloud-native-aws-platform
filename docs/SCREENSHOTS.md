# Project Screenshot Guide

Store screenshots in:

```text
docs/screenshots/
```

Use PNG files, consistent browser zoom, and clear filenames without spaces.

## Required portfolio screenshots

| Filename | What to capture | AWS/GitHub location | What it demonstrates |
|---|---|---|---|
| `01-live-application.png` | Live application with example tasks | Browser | End-to-end application availability through HTTPS |
| `02-ci-workflow.png` | Green backend, frontend and Terraform jobs | GitHub → Actions → Continuous Integration | Automated validation |
| `03-deployment-workflow.png` | Successful deployment job and steps | GitHub → Actions → `.github/workflows/deploy-dev.yml` | OIDC, ECR and ECS automation |
| `04-ecs-services.png` | Both services desired `1`, running `1`, rollout completed | AWS Console → ECS → Cluster → Services | Healthy Fargate services |
| `05-alb-listeners-rules.png` | HTTPS listener and `/api/*` rule | AWS Console → EC2 → Load Balancers | TLS and path-based routing |
| `06-rds-database.png` | PostgreSQL instance with status `Available` | AWS Console → RDS → Databases | Private database layer |

## Supporting screenshots

| Filename | Capture |
|---|---|
| `07-route53-record.png` | Alias record for `tasks.hashim-next-gen.com` |
| `08-acm-certificate.png` | ACM certificate with status `Issued` |
| `09-ecr-images.png` | Frontend and backend images with commit-SHA tags |
| `10-task-definitions.png` | Frontend and backend task-definition revisions |
| `11-cloudwatch-logs.png` | Frontend and backend log groups and recent streams |
| `12-terraform-plan.png` | Terraform plan or `No changes` output |
| `13-security-groups.png` | ALB, frontend, backend and RDS security-group chain |
| `14-oidc-role.png` | GitHub Actions role and trust relationship |

## Security rules

- Never show AWS access keys.
- Never open or display the value of the RDS secret.
- Hide passwords, tokens and private keys.
- Blur personal tabs, notifications and unrelated account data.
- Capture only the panel needed for the explanation.
- Account IDs and resource ARNs may be blurred for a public portfolio.

## Ready-to-copy README blocks

```markdown
## Project screenshots

### Live application

![Live task management application](docs/screenshots/01-live-application.png)

The application is available through the custom HTTPS domain and stores tasks in RDS PostgreSQL.

### Continuous integration

![GitHub Actions CI workflow](docs/screenshots/02-ci-workflow.png)

Every pull request validates the backend, frontend, Docker builds, and Terraform configuration.

### Automated deployment

![GitHub Actions development deployment](docs/screenshots/03-deployment-workflow.png)

A merge to `main` authenticates to AWS using OIDC, pushes immutable images to ECR, and deploys new ECS task revisions.

### ECS Fargate services

![Healthy ECS Fargate services](docs/screenshots/04-ecs-services.png)

The frontend and backend services run independently in private application subnets.

### Load balancer routing

![Application Load Balancer listeners and rules](docs/screenshots/05-alb-listeners-rules.png)

The ALB serves the frontend by default and routes `/api/*` requests to the backend.

### PostgreSQL database

![Amazon RDS PostgreSQL database](docs/screenshots/06-rds-database.png)

The backend stores application data in a private RDS PostgreSQL instance.
```

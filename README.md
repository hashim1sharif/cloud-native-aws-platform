# Containerized Three-Tier Task Management Platform

A full-stack task management application built with React, Node.js, Express, and PostgreSQL.

The application uses a three-tier architecture and is containerized with Docker. Docker Compose is used to build, configure, and run the frontend, backend API, and database as separate services.

## Architecture

- Frontend: React and Vite
- Backend: Node.js and Express
- Database: PostgreSQL
- Web server: Nginx
- Containerization: Docker
- Local orchestration: Docker Compose

## Project Goals

- Build a clean three-tier application architecture
- Create optimized multi-stage Docker images
- Separate application configuration from source code
- Run all services using Docker Compose
- Prepare the application for deployment to AWS ECS Fargate
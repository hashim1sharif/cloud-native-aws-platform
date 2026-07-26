# DevOps three-tier Docker practice

This repository simulates a clean developer handover of an application that has not been containerized.

## Tiers

```text
React frontend -> Express API -> PostgreSQL database
```

## Step 1: Configure PostgreSQL

Create the database:

```bash
psql -U postgres -c "CREATE DATABASE devops_tasks;"
```

Create the table:

```bash
psql -U postgres -d devops_tasks -f database/init.sql
```

On Windows, you may also run `database/init.sql` through pgAdmin Query Tool.

## Step 2: Configure and run the backend

```bash
cp backend/.env.example backend/.env
```

Open `backend/.env` and set your PostgreSQL password.

```bash
cd backend
npm install
npm run dev
```

Test:

```bash
curl http://localhost:5000/health
```

Expected response:

```json
{"status":"healthy"}
```

## Step 3: Configure and run the frontend

Open another terminal from the repository root:

```bash
cp frontend/.env.example frontend/.env
cd frontend
npm install
npm run dev
```

Open `http://localhost:5173`.

## Docker task

After local testing succeeds, create:

```text
backend/Dockerfile
backend/.dockerignore
frontend/Dockerfile
frontend/.dockerignore
compose.yaml
.env
```

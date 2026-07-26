# Developer handover: Tasks application

## Business purpose
A small task-management application. Users can create, view, complete, and delete tasks.

## Architecture
- Frontend: React + Vite
- Backend: Node.js + Express REST API
- Database: PostgreSQL

## Runtime requirements
- Node.js and npm
- PostgreSQL

## Local ports
- Frontend: `5173`
- Backend: `5000`
- PostgreSQL: `5432`

## Start commands

### Backend
```bash
cd backend
npm install
npm run dev
```

### Frontend
```bash
cd frontend
npm install
npm run dev
```

## Environment variables
Copy each `.env.example` file to `.env` and adjust the values.

### Backend
- `PORT`
- `DB_HOST`
- `DB_PORT`
- `DB_NAME`
- `DB_USER`
- `DB_PASSWORD`
- `CORS_ORIGIN`

### Frontend
- `VITE_API_URL`

## Database initialization
Create a PostgreSQL database named `devops_tasks`, then execute `database/init.sql` against it.

## Health check
`GET http://localhost:5000/health`

## Important
This handover intentionally contains no Dockerfile and no Compose file. The DevOps task is to containerize it after confirming that it runs locally.

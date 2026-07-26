require("dotenv").config();

const cors = require("cors");
const express = require("express");
const pool = require("./db");

const app = express();
const port = Number(process.env.PORT || 5000);

app.use(
  cors({
    origin: process.env.CORS_ORIGIN || "http://localhost:5173",
  })
);
app.use(express.json());

app.get("/health", async (_request, response) => {
  try {
    await pool.query("SELECT 1");
    response.status(200).json({ status: "healthy" });
  } catch (error) {
    console.error("Health check failed:", error.message);
    response.status(503).json({ status: "unhealthy" });
  }
});

app.get("/api/tasks", async (_request, response, next) => {
  try {
    const result = await pool.query(
      "SELECT id, title, completed, created_at FROM tasks ORDER BY id DESC"
    );
    response.json(result.rows);
  } catch (error) {
    next(error);
  }
});

app.post("/api/tasks", async (request, response, next) => {
  try {
    const title = String(request.body.title || "").trim();

    if (!title) {
      return response.status(400).json({ error: "Title is required" });
    }

    const result = await pool.query(
      "INSERT INTO tasks (title) VALUES ($1) RETURNING id, title, completed, created_at",
      [title]
    );

    return response.status(201).json(result.rows[0]);
  } catch (error) {
    return next(error);
  }
});

app.patch("/api/tasks/:id", async (request, response, next) => {
  try {
    const id = Number(request.params.id);
    const completed = Boolean(request.body.completed);

    if (!Number.isInteger(id)) {
      return response.status(400).json({ error: "Invalid task id" });
    }

    const result = await pool.query(
      "UPDATE tasks SET completed = $1 WHERE id = $2 RETURNING id, title, completed, created_at",
      [completed, id]
    );

    if (result.rowCount === 0) {
      return response.status(404).json({ error: "Task not found" });
    }

    return response.json(result.rows[0]);
  } catch (error) {
    return next(error);
  }
});

app.delete("/api/tasks/:id", async (request, response, next) => {
  try {
    const id = Number(request.params.id);

    if (!Number.isInteger(id)) {
      return response.status(400).json({ error: "Invalid task id" });
    }

    const result = await pool.query("DELETE FROM tasks WHERE id = $1", [id]);

    if (result.rowCount === 0) {
      return response.status(404).json({ error: "Task not found" });
    }

    return response.status(204).send();
  } catch (error) {
    return next(error);
  }
});

app.use((error, _request, response, _next) => {
  console.error(error);
  response.status(500).json({ error: "Internal server error" });
});

const server = app.listen(port, "0.0.0.0", () => {
  console.log(`Tasks API listening on port ${port}`);
});

async function shutdown(signal) {
  console.log(`${signal} received, shutting down`);
  server.close(async () => {
    await pool.end();
    process.exit(0);
  });
}

process.on("SIGTERM", () => shutdown("SIGTERM"));
process.on("SIGINT", () => shutdown("SIGINT"));

require("dotenv").config();

const cors = require("cors");
const express = require("express");
const pool = require("./db");

const app = express();
const port = Number(process.env.PORT || 5000);

let server;

/**
 * Creates the database table when it does not exist.
 * Existing tables and task data are not deleted.
 */
async function initializeDatabase() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS tasks (
      id SERIAL PRIMARY KEY,
      title TEXT NOT NULL,
      completed BOOLEAN NOT NULL DEFAULT FALSE,
      created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
    );
  `);

  console.log("Database table initialized");
}

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
      return response.status(400).json({
        error: "Title is required",
      });
    }

    const result = await pool.query(
      `INSERT INTO tasks (title)
       VALUES ($1)
       RETURNING id, title, completed, created_at`,
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
    const completed = request.body.completed;

    if (!Number.isInteger(id) || id <= 0) {
      return response.status(400).json({
        error: "Invalid task id",
      });
    }

    if (typeof completed !== "boolean") {
      return response.status(400).json({
        error: "Completed must be true or false",
      });
    }

    const result = await pool.query(
      `UPDATE tasks
       SET completed = $1
       WHERE id = $2
       RETURNING id, title, completed, created_at`,
      [completed, id]
    );

    if (result.rowCount === 0) {
      return response.status(404).json({
        error: "Task not found",
      });
    }

    return response.json(result.rows[0]);
  } catch (error) {
    return next(error);
  }
});

app.delete("/api/tasks/:id", async (request, response, next) => {
  try {
    const id = Number(request.params.id);

    if (!Number.isInteger(id) || id <= 0) {
      return response.status(400).json({
        error: "Invalid task id",
      });
    }

    const result = await pool.query(
      "DELETE FROM tasks WHERE id = $1",
      [id]
    );

    if (result.rowCount === 0) {
      return response.status(404).json({
        error: "Task not found",
      });
    }

    return response.status(204).send();
  } catch (error) {
    return next(error);
  }
});

app.use((error, _request, response, _next) => {
  console.error("Unhandled API error:", error);

  response.status(500).json({
    error: "Internal server error",
  });
});

/**
 * Initializes the database before starting the API.
 */
async function startServer() {
  try {
    await initializeDatabase();

    server = app.listen(port, "0.0.0.0", () => {
      console.log(`Tasks API listening on port ${port}`);
    });
  } catch (error) {
    console.error("Failed to initialize database:", error);

    try {
      await pool.end();
    } catch (poolError) {
      console.error("Failed to close database pool:", poolError);
    }

    process.exit(1);
  }
}

/**
 * Stops accepting requests and closes database connections.
 */
async function shutdown(signal) {
  console.log(`${signal} received, shutting down`);

  if (!server) {
    await pool.end();
    process.exit(0);
    return;
  }

  server.close(async () => {
    try {
      await pool.end();
      console.log("Database pool closed");
      process.exit(0);
    } catch (error) {
      console.error("Shutdown failed:", error);
      process.exit(1);
    }
  });
}

process.once("SIGTERM", () => shutdown("SIGTERM"));
process.once("SIGINT", () => shutdown("SIGINT"));

startServer();
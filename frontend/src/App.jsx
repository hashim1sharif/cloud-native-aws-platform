import { useEffect, useState } from "react";

// const apiUrl = import.meta.env.VITE_API_URL || "http://localhost:5000";
const apiUrl = import.meta.env.VITE_API_URL ?? "";
export default function App() {
  const [tasks, setTasks] = useState([]);
  const [title, setTitle] = useState("");
  const [error, setError] = useState("");

  async function loadTasks() {
    try {
      setError("");
      const response = await fetch(`${apiUrl}/api/tasks`);
      if (!response.ok) throw new Error("Could not load tasks");
      setTasks(await response.json());
    } catch (requestError) {
      setError(requestError.message);
    }
  }

  useEffect(() => {
    loadTasks();
  }, []);

  async function addTask(event) {
    event.preventDefault();
    const cleanTitle = title.trim();
    if (!cleanTitle) return;

    const response = await fetch(`${apiUrl}/api/tasks`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ title: cleanTitle }),
    });

    if (!response.ok) {
      setError("Could not create task");
      return;
    }

    setTitle("");
    await loadTasks();
  }

  async function toggleTask(task) {
    await fetch(`${apiUrl}/api/tasks/${task.id}`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ completed: !task.completed }),
    });
    await loadTasks();
  }

  async function deleteTask(id) {
    await fetch(`${apiUrl}/api/tasks/${id}`, { method: "DELETE" });
    await loadTasks();
  }

  return (
    <main className="page">
      <section className="card">
        <p className="eyebrow">Three-tier practice application</p>
        <h1>DevOps Tasks</h1>
        <p className="intro">React frontend, Express API, PostgreSQL database.</p>

        <form onSubmit={addTask} className="task-form">
          <input
            value={title}
            onChange={(event) => setTitle(event.target.value)}
            placeholder="Add a task"
            aria-label="Task title"
          />
          <button type="submit">Add</button>
        </form>

        {error && <p className="error">{error}</p>}

        <ul className="task-list">
          {tasks.map((task) => (
            <li key={task.id}>
              <button
                className={`task-title ${task.completed ? "completed" : ""}`}
                onClick={() => toggleTask(task)}
              >
                {task.title}
              </button>
              <button className="delete" onClick={() => deleteTask(task.id)}>
                Delete
              </button>
            </li>
          ))}
        </ul>
      </section>
    </main>
  );
}

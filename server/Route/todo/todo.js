const express = require("express");
const sql = require("../../DB/connection");
const router = express.Router();

router.get("/get-tasks", async (req, res) => {
  const userId = req.query.user_id;
  console.log("id: ", userId);
  if (!userId) {
    return res.status(400).json({ error: "User ID is required" });
  }
  const result = await sql`SELECT * FROM todo_list WHERE user_id = ${userId}`;
  console.log("Fetched tasks:", result);
  res.json(result);
});

router.post("/add-task", async (req, res) => {
  const { user_id, title, description, priority, dueDate, createdAt } =
    req.body;
  console.log("Adding task for user:", user_id);
  if (!user_id || !title || !description || !priority) {
    return res.status(400).json({
      error: "User ID, title, description, and priority are required",
    });
  }

  try {
    // Use client-provided createdAt or fallback to server time
    const timestamp = createdAt || new Date().toISOString();

    const result = await sql`
      INSERT INTO todo_list (user_id, title, description, priority, "dueDate", "createdAt", "isCompleted") 
      VALUES (${user_id}, ${title}, ${description}, ${priority}, ${
      dueDate || null
    }, ${timestamp}, false)
      RETURNING *
    `;
    console.log("Task added:", result[0]);
    res.status(201).json(result[0]);
  } catch (error) {
    console.error("Error adding task:", error);
    res.status(500).json({ error: "Failed to add task" });
  }
});

router.post("/update-task", async (req, res) => {
  const { user_id, task_id, title, description, priority, due_date } = req.body;
  console.log("Updating task:", task_id, "for user:", user_id);

  if (!user_id || !task_id || !title || !description || !priority) {
    return res.status(400).json({
      error: "User ID, task ID, title, description, and priority are required",
    });
  }

  try {
    const result = await sql`
      UPDATE todo_list 
      SET title = ${title}, description = ${description}, priority = ${priority}, "dueDate" = ${
      due_date || null
    }
      WHERE id = ${task_id} AND user_id = ${user_id}
      RETURNING *
    `;

    if (result.length === 0) {
      return res.status(404).json({
        error: "Task not found or you don't have permission to update it",
      });
    }

    console.log("Task updated:", result[0]);
    res.status(200).json(result[0]);
  } catch (error) {
    console.error("Error updating task:", error);
    res.status(500).json({ error: "Failed to update task" });
  }
});

router.post("/delete-task", async (req, res) => {
  const { user_id, task_id } = req.body;
  console.log("Deleting task:", task_id, "for user:", user_id);

  if (!user_id || !task_id) {
    return res.status(400).json({ error: "User ID and task ID are required" });
  }

  try {
    const result = await sql`
      DELETE FROM todo_list 
      WHERE id = ${task_id} AND user_id = ${user_id}
      RETURNING *
    `;

    if (result.length === 0) {
      return res.status(404).json({
        error: "Task not found or you don't have permission to delete it",
      });
    }

    console.log("Task deleted:", result[0]);
    res.status(200).json({ message: "Task deleted successfully" });
  } catch (error) {
    console.error("Error deleting task:", error);
    res.status(500).json({ error: "Failed to delete task" });
  }
});

router.post("/complete-task", async (req, res) => {
  const { user_id, task_id } = req.body;
  console.log("Completing task:", task_id, "for user:", user_id);

  if (!user_id || !task_id) {
    return res.status(400).json({ error: "User ID and task ID are required" });
  }

  try {
    const result = await sql`
      UPDATE todo_list 
      SET "isCompleted" = true
      WHERE id = ${task_id} AND user_id = ${user_id}
      RETURNING *
    `;

    if (result.length === 0) {
      return res.status(404).json({
        error: "Task not found or you don't have permission to complete it",
      });
    }

    console.log("Task completed:", result[0]);
    res.status(200).json(result[0]);
  } catch (error) {
    console.error("Error completing task:", error);
    res.status(500).json({ error: "Failed to complete task" });
  }
});

module.exports = router;

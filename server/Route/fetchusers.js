const express = require("express");
const sql = require("../DB/connection");
const router = express.Router();

router.get("/users", async (req, res) => {
  try {
    console.log("Attempting to fetch users from PostgreSQL...");

    // Use the `postgres` tagged template literal to execute the SQL query
    const users = await sql`SELECT * FROM users`; // No need for query() method

    console.log("Successfully fetched users:", users);
    res.json(users); // Send the fetched users as response
  } catch (err) {
    console.error("Server error:", err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

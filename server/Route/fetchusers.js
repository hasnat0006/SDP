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

// Signup endpoint
router.post("/signup", async (req, res) => {
  try {
    const { email, password } = req.body;
    
    console.log("Attempting to create new user:", email);

    // Check if user already exists
    const existingUser = await sql`SELECT * FROM users WHERE email = ${email}`;
    
    if (existingUser.length > 0) {
      return res.status(400).json({ error: "User already exists with this email" });
    }

    // Insert new user (you may want to hash the password before storing)
    const newUser = await sql`
      INSERT INTO users (email, password) 
      VALUES (${email}, ${password}) 
      RETURNING id, email
    `;

    console.log("Successfully created user:", newUser[0]);
    res.status(201).json({ 
      message: "User created successfully", 
      user: newUser[0] 
    });
    
  } catch (err) {
    console.error("Signup error:", err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

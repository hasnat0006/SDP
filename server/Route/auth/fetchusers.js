const express = require("express");
const bcrypt = require("bcrypt");
const sql = require("../../DB/connection");
const router = express.Router();

router.get("/login", async (req, res) => {
  const { email, password } = req.query;
  if (!email || !password) {
    return res.status(400).json({ error: "Email and password are required" });
  }
  console.log("Login attempt for email:", email);
  
  try {
    // Fetch user by email
    const user = await sql`SELECT * FROM users WHERE email = ${email}`;
    
    if (user.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    // Verify password
    const isPasswordValid = await verifyPassword(password, user[0].en_pass);
    
    if (!isPasswordValid) {
      return res.status(401).json({ error: "Invalid password" });
    }

    // Return user details excluding password
    const { en_pass, ...userDetails } = user[0];
    res.status(200).json(userDetails);
    
  } catch (err) {
    console.error("Login error:", err);
    res.status(500).json({ error: err.message });
  }
});

// Signup endpoint
router.post("/signup", async (req, res) => {
  try {
    const { email, password, name, bdn, isPatient, emergencyContacts } = req.body;
    console.log("Attempting to create new user:", email);
    console.log("Emergency contacts:", emergencyContacts);
    
    // Check if user already exists
    const existingUser = await sql`SELECT * FROM users WHERE email = ${email}`;
    if (existingUser.length > 0) {
      return res
        .status(400)
        .json({ error: "User already exists with this email" });
    }

    // Hash the password before storing
    const hashedPassword = await encryptPassword(password);

    // Insert new user with hashed password
    const newUser = await sql`
      INSERT INTO users (email, en_pass, name, type) 
      VALUES (${email}, ${hashedPassword}, ${name}, ${
      isPatient ? "patient" : "doctor"
    }) 
      RETURNING id, email
    `;

    await postInOtherTable(newUser[0].id, bdn, isPatient, emergencyContacts);
    console.log("Successfully created user:", newUser[0]);
    res.status(201).json({
      message: "User created successfully",
      user: newUser[0],
    });
  } catch (err) {
    console.error("Signup error:", err);
    res.status(500).json({ error: err.message });
  }
});

// Add emergency contact update route
router.post("/update-emergency-contacts", async (req, res) => {
  try {
    const { userId, emergencyContacts } = req.body;
    console.log("Updating emergency contacts for user:", userId);
    console.log("Emergency contacts:", emergencyContacts);
    
    if (!emergencyContacts || !Array.isArray(emergencyContacts)) {
      return res.status(400).json({ error: "Emergency contacts must be an array" });
    }

    // Update patient table with emergency contacts
    const result = await sql`
      UPDATE patient 
      SET emergency_contact = ${emergencyContacts}
      WHERE user_id = ${userId}
    `;

    if (result.count === 0) {
      return res.status(404).json({ error: "Patient not found" });
    }

    console.log("Successfully updated emergency contacts");
    res.status(200).json({
      message: "Emergency contacts updated successfully",
      contacts: emergencyContacts
    });
  } catch (err) {
    console.error("Update emergency contacts error:", err);
    res.status(500).json({ error: err.message });
  }
});

async function postInOtherTable(userId, bdn, isPatient, emergencyContacts = null) {
  if (isPatient) {
    // Logic to insert into patient table with emergency contacts
    if (emergencyContacts && Array.isArray(emergencyContacts)) {
      await sql`
        INSERT INTO patient (user_id, emergency_contact) 
        VALUES (${userId}, ${emergencyContacts})
      `;
    } else {
      await sql`
        INSERT INTO patient (user_id) 
        VALUES (${userId})
      `;
    }
  } else {
    // Logic to insert into doctor table
    await sql`
      INSERT INTO doctor (doc_id, bdn) 
      VALUES (${userId}, ${bdn})
    `;
  }
}

async function encryptPassword(password) {
  const saltRounds = 12; // Higher value = more secure but slower
  return await bcrypt.hash(password, saltRounds);
}

// Function to verify password during login
async function verifyPassword(plainPassword, hashedPassword) {
  return await bcrypt.compare(plainPassword, hashedPassword);
}

// Get user by ID endpoint
router.get("/user/:userId", async (req, res) => {
  const { userId } = req.params;
  
  try {
    console.log("Fetching user details for ID:", userId);
    
    // Fetch user by ID
    const user = await sql`SELECT id, email, name, type FROM users WHERE id = ${userId}`;
    
    if (user.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    // Return user details excluding password
    res.status(200).json(user[0]);
    
  } catch (err) {
    console.error("Fetch user error:", err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

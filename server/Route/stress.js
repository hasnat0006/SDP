const express = require("express");
const sql = require("../DB/connection");
const router = express.Router();

// Store stress tracking data
router.post("/track", async (req, res) => {
  try {
    const { user_id, stress_level, cause, logged_symptoms, Notes, date } = req.body;
    
    const result = await sql`
      INSERT INTO stress_tracker (
        user_id, 
        stress_level, 
        cause, 
        logged_symptoms, 
        notes, 
        date
      ) 
      VALUES (
        ${user_id}, 
        ${stress_level}, 
        ${cause}, 
        ${logged_symptoms}, 
        ${Notes}, 
        ${date}
      )
      RETURNING *
    `;

    res.status(201).json(result[0]);
  } catch (err) {
    console.error("Error saving stress data:", err);
    res.status(500).json({ error: err.message });
  }
});

// Get stress data for a specific user
router.get("/data/:userId", async (req, res) => {
  try {
    const { userId } = req.params;
    console.log("User ID:", userId);
    const result = await sql`
      SELECT * FROM stress_tracker 
      WHERE user_id = ${userId}
      ORDER BY date DESC
      LIMIT 1
    `;

    if (result.length === 0) {
      return res.status(404).json({ error: "No stress data found" });
    }

    res.json(result[0]);
  } catch (err) {
    console.error("Error retrieving stress data:", err);
    res.status(500).json({ error: err.message });
  }
});

// Get stress data for a specific user and date
router.get("/data/:userId/:date", async (req, res) => {
  try {
    const { userId, date } = req.params;
    console.log("User ID:", userId, "Date:", date);
    
    const result = await sql`
      SELECT * FROM stress_tracker 
      WHERE user_id = ${userId} AND DATE(date) = ${date}
      ORDER BY date DESC
      LIMIT 1
    `;

    if (result.length === 0) {
      return res.status(404).json({ 
        message: "No stress data found for this date",
        data: null 
      });
    }

    res.json(result[0]);
  } catch (err) {
    console.error("Error retrieving stress data for date:", err);
    res.status(500).json({ error: err.message });
  }
});

// Get weekly stress data for a user
router.get("/weekly/:userId", async (req, res) => {
  try {
    const { userId } = req.params;
    
    const result = await sql`
      SELECT 
        date_trunc('day', date) as day,
        AVG(stress_level)::numeric(10,2) as avg_stress_level,
        json_agg(DISTINCT cause) as causes,
        json_agg(DISTINCT logged_symptoms) as symptoms
      FROM stress_tracker 
      WHERE 
        user_id = ${userId}
        AND date >= NOW() - INTERVAL '7 days'
      GROUP BY date_trunc('day', date)
      ORDER BY day DESC
    `;

    res.json(result);
  } catch (err) {
    console.error("Error retrieving weekly stress data:", err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

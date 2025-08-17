const express = require("express");
const sql = require("../DB/connection");
const router = express.Router();

// Test route
router.get("/test", (req, res) => {
  console.log("Sleep test route hit!");
  res.json({ message: "Sleep route is working" });
});

// Store sleep tracking data
router.post("/track", async (req, res) => {
  try {
    const { user_id, hours_slept, sleep_quality, bedtime, wake_time, date } = req.body;
    
    const result = await sql`
      INSERT INTO sleep_tracker (
        user_id, 
        hours_slept, 
        sleep_quality, 
        bedtime, 
        wake_time, 
        date
      ) 
      VALUES (
        ${user_id}, 
        ${hours_slept}, 
        ${sleep_quality}, 
        ${bedtime}, 
        ${wake_time}, 
        (${date}::timestamp AT TIME ZONE '+06:00')::timestamp with time zone
      )
      RETURNING *
    `;

    res.status(201).json(result[0]);
  } catch (err) {
    console.error("Error saving sleep data:", err);
    res.status(500).json({ error: err.message });
  }
});

// Get sleep data for a specific user (latest entry)
router.get("/data/:userId", async (req, res) => {
  try {
    const { userId } = req.params;
    console.log("User ID:", userId);
    const result = await sql`
      SELECT * FROM sleep_tracker 
      WHERE user_id = ${userId}
      ORDER BY date DESC
      LIMIT 1
    `;

    if (result.length === 0) {
      return res.status(404).json({ 
        message: "No sleep data found for this user",
        data: null 
      });
    }

    res.json(result[0]);
  } catch (err) {
    console.error("Error retrieving sleep data:", err);
    res.status(500).json({ error: err.message });
  }
});

// Get sleep data for a specific user and date
router.get("/data/:userId/:date", async (req, res) => {
  try {
    const { userId, date } = req.params;
    console.log("User ID:", userId, "Date:", date);
    
    // First try to get data without timezone conversion to debug
    console.log("Searching for sleep data - User:", userId, "Date:", date);
    const result = await sql`
      SELECT *, DATE(date) as date_only FROM sleep_tracker 
      WHERE user_id = ${userId}
      ORDER BY date DESC
    `;
    
    console.log("All sleep data for user:", result.map(r => ({id: r.id, date: r.date, date_only: r.date_only, hours: r.sleep_hours})));
    
    // Filter for the specific date
    const filteredResult = result.filter(r => r.date_only === date);
    console.log("Filtered result for date", date, ":", filteredResult);

    if (filteredResult.length === 0) {
      return res.status(404).json({ 
        message: "No sleep data found for this date",
        data: null 
      });
    }

    res.json(filteredResult[0]);
  } catch (err) {
    console.error("Error retrieving sleep data for date:", err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

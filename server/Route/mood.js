const express = require("express");
const sql = require("../DB/connection");
const router = express.Router();

// Store mood tracking data
router.post("/track", async (req, res) => {
  try {
    const { user_id, mood_status, mood_level, reason, date } = req.body;
    
    console.log('📝 Received mood data:', {
      user_id,
      mood_status,
      mood_level,
      reason,
      date
    });
    
    // Ensure reason is properly formatted as an array
    const reasonArray = Array.isArray(reason) ? reason : [];
    
    const result = await sql`
      INSERT INTO mood_tracker (
        user_id, 
        mood_status, 
        mood_level, 
        reason, 
        date
      ) 
      VALUES (
        ${user_id}, 
        ${mood_status}, 
        ${mood_level}, 
        ${reasonArray}, 
        ${date}
      )
      RETURNING *
    `;

    console.log('✅ Mood data saved successfully:', result[0]);
    res.status(201).json(result[0]);
  } catch (err) {
    console.error("❌ Error saving mood data:", err);
    res.status(500).json({ error: err.message });
  }
});

// Get mood data for a specific user (latest entry)
router.get("/data/:userId", async (req, res) => {
  try {
    const { userId } = req.params;
    console.log("User ID:", userId);
    const result = await sql`
      SELECT * FROM mood_tracker 
      WHERE user_id = ${userId}
      ORDER BY date DESC
      LIMIT 1
    `;

    if (result.length === 0) {
      return res.status(404).json({ 
        message: "No mood data found for this user",
        data: null 
      });
    }

    // Ensure reason is always an array
    const moodData = result[0];
    if (moodData.reason && !Array.isArray(moodData.reason)) {
      moodData.reason = [moodData.reason];
    } else if (!moodData.reason) {
      moodData.reason = [];
    }

    console.log('✅ Latest mood data retrieved:', moodData);
    res.json(moodData);
  } catch (err) {
    console.error("Error retrieving mood data:", err);
    res.status(500).json({ error: err.message });
  }
});

// Get mood data for a specific user and date
router.get("/data/:userId/:date", async (req, res) => {
  try {
    const { userId, date } = req.params;
    console.log("User ID:", userId, "Date:", date);
    
    const result = await sql`
      SELECT * FROM mood_tracker 
      WHERE user_id = ${userId} AND DATE(date) = ${date}
      ORDER BY date DESC
      LIMIT 1
    `;

    if (result.length === 0) {
      return res.status(404).json({ 
        message: "No mood data found for this date",
        data: null 
      });
    }

    // Ensure reason is always an array
    const moodData = result[0];
    if (moodData.reason && !Array.isArray(moodData.reason)) {
      moodData.reason = [moodData.reason];
    } else if (!moodData.reason) {
      moodData.reason = [];
    }

    console.log('✅ Mood data for date retrieved:', moodData);
    res.json(moodData);
  } catch (err) {
    console.error("Error retrieving mood data for date:", err);
    res.status(500).json({ error: err.message });
  }
});

// Get weekly mood data for a user
router.get("/weekly/:userId", async (req, res) => {
  try {
    const { userId } = req.params;
    const result = await sql`
      SELECT 
        DATE(date) as date,
        mood_status,
        mood_level,
        reason
      FROM mood_tracker 
      WHERE user_id = ${userId} 
        AND date >= CURRENT_DATE - INTERVAL '7 days'
      ORDER BY date DESC
    `;

    if (result.length === 0) {
      return res.status(404).json({ 
        message: "No mood data found for the past week",
        data: [] 
      });
    }

    // Ensure reason is always an array for each entry
    const processedData = result.map(entry => {
      if (entry.reason && !Array.isArray(entry.reason)) {
        entry.reason = [entry.reason];
      } else if (!entry.reason) {
        entry.reason = [];
      }
      return entry;
    });

    console.log('✅ Weekly mood data retrieved:', processedData);
    res.json(processedData);
  } catch (err) {
    console.error("Error retrieving weekly mood data:", err);
    res.status(500).json({ error: err.message });
  }
});

// Get monthly mood data for weekly overview
router.get("/monthly/:userId/:year/:month", async (req, res) => {
  try {
    const { userId, year, month } = req.params;
    
    const result = await sql`
      SELECT 
        DATE(date) as date,
        mood_status,
        mood_level,
        reason,
        EXTRACT(WEEK FROM date) - EXTRACT(WEEK FROM DATE_TRUNC('month', date)) + 1 as week_number
      FROM mood_tracker 
      WHERE user_id = ${userId} 
        AND EXTRACT(YEAR FROM date) = ${year}
        AND EXTRACT(MONTH FROM date) = ${month}
      ORDER BY date ASC
    `;

    if (result.length === 0) {
      return res.status(404).json({ 
        message: "No mood data found for this month",
        data: [] 
      });
    }

    // Group by weeks
    const weeklyData = {};
    result.forEach(entry => {
      // Ensure reason is always an array
      if (entry.reason && !Array.isArray(entry.reason)) {
        entry.reason = [entry.reason];
      } else if (!entry.reason) {
        entry.reason = [];
      }
      
      const week = `Week ${entry.week_number}`;
      if (!weeklyData[week]) {
        weeklyData[week] = [];
      }
      weeklyData[week].push(entry);
    });

    console.log('✅ Monthly mood data retrieved:', weeklyData);
    res.json(weeklyData);
  } catch (err) {
    console.error("Error retrieving monthly mood data:", err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

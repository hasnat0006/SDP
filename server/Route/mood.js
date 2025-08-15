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
        (${date}::timestamp AT TIME ZONE '+06:00')::timestamp with time zone
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
    
    // Convert the date to local timezone (UTC+6 for Dhaka) before comparing
    const result = await sql`
      SELECT * FROM mood_tracker 
      WHERE user_id = ${userId} 
      AND DATE(date AT TIME ZONE 'UTC' AT TIME ZONE '+06:00') = ${date}
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

// Get weekly mood data for a user (current week Monday to Sunday)
router.get("/weekly/:userId", async (req, res) => {
  try {
    const { userId } = req.params;
    
    // Get data for a wider range to ensure we catch all relevant data
    const result = await sql`
      SELECT 
        DATE(date AT TIME ZONE 'UTC' AT TIME ZONE '+06:00') as date,
        mood_status,
        mood_level,
        reason,
        EXTRACT(DOW FROM date AT TIME ZONE 'UTC' AT TIME ZONE '+06:00') as day_of_week,
        TO_CHAR(date AT TIME ZONE 'UTC' AT TIME ZONE '+06:00', 'YYYY-MM-DD') as formatted_date
      FROM mood_tracker 
      WHERE user_id = ${userId} 
        AND date AT TIME ZONE 'UTC' AT TIME ZONE '+06:00' >= CURRENT_DATE - INTERVAL '10 days'
        AND date AT TIME ZONE 'UTC' AT TIME ZONE '+06:00' <= CURRENT_DATE + INTERVAL '3 days'
      ORDER BY date ASC
    `;

    console.log('📊 Weekly query for user:', userId);
    console.log('📊 Query date range: CURRENT_DATE - 10 days to CURRENT_DATE + 3 days');
    console.log('📊 Raw query result:', JSON.stringify(result.map(r => ({
      date: r.date,
      formatted_date: r.formatted_date,
      mood_status: r.mood_status,
      day_of_week: r.day_of_week
    })), null, 2));
    
    // Always return an array, even if empty
    const processedData = result.map(entry => {
      if (entry.reason && !Array.isArray(entry.reason)) {
        entry.reason = [entry.reason];
      } else if (!entry.reason) {
        entry.reason = [];
      }
      
      console.log('📊 Processing entry:', {
        date: entry.date,
        formatted_date: entry.formatted_date,
        mood_status: entry.mood_status,
        mood_level: entry.mood_level,
        day_of_week: entry.day_of_week
      });
      
      return entry;
    });

    console.log('✅ Weekly mood data processed:', processedData.length, 'entries');
    console.log('✅ Final processed data:', JSON.stringify(processedData, null, 2));
    res.json(processedData);
  } catch (err) {
    console.error("❌ Error retrieving weekly mood data:", err);
    res.status(500).json({ error: err.message });
  }
});

// Get monthly mood data for weekly overview
router.get("/monthly/:userId/:year/:month", async (req, res) => {
  try {
    const { userId, year, month } = req.params;
    
    const result = await sql`
      SELECT 
        DATE(date AT TIME ZONE 'UTC' AT TIME ZONE '+06:00') as date,
        mood_status,
        mood_level,
        reason,
        EXTRACT(WEEK FROM date AT TIME ZONE 'UTC' AT TIME ZONE '+06:00') - EXTRACT(WEEK FROM DATE_TRUNC('month', date AT TIME ZONE 'UTC' AT TIME ZONE '+06:00')) + 1 as week_number
      FROM mood_tracker 
      WHERE user_id = ${userId} 
        AND EXTRACT(YEAR FROM date AT TIME ZONE 'UTC' AT TIME ZONE '+06:00') = ${year}
        AND EXTRACT(MONTH FROM date AT TIME ZONE 'UTC' AT TIME ZONE '+06:00') = ${month}
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

// Get yearly mood data (12 months)
router.get("/yearly/:userId/:year", async (req, res) => {
  try {
    const { userId, year } = req.params;
    
    const result = await sql`
      SELECT 
        EXTRACT(MONTH FROM date AT TIME ZONE 'UTC' AT TIME ZONE '+06:00') as month,
        AVG(mood_level::float) as avg_mood_level,
        COUNT(*) as entry_count
      FROM mood_tracker 
      WHERE user_id = ${userId} 
        AND EXTRACT(YEAR FROM date AT TIME ZONE 'UTC' AT TIME ZONE '+06:00') = ${year}
      GROUP BY EXTRACT(MONTH FROM date AT TIME ZONE 'UTC' AT TIME ZONE '+06:00')
      ORDER BY month ASC
    `;

    if (result.length === 0) {
      return res.status(404).json({ 
        message: "No mood data found for this year",
        data: [] 
      });
    }

    console.log('✅ Yearly mood data retrieved:', result);
    res.json(result);
  } catch (err) {
    console.error("❌ Error retrieving yearly mood data:", err);
    res.status(500).json({ error: err.message });
  }
});

// Get all-time mood data
router.get("/all-time/:userId", async (req, res) => {
  try {
    const { userId } = req.params;
    
    const result = await sql`
      SELECT 
        EXTRACT(YEAR FROM date AT TIME ZONE 'UTC' AT TIME ZONE '+06:00') as year,
        AVG(mood_level::float) as avg_mood_level,
        COUNT(*) as entry_count
      FROM mood_tracker 
      WHERE user_id = ${userId}
      GROUP BY EXTRACT(YEAR FROM date AT TIME ZONE 'UTC' AT TIME ZONE '+06:00')
      ORDER BY year ASC
    `;

    if (result.length === 0) {
      return res.status(404).json({ 
        message: "No mood data found",
        data: [] 
      });
    }

    console.log('✅ All-time mood data retrieved:', result);
    res.json(result);
  } catch (err) {
    console.error("❌ Error retrieving all-time mood data:", err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

const express = require("express");
const sql = require("../DB/connection");
const router = express.Router();

// Store sleep tracking data
router.post("/track", async (req, res) => {
  try {
    const { user_id, sleep_hours, sleep_quality, bedtime, wake_time, date } =
      req.body;

    const result = await sql`
      INSERT INTO sleep_tracker (
        user_id, 
        sleep_hours, 
        sleep_quality, 
        bedtime, 
        wake_time, 
        date
      ) 
      VALUES (
        ${user_id}, 
        ${sleep_hours}, 
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
    //console.log("User ID:", userId);
    const result = await sql`
      SELECT * FROM sleep_tracker 
      WHERE user_id = ${userId}
      ORDER BY date DESC
      LIMIT 1
    `;

    if (result.length === 0) {
      return res.status(404).json({
        message: "No sleep data found for this user",
        data: null,
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
    //console.log("Sleep API - User ID:", userId, "Date:", date);

    const result = await sql`
      SELECT * FROM sleep_tracker 
      WHERE user_id = ${userId} 
      AND DATE(date) = ${date}
      ORDER BY date DESC
      LIMIT 1
    `;

    console.log("Sleep data query result:", result);

    if (result.length === 0) {
      console.log("No sleep data found for date:", date);
      return res.status(404).json({
        message: "No sleep data found for this date",
        data: null,
      });
    }

    console.log("Returning sleep data:", result[0]);
    res.json(result[0]);
  } catch (err) {
    console.error("Error retrieving sleep data for date:", err);
    res.status(500).json({ error: err.message });
  }
});

router.post("/sleepinput", async (req, res) => {
  try {
    const { hours, date, userId } = req.body;
    //console.log("This is sleep req body: ", req.body);
    const result = await sql`
        INSERT INTO sleep_tracker (user_id, date, sleep_hours)
        VALUES (${userId}, ${date}, ${hours})`;
    res.status(201).json({ message: "Sleep hours logged successfully" });
  } catch (err) {
    console.error("Error in recorning sleep input", err);
    res.status(500).json({ error: err.message });
  }
});

router.get("/getsleephours/:userId", async (req, res) => {
  try {
    const { userId } = req.params;

    console.log("Here is user id: ", userId);

    // Query to get the sleep time from the database
    const result = await sql`
        SELECT sleep_time FROM users WHERE id = ${userId}`;

    // Check if the result is empty (no sleep time found)
    if (result.length === 0) {
      return res
        .status(404)
        .json({ error: "No sleep time found for this user" });
    }

    // Send only the sleep_time in the response
    
    return res.status(200).json(result[0].sleep_time);
  } catch (err) {
    console.log("Error in getting sleep hours", err);
    // Sending a 500 error response in case of failure
    return res.status(500).json({ error: err.message });
  }
});

router.get("/check/:userId/:datefinal", async (req, res) => {
  try {
    const { userId, datefinal } = req.params;
    console.log("Req params", req.params);

    const result = await sql`SELECT sleep_hours 
  FROM sleep_tracker 
  WHERE user_id = ${userId} AND date = ${datefinal}`;

    console.log(result[0]);
    res.json(result[0]);
  } catch (err) {
    console.log("error in sleep", err);
    res.status(500).json({ error: err.message });
  }
});
module.exports = router;

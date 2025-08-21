const express = require("express");
const sql = require("../DB/connection");
const router = express.Router();

// Middleware to parse JSON bodies
router.use(express.json()); // This is critical for parsing JSON request bodies// parses JSON
router.use(express.urlencoded({ extended: true })); // parses form-data

router.post("/sleepinput", async (req, res) => {
  try {
    const { hours, date, userId } = req.body;
    console.log("This is sleep req body: ", req.body);
    const result = await sql`
        INSERT INTO sleep_tracker (user_id, date, sleep_hours)
        VALUES (${userId}, ${date}, ${hours})`;
    res.status(201).json({ message: "Sleep hours logged successfully" });
  } catch (err) {
    console.error("Error in recorning sleep input", err);
    res.status(500).json({ error: err.message });
  }
});
module.exports = router;

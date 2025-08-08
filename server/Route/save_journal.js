const express = require("express");
const sql = require("../DB/connection");
const router = express.Router();

router.post("/journal", async (req, res) => {
  try {
    const { user_id, title, information, date, time } = req.body;

    if (!user_id || !title || !information || !date || !time) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    // Insert journal entry with provided time
    const newJournal = await sql`
      INSERT INTO journal (user_id, title, information, date, time)
      VALUES (${user_id}, ${title}, ${information}, ${date}, ${time})
      RETURNING *;
    `;

    res.status(201).json({
      message: "Journal saved successfully",
      journal: newJournal[0],
    });
  } catch (error) {
    console.error("Error saving journal:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

module.exports = router;

const express = require("express");
const sql = require("../DB/connection");
const router = express.Router();

router.post("/journal", async (req, res) => {
  try {
    console.log('Full request body:', JSON.stringify(req.body));
    const { user_id, title, information, date, time, mood, mood_color } = req.body;
    
    console.log('Extracted mood:', mood);
    console.log('Extracted mood_color:', mood_color);

    if (!user_id || !title || !information || !date || !time) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    const finalMood = mood || 'neutral';
    const finalMoodColor = mood_color || '#EEDCF9';

    console.log('Final mood to insert:', finalMood);
    console.log('Final mood_color to insert:', finalMoodColor);

    const newJournal = await sql`
      INSERT INTO journal (user_id, title, information, date, time, mood, mood_color)
      VALUES (${user_id}, ${title}, ${information}, ${date}, ${time}, ${finalMood}, ${finalMoodColor})
      RETURNING *;
    `;

    console.log('Journal created:', newJournal[0]);

    res.status(201).json({
      message: "Journal saved successfully",
      journal: newJournal[0],
    });

  } catch (error) {
    console.error("Error saving journal:", error);
    console.error("Stack trace:", error.stack);
    res.status(500).json({ 
      error: "Internal server error", 
      details: error.message 
    });
  }
});

module.exports = router;

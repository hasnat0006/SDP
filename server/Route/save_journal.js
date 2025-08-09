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

    try {
      // Try inserting without mood first
      const newJournal = await sql`
        INSERT INTO journal (user_id, title, information, date, time)
        VALUES (${user_id}, ${title}, ${information}, ${date}, ${time})
        RETURNING *;
      `;

      console.log('Basic journal entry created, now updating with mood');
      
      // Then update with mood data
      const updatedJournal = await sql`
        UPDATE journal 
        SET mood = ${finalMood}, mood_color = ${finalMoodColor}
        WHERE j_id = ${newJournal[0].j_id}
        RETURNING *;
      `;

      console.log('Journal updated with mood:', updatedJournal[0]);

      res.status(201).json({
        message: "Journal saved successfully",
        journal: updatedJournal[0],
      });
    } catch (dbError) {
      console.error("Database error:", dbError);
      console.error("Error message:", dbError.message);
      console.error("Error detail:", dbError.detail);
      
      // Try a different approach with default mood if the first approach failed
      try {
        console.log('First approach failed, trying alternative approach');
        const newJournal = await sql`
          INSERT INTO journal (user_id, title, information, date, time, mood, mood_color)
          VALUES (${user_id}, ${title}, ${information}, ${date}, ${time}, 'neutral', '#EEDCF9')
          RETURNING *;
        `;

        console.log('Alternative approach succeeded:', newJournal[0]);
        res.status(201).json({
          message: "Journal saved successfully (with default mood)",
          journal: newJournal[0],
        });
      } catch (fallbackError) {
        console.error("Fallback approach also failed:", fallbackError);
        throw new Error(`Both database approaches failed: ${fallbackError.message}`);
      }
    }
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

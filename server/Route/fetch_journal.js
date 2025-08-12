const express = require("express");
const sql = require("../DB/connection");
const router = express.Router();

router.get("/journal", async (req, res) => {
  try {
    const { user_id } = req.query;

    if (!user_id) {
      return res.status(400).json({ error: "Missing user_id" });
    }

    // Include mood and mood_color in the SELECT statement
    const journals = await sql`
      SELECT j_id, date, time, title, information, mood, mood_color FROM journal
      WHERE user_id = ${user_id}
      ORDER BY date DESC, time DESC;
    `;

    console.log("Fetched journals with mood data:", journals);
    res.status(200).json({ journals });
  } catch (error) {
    console.error("Error fetching journal:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

router.post('/journal/update', async (req, res) => {
  const { id, title, description, mood, mood_color } = req.body;
  console.log('Update request received:', req.body);

  if (!id || !title || !description || !mood) {
    return res.status(400).json({ error: 'Missing fields' });
  }

  const finalMoodColor = mood_color || '#EEDCF9';

  try {
    const updatedJournal = await sql`
      UPDATE journal
      SET title = ${title}, information = ${description}, mood = ${mood}, mood_color = ${finalMoodColor}
      WHERE j_id = ${id}
      RETURNING *;
    `;
    
    if (updatedJournal.length === 0) {
      return res.status(404).json({ error: 'Journal not found' });
    }

    console.log('Journal updated successfully:', updatedJournal[0]);
    res.json({ success: true, journal: updatedJournal[0] });
  } catch (err) {
    console.error('Error updating journal:', err);
    res.status(500).json({ error: 'Database error' });
  }
});

router.post('/journal/delete', async (req, res) => {
  const { id } = req.body;
  console.log('Delete request received:', req.body);

  if (!id) {
    return res.status(400).json({ error: 'Missing journal ID' });
  }

  try {
    await sql`
      DELETE FROM journal
      WHERE j_id = ${id}
    `;
    res.json({ success: true });
  } catch (err) {
    console.error('Error deleting journal:', err);
    res.status(500).json({ error: 'Database error' });
  }
});

module.exports = router;

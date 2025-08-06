const express = require("express");
const sql = require("../DB/connection");
const router = express.Router();

router.get("/journal", async (req, res) => {
  try {
    const { user_id } = req.query;

    if (!user_id) {
      return res.status(400).json({ error: "Missing user_id" });
    }

    const journals = await sql`
      SELECT j_id, date, time, title, information FROM journal
      WHERE user_id = ${user_id}
      ORDER BY date DESC, time DESC;
    `;

    // ✅ Wrap in a map so Flutter gets Map<String, dynamic>
    console.log("Fetched journals:", journals);
    res.status(200).json({ journals });
  } catch (error) {
    console.error("Error fetching journal:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

router.post('/journal/update', async (req, res) => {
  const { id, title, description } = req.body;
  console.log('Update request received:', req.body);

  if (!id || !title || !description) {
    return res.status(400).json({ error: 'Missing fields' });
  }

  try {
    await sql`
      UPDATE journal
      SET title = ${title}, information = ${description}
      WHERE j_id = ${id}
    `;
    res.json({ success: true });
  } catch (err) {
    console.error('Error updating journal:', err);
    res.status(500).json({ error: 'Database error' });
  }
});




module.exports = router;

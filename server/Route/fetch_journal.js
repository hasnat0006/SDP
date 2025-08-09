const express = require("express");
const sql = require("../DB/connection");
const router = express.Router();

router.get("/journal", async (req, res) => {
  try {
    const { user_id } = req.query; // Get user_id from query parameters
    
    console.log('📡 Fetching journals for user:', user_id);
    
    if (!user_id) {
      return res.status(400).json({ error: 'User ID is required' });
    }

    const result = await sql`
      SELECT j_id, user_id, title, information, date, time 
      FROM journal 
      WHERE user_id = ${user_id}
      ORDER BY date DESC, time DESC
    `;
    
    console.log(`📚 Found ${result.length} journals for user ${user_id}`);
    
    res.json({ journals: result });
  } catch (error) {
    console.error('❌ Error fetching journals:', error);
    res.status(500).json({ error: 'Database error' });
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

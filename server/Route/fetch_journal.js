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
      SELECT * FROM journal
      WHERE user_id = ${user_id}
      ORDER BY date DESC, time DESC;
    `;

    // ✅ Wrap in a map so Flutter gets Map<String, dynamic>
    res.status(200).json({ journals });
  } catch (error) {
    console.error("Error fetching journal:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});



module.exports = router;

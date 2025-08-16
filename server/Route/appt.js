const express = require("express");
const sql = require("../DB/connection");
const router = express.Router();

// Fetching therapist details

router.get("/therapists", async (req, res) => {
  try {
    const result = await sql`
        SELECT * from doctor`;
    if (result.length === 0) {
      return res.status(404).json({ error: "No therapists found" });
    }
    res.json(result[0]);
    console.log(result[0]);
  } catch (err) {
    console.error("Error retrieving therapist data:", err);
    res.status(500).json({ error: err.message });
  }
});
// router.get("/data/:userId", async (req, res) => {
//   try {
//     const { userId } = req.params;
//     console.log("User ID:", userId);
//     const result = await sql`
//       SELECT * FROM stress_tracker
//       WHERE user_id = ${userId}
//       ORDER BY date DESC
//       LIMIT 1
//     `;

//     if (result.length === 0) {
//       return res.status(404).json({ error: "No stress data found" });
//     }

//     res.json(result[0]);
//   } catch (err) {
//     console.error("Error retrieving stress data:", err);
//     res.status(500).json({ error: err.message });
//   }
// });
module.exports = router;

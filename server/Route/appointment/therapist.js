const express = require("express");
const sql = require("../../DB/connection");
const router = express.Router();

// Middleware to parse JSON bodies
router.use(express.json()); // This is critical for parsing JSON request bodies// parses JSON
router.use(express.urlencoded({ extended: true })); // parses form-data

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

module.exports = router;

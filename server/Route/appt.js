const express = require("express");
const sql = require("../DB/connection");
const router = express.Router();

// Fetching therapist details

router.get("/therapists", (req, res) => {
  sql.query('SELECT * FROM users WHERE type = "doctor"', (err, results) => {
    if (err) {
      res.status(500).json({ error: "Error fetching data" });
      return;
    }
    res.status(200).json(results); // Return therapist data in JSON format
  });
});

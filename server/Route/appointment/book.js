const express = require("express");
const sql = require("../../DB/connection");
const router = express.Router();

// Middleware to parse JSON bodies
router.use(express.json()); // This is critical for parsing JSON request bodies// parses JSON
router.use(express.urlencoded({ extended: true })); // parses form-data

router.post("/booked", async (req, res) => {
  try {
    const { docId, userId, name, institution, date, time, reason, email } =
      req.body;
    console.log("This is req body", req.body);

    if (
      !userId ||
      !name ||
      !institution ||
      !date ||
      !time ||
      !reason ||
      !docId
    ) {
      return res.status(400).json({ error: "Missing required fields" });
    }
    const status = "Pending";
    console.log(status);
    const result = await sql`
      INSERT INTO appointment (doc_id, user_id, status, time, date, reason, reminder, email)
      VALUES (${docId}, ${userId}, 'Pending' , ${time}, ${date}, ${reason}, 'yes', ${email})
    `;
    res.status(201).json({ message: "Appointment booked successfully" });
  } catch (err) {
    console.error("Error booking appointment:", err);
    res.status(500).json({ error: err.message });
  }
});
module.exports = router;

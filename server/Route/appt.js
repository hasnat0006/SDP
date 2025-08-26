const express = require("express");
const sql = require("../DB/connection");
const router = express.Router();

// Middleware to parse JSON bodies
router.use(express.json()); // This is critical for parsing JSON request bodies// parses JSON
router.use(express.urlencoded({ extended: true })); // parses form-data

router.post("/therapists", async (req, res) => {
  try {
    const result = await sql`
        SELECT doc_id, bdn, institute, name, shortbio, education, description, special, exp, dob, accept_patient, profession, gender 
        FROM doctor, users WHERE 
          users.id = doctor.doc_id AND
         type = 'doctor'`;
    if (result.length === 0) {
      return res.status(404).json({ error: "No therapists found" });
    }
    res.json(result);
    console.log(result);
  } catch (err) {
    console.error("Error retrieving therapist data:", err);
    res.status(500).json({ error: err.message });
  }
});
router.post("/booked", async (req, res) => {
  try {
    const { docId, userId, name, institution, date, time, reason, email } =
      req.body;
    console.log("This is req body", req.body);
    const query =
      await sql`SELECT time from appointment where time = ${time} and doc_id = ${docId} and date = ${date}`;
    console.log("Existing time slot: ", query[0]);

    if (query[0]) {
      console.log("Already booked");
      return res.status(409).json({ error: "Slot already booked" });
    } else {
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
    }
  } catch (err) {
    console.error("Error booking appointment:", err);
    res.status(500).json({ error: err.message });
  }
});

router.get("/yourappt/:userId", async (req, res) => {
  try {
    const { userId } = req.params;
    console.log("Fetching appointments for user ID:", userId);
    
    const result = await sql`
      SELECT 
        a.app_id as appointment_id,
        a.doc_id,
        a.user_id,
        a.status,
        a.time,
        a.date,
        a.reason,
        a.email,
        d.profession,
        d.institute as location,
        u.name,
        CONCAT(a.date, ' ', a.time) as datetime
      FROM appointment a
      JOIN doctor d ON a.doc_id = d.doc_id
      JOIN users u ON d.doc_id = u.id
      WHERE a.user_id = ${userId}
      ORDER BY a.date DESC, a.time DESC
    `;
    
    console.log(`Found ${result.length} appointments`);
    res.json(result);
  } catch (err) {
    console.error("Error retrieving appointments:", err);
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

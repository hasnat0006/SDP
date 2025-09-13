const express = require("express");
const sql = require("../DB/connection");
const router = express.Router();

// Middleware to parse JSON bodies
router.use(express.json()); // This is critical for parsing JSON request bodies// parses JSON
router.use(express.urlencoded({ extended: true })); // parses form-data

router.post("/therapists", async (req, res) => {
  try {
    const result = await sql`      
     SELECT d.doc_id, d.bdn, d.institute, u.name, d.shortbio, d.education, d.description, d.special, d.exp, d.dob, d.accept_patient, d.profession, d.gender, "profileImage"
        FROM doctor d, users u WHERE 
          u.id = d.doc_id AND
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

router.get("/appointments/:userId", async (req, res) => {
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
        u.name
      FROM appointment a
      JOIN doctor d ON a.doc_id = d.doc_id
      JOIN users u ON a.doc_id = u.id  -- Changed this join condition
      WHERE a.user_id = ${userId}
      ORDER BY a.date DESC, a.time DESC
    `;

    // Format the response
    const formattedResult = result.map((appt) => ({
      appointment_id: appt.appointment_id,
      name: appt.name,
      profession: appt.profession,
      location: appt.location,
      time: appt.time,
      datetime: appt.date,
      status: appt.status,
      reason: appt.reason,
      email: appt.email,
    }));

    console.log(`Found ${result.length} appointments`);
    console.log("Formatted appointments:", formattedResult);
    res.json(formattedResult);
  } catch (err) {
    console.error("Error retrieving appointments:", err);
    res.status(500).json({ error: err.message });
  }
});

// Update the route to accept POST with body instead of URL params
router.post("/cancel-appointment", async (req, res) => {
  try {
    const { appointmentId } = req.body;
    console.log("Cancelling appointment:", appointmentId);

    if (!appointmentId) {
      return res.status(400).json({ error: "Appointment ID is required" });
    }

    const result = await sql`
      UPDATE appointment 
      SET status = 'Cancelled'
      WHERE app_id = ${appointmentId}
      RETURNING *
    `;

    if (result.length === 0) {
      return res.status(404).json({ error: "Appointment not found" });
    }

    console.log("Appointment cancelled successfully");
    res.json({ message: "Appointment cancelled successfully" });
  } catch (err) {
    console.error("Error cancelling appointment:", err);
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

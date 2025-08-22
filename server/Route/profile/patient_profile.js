const express = require("express");
const sql = require("../../DB/connection");
const router = express.Router();

router.get("/get-info", async (req, res) => {
  try {
    const { user_id, user_type } = req.query;

    if (!user_id || !user_type) {
      return res.status(400).json({ error: "Missing user_id or user_type" });
    }
    console.log("Fetching profile information for:", user_id, user_type);
    const result =
      user_type === "patient"
        ? await sql`
      SELECT * FROM users, patient
      WHERE users.id = patient.user_id
      AND users.id = ${user_id}
    `
        : await sql`
      SELECT * FROM users, doctor
      WHERE users.id = doctor.doc_id
      AND users.id = ${user_id}
    `;

    if (user_type === "doctor") {
      const countPatient = await sql`
          SELECT COUNT(*) FROM appointment
          WHERE doc_id = ${user_id}
        `;
      result[0].patient_count = countPatient[0].count;
    }

    console.log("Profile information retrieved:", result);
    if (result.length === 0) {
      return res.status(404).json({ error: "Profile not found" });
    }

    res.json(result[0]);
  } catch (err) {
    console.error("Error retrieving profile information:", err);
    res.status(500).json({ error: err.message });
  }
});

async function update_patient(user_id, updateData) {
  const result1 = await sql`
    UPDATE users
    SET name = ${updateData.name}, email = ${updateData.email}
    WHERE users.id = ${user_id}
    RETURNING *
  `;

  const result2 = await sql`
    UPDATE patient
    SET profession = ${updateData.profession}, bio = ${updateData.bio}, dob = ${updateData.dob}, gender = ${updateData.gender}, emergency_contact = ${updateData.emergency_contact}
    WHERE patient.user_id = ${user_id}
    RETURNING *
  `;
  return result1.length > 0 ? result1 : result2;
}

async function update_doctor(user_id, updateData) {
  const result1 = await sql`
    UPDATE users
    SET name = ${updateData.name}, email = ${updateData.email}, phone_no = ${updateData.phone_no}
    WHERE users.id = ${user_id}
    RETURNING *
  `;

  console.log("User information updated:", result1);

  const result2 = await sql`
    UPDATE doctor
    SET
    special = ${updateData.special}, bdn = ${updateData.bdn}, accept_patient = ${updateData.accept_patient}, shortbio = ${updateData.shortbio}, education = ${updateData.education}, exp = ${updateData.exp}, profession = ${updateData.profession}, description = ${updateData.description}, dob = ${updateData.dob}, gender = ${updateData.gender}
    WHERE doctor.doc_id = ${user_id}
    RETURNING *
  `;

  console.log("Doctor information updated:", result2);

  return result1.length > 0 ? result1 : result2;
}

router.post("/update-info", async (req, res) => {
  try {
    console.log("Updating profile information:", req.body);

    const { user_id, user_type, ...updateData } = req.body;

    if (!user_id || !user_type) {
      return res.status(400).json({ error: "Missing user_id or user_type" });
    }
    let result;

    if (user_type === "patient") {
      result = await update_patient(user_id, updateData);
    } else {
      result = await update_doctor(user_id, updateData);
    }

    console.log(result);
    if (result.length === 0) {
      return res.status(404).json({ error: "Profile not found" });
    }

    res.json(result[0]);
  } catch (err) {
    console.error("Error updating profile information:", err);
    res.status(500).json({ error: err.message });
  }
});

router.post("/update-profile-image", async (req, res) => {
  try {
    const { user_id, user_type, profileImage } = req.body;
    console.log("Updating profile image for:", user_id, user_type);
    console.log("New profile image:", profileImage);
    if (!user_id || !user_type || !profileImage) {
      return res
        .status(400)
        .json({ error: "Missing user_id, user_type, or profileImage" });
    }

    let result = await sql`
        UPDATE users
        SET "profileImage" = ${profileImage}
        WHERE id = ${user_id}
        RETURNING *
      `;

    console.log(result);
    if (result.length === 0) {
      return res.status(404).json({ error: "Profile not found" });
    }

    res.json(result[0]);
  } catch (err) {
    console.error("Error updating profile image:", err);
    res.status(500).json({ error: err.message });
  }
});

async function get_streak(user_id) {
  const streak = await sql`
        WITH ordered_moods AS (
        SELECT
          date,
          ROW_NUMBER() OVER (ORDER BY date) AS rn
        FROM (
          SELECT DISTINCT date
          FROM mood_tracker
          WHERE user_id = ${user_id}
        ) t
      ),
      grouped AS (
        SELECT
          date,
          date - (rn || ' days')::interval AS grp
        FROM ordered_moods
      ),
      latest_grp AS (
        SELECT grp
        FROM grouped
        ORDER BY date DESC
        LIMIT 1
      )
      SELECT COUNT(*) AS current_streak
      FROM grouped
      WHERE grp = (SELECT grp FROM latest_grp);
`;
  return streak;
}

router.get("/get-mood", async (req, res) => {
  try {
    const { user_id } = req.query;
    if (!user_id) {
      return res.status(400).json({ error: "Missing user_id" });
    }

    const result = await sql`
      SELECT mood_status FROM mood_tracker
      WHERE user_id = ${user_id} and date = CURRENT_DATE
    `;
    if (result.length === 0) {
      return res.status(404).json({ error: "Mood data not found" });
    }

    const streak = await get_streak(user_id);

    res.json({
      mood_status: result[0].mood_status,
      current_streak: streak[0].current_streak,
    });
  } catch (err) {
    console.error("Error retrieving mood data:", err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

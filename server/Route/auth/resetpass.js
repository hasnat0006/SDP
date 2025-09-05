const express = require("express");
const bcrypt = require("bcrypt");
const sql = require("../../DB/connection");
const { sendMail, sendEmergencyAlert } = require("./mail");
const router = express.Router();

router.get("/check-user", async (req, res) => {
  const { email } = req.query;
  if (!email) {
    return res.status(400).json({ error: "Email is required" });
  }
  const response = await sql`SELECT * FROM users WHERE email = ${email}`;
  if (response.length === 0) {
    return res.status(404).json({ error: "User not found" });
  }
  return res.status(200).json({ message: "User exists", user: response[0] });
});

const checkUser = async (email) => {
  const response = await sql`SELECT * FROM users WHERE email = ${email}`;
  return response[0];
};

router.get("/send-otp", async (req, res) => {
  const { email } = req.query;
  if (!email) {
    return res.status(400).json({ error: "Email is required" });
  }
  const userExists = await checkUser(email);
  console.log("user: ", userExists);
  if (!userExists) {
    return res.status(404).json({ error: "User not found" });
  }
  const otp = Math.floor(10000 + Math.random() * 90000);
  const mailSent = await sendMail(email, "Your OTP Code", otp);
  if (!mailSent) {
    return res.status(500).json({ error: "Failed to send OTP" });
  }
  return res.status(200).json({ message: "OTP sent successfully", otp: otp });
});

router.post("/change-pass", async(req, res) => {
    const { email, password } = req.body;
    if (!email || !password) {
        return res.status(400).json({ error: "All fields are required" });
    }

    const hashedPassword = await encryptPassword(password);
    const changepass = await sql`UPDATE users SET en_pass = ${hashedPassword} WHERE email = ${email}`;

    if (!changepass) {
        return res.status(500).json({ error: "Failed to change password" });
    }
    return res.status(200).json({ message: "Password changed successfully" });
});

async function encryptPassword(password) {
  const saltRounds = 12; // Higher value = more secure but slower
  return await bcrypt.hash(password, saltRounds);
}

// Test endpoint for emergency alert
router.get("/test-emergency-alert", async (req, res) => {
  try {
    const testData = [
      { date: '2025-09-01', mood_status: 'Sad', mood_level: 4 },
      { date: '2025-09-02', mood_status: 'Depressed', mood_level: 3 },
      { date: '2025-09-03', mood_status: 'Angry', mood_level: 5 }
    ];
    
    const result = await sendEmergencyAlert(
      'zahin2296@gmail.com',
      'TestUser',
      'negative_mood_pattern',
      testData
    );
    
    res.json({ 
      success: result, 
      message: result ? 'Emergency alert sent successfully' : 'Failed to send emergency alert' 
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;

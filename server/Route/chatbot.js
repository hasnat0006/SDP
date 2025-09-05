const express = require("express");
const sql = require("../DB/connection");
const nodemailer = require("nodemailer");
const router = express.Router();

// Save chat message
router.post("/chat/save", async (req, res) => {
  try {
    const { userId, conversation, date } = req.body;
    console.log("Saving chat conversation:", { userId, date });

    const result = await sql`
      INSERT INTO chatbot (user_id, conversation, date)
      VALUES (${userId}, ${conversation}, ${date})
      RETURNING *
    `;

    console.log("Conversation saved:", result[0]);
    res.status(201).json(result[0]);
  } catch (err) {
    console.error("Error saving chat message:", err);
    res.status(500).json({ error: err.message });
  }
});

// Get chat history
router.get("/chat/history/:userId", async (req, res) => {
  try {
    const { userId } = req.params;
    if (!userId) {
      return res.status(400).json({ error: "userId is required" });
    }

    console.log("Fetching chat history for user:", userId);

    const result = await sql`
      SELECT 
        COALESCE(conversation, '{"messages":[]}'::jsonb) as conversation,
        date
      FROM chatbot
      WHERE user_id = ${userId}
      ORDER BY date ASC
    `;

    if (!result || result.length === 0) {
      return res.json([]); // Return empty array instead of null
    }

    console.log(`Found ${result.length} conversations`);
    res.json(result);
  } catch (err) {
    console.error("Error fetching chat history:", err);
    res.status(500).json({ error: err.message });
  }
});

// New endpoint for sending emergency email alerts using nodemailer
router.post("/alert/email", async (req, res) => {
  try {
    const { userId, message } = req.body;
    console.log(req.body);
    if (!userId || !message) {
      return res
        .status(400)
        .json({ error: "userId and message are required." });
    }

    // Retrieve the user's emergency email from the users table
    const userResult =
      await sql`SELECT emergency_email FROM users WHERE id = ${userId}`;
    if (
      !userResult ||
      userResult.length === 0 ||
      !userResult[0].emergency_email
    ) {
      return res
        .status(400)
        .json({ error: "Emergency email not found for the user." });
    }

    const emergencyEmail = userResult[0].emergency_email;
    console.log(`Sending emergency email to: ${emergencyEmail}`);

    const transporter = nodemailer.createTransport({
      host: "smtp.gmail.com",
      port: 465,
      secure: true,
      auth: {
        user: process.env.GMAIL,
        pass: process.env.GMAIL_PASS,
      },
    });
    // Configure nodemailer transporter
    // let transporter = nodemailer.createTransport({
    //   service: "gmail", // Change this if using a different email service
    //   auth: {
    //     user: process.env.EMAIL_USER, // Your email address
    //     pass: process.env.EMAIL_PASS, // Your email password or app password
    //   },
    // });

    // Setup email options
    let mailOptions = {
      from: process.env.GMAIL,
      to: emergencyEmail,
      subject: "Emergency Alert from Chatbot",
      text: message,
    };

    // Send the email
    await transporter.sendMail(mailOptions);
    console.log("Emergency email alert sent successfully.");
    res.status(200).json({ message: "Emergency email sent successfully." });
  } catch (err) {
    console.error("Error sending emergency email:", err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

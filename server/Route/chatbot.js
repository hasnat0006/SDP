const express = require("express");
const sql = require("../DB/connection");
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
      ORDER BY date DESC, created_at ASC
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

// // Get chats by date
// router.get("/chat/history/:userId/:date", async (req, res) => {
//   try {
//     const { userId, date } = req.params;
//     console.log("Fetching chats for user:", userId, "date:", date);

//     const result = await sql`
//       SELECT conversation
//       FROM chat_messages
//       WHERE user_id = ${userId}
//         AND date = ${date}
//       ORDER BY created_at ASC
//     `;

//     console.log(`Found ${result.length} conversations for date ${date}`);
//     res.json(result);
//   } catch (err) {
//     console.error("Error fetching chat history:", err);
//     res.status(500).json({ error: err.message });
//   }
// });

module.exports = router;

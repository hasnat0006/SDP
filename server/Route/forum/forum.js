const express = require("express");
const sql = require("../../DB/connection");
const router = express.Router();

router.post("/post-content", async (req, res) => {
  try {
    console.log("Body:", req.body);

    const { id, content, mood } = req.body;

    if (!id || !content || !mood) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    const newPost = await sql`
      INSERT INTO forum (user_id, content, mood)
      VALUES (${id}, ${content}, ${mood})
      RETURNING *;
    `;

    res.status(200).json({
      message: "Post created successfully",
      post: newPost[0],
    });
  } catch (error) {
    console.error("Error creating post:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

router.get("/get-posts", async (req, res) => {
  const { id } = req.query;

  if (!id) {
    return res.status(400).json({ error: "Missing user ID" });
  }

  try {
    const posts = await sql`
            SELECT * FROM forum WHERE user_id = ${id} ORDER BY timestamp DESC;
        `;
    res.status(200).json({ data: posts });
  } catch (error) {
    console.error("Error fetching posts:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

router.post("/delete-post", async (req, res) => {
  const { postId } = req.body;

  if (!postId) {
    return res.status(400).json({ error: "Missing post ID" });
  }

  try {
    await sql`
                DELETE FROM forum WHERE id = ${postId};
            `;
    res.status(200).json({ message: "Post deleted successfully" });
  } catch (error) {
    console.error("Error deleting post:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

router.post("/update-post", async (req, res) => {
  const { postId, content, mood } = req.body;

  if (!postId || !content || !mood) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  try {
    const updatedPost = await sql`
            UPDATE forum
            SET content = ${content}, mood = ${mood}
            WHERE id = ${postId}
            RETURNING *;
        `;

    res.status(200).json({
      message: "Post updated successfully",
      post: updatedPost[0],
    });
  } catch (error) {
    console.error("Error updating post:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

router.get("/get-all-posts", async (req, res) => {
  try {
    const posts = await sql`
            SELECT * FROM forum ORDER BY timestamp DESC;
        `;
    console.log(posts);
    res.status(200).json({ data: posts });
  } catch (error) {
    console.error("Error fetching all posts:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

module.exports = router;

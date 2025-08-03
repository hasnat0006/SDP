require("dotenv").config();
const express = require("express");
const { createClient } = require("@supabase/supabase-js");
const sql = require("./DB/connection");
const app = express();
app.use(express.json());

const users = require("./Route/fetchusers");

const cors = require("cors");
app.use(cors());

app.use("/", users);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

const express = require("express");
const app = express();
app.use(express.json());
require("dotenv").config();

const cors = require("cors");
app.use(cors());

const stress = require("./Route/stress");
const auth = require("./Route/auth/fetchusers");
const resetPassword = require("./Route/auth/resetpass");
const saveJournal = require("./Route/save_journal");
const journalRoutes = require("./Route/fetch_journal");
const forumRoutes = require("./Route/forum/forum");
const therapists = require("./Route/appt");
const sleep = require("./Route/sleep");

app.use("/", auth);
app.use("/reset-pass", resetPassword);
app.use("/stress", stress);
app.use("/forum", forumRoutes);
app.use("/", saveJournal);
app.use("/", journalRoutes);
app.use("/", therapists);
app.use("/", sleep);

app.get("/", (req, res) => {
  res.send("Welcome to the MindOra API");
});

const PORT = process.env.PORT;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

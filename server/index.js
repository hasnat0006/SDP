const express = require("express");
const app = express();
app.use(express.json());
require("dotenv").config();

const cors = require("cors");
app.use(cors());

const mood = require("./Route/mood");
const sleep = require("./Route/sleep");
const stress = require("./Route/stress");
const todo = require("./Route/todo/todo");
const therapists = require("./Route/appt");
const chatRoutes = require("./Route/chatbot");
const auth = require("./Route/auth/fetchusers");
const forumRoutes = require("./Route/forum/forum");
const saveJournal = require("./Route/save_journal");
const journalRoutes = require("./Route/fetch_journal");
const resetPassword = require("./Route/auth/resetpass");
const therapistRoutes = require("./Route/fetchtherapist");
const suggestedTask = require("./Route/todo/suggested_task");
const patientProfile = require("./Route/profile/patient_profile");


app.use("/", auth);
app.use("/", sleep);
app.use("/mood", mood);
app.use("/tasks", todo);
app.use("/", therapists);
app.use("/sleep", sleep);
app.use("/", saveJournal);
app.use("/stress", stress);
app.use("/", journalRoutes);
app.use("/", therapistRoutes);
app.use("/forum", forumRoutes);
app.use("/profile", patientProfile);
app.use("/reset-pass", resetPassword);
app.use("/suggested-tasks", suggestedTask);
app.use("/", chatRoutes);

app.get("/", (req, res) => {
  res.send("Welcome to the MindOra API");
});

app.use((req, res, next) => {
  res.on("finish", () => {
    console.log("----------------------------------------");
  });
  next();
});

const PORT = process.env.PORT;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

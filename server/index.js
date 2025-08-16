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
const therapistRoutes = require("./Route/fetchtherapist");
const patientProfile = require("./Route/profile/patient_profile");

app.use("/", auth);
app.use("/reset-pass", resetPassword);
app.use("/stress", stress);
app.use("/forum", forumRoutes);
app.use("/profile", patientProfile);
app.use("/", saveJournal);
app.use("/", journalRoutes);
app.use("/", therapistRoutes);

app.get("/", (req, res) => {
  res.send("Welcome to the MindOra API");
});

app.use((req, res, next) => {
  res.on('finish', () => {
    console.log('----------------------------------------');
  });
  next();
});

const PORT = process.env.PORT;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

const express = require("express");
const app = express();
app.use(express.json());
require("dotenv").config();


const cors = require("cors");
app.use(cors());

const auth = require("./Route/auth/fetchusers");
const resetPassword = require("./Route/auth/resetpass");
const saveJournal = require("./Route/save_journal");
const journalRoutes = require("./Route/fetch_journal");
const forumRoutes = require("./Route/forum/forum");

app.use("/", auth);
app.use("/reset-pass", resetPassword);
app.use("/forum", forumRoutes);
app.use("/", saveJournal);
app.use("/", journalRoutes);


const PORT = process.env.PORT;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

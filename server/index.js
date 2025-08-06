const express = require("express");
const app = express();
app.use(express.json());
require("dotenv").config();


const cors = require("cors");
app.use(cors());

const users = require("./Route/fetchusers");

app.use("/", users);

const saveJournal = require("./Route/save_journal");
app.use("/", saveJournal);

const PORT = process.env.PORT;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

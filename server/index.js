const express = require("express");
const app = express();
app.use(express.json());
require("dotenv").config();

const cors = require("cors");
app.use(cors());

const users = require("./Route/fetchusers");
const therapist = require("./Route/appt");

app.use("/", users);
app.use("/", therapist);

const PORT = process.env.PORT;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

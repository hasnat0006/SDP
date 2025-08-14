const express = require("express");
const app = express();
app.use(express.json());
require("dotenv").config();


const cors = require("cors");
app.use(cors());

const users = require("./Route/fetchusers");
const stress = require("./Route/stress");
const mood = require("./Route/mood");
const sleep = require("./Route/sleep");

app.use("/", users);
app.use("/stress", stress);
app.use("/mood", mood);
app.use("/sleep", sleep);


const PORT = process.env.PORT;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

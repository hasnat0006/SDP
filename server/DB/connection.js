const postgres = require("postgres");

const connectionString = process.env.DATABASE_URL;
console.log(connectionString);
const sql = postgres(connectionString);

module.exports = sql;

require('dotenv').config();
const sql = require("./DB/connection");

async function addMoodColumns() {
  try {
    console.log("Adding mood and mood_color columns to journal table...");
    
    // Add mood column
    await sql`
      ALTER TABLE journal 
      ADD COLUMN IF NOT EXISTS mood VARCHAR(20) DEFAULT 'neutral'
    `;
    
    // Add mood_color column
    await sql`
      ALTER TABLE journal 
      ADD COLUMN IF NOT EXISTS mood_color VARCHAR(7) DEFAULT '#EEDCF9'
    `;
    
    console.log("✅ Successfully added mood columns to journal table");
    
    // Verify the columns exist
    const result = await sql`
      SELECT column_name, data_type, column_default 
      FROM information_schema.columns 
      WHERE table_name = 'journal' AND column_name IN ('mood', 'mood_color')
    `;
    
    console.log("📊 Column info:", result);
    
  } catch (error) {
    console.error("❌ Error adding mood columns:", error);
    throw error;
  } finally {
    process.exit(0);
  }
}

addMoodColumns();

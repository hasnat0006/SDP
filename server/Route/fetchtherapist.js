const express = require('express');
const router = express.Router();
const sql = require('../DB/connection');

// Test database connection with a known table
router.get('/test-db', async (req, res) => {
  try {
    console.log('🔍 Testing database connection...');
    
    // Test with users table (we know this exists)
    const users = await sql`SELECT COUNT(*) as count FROM users`;
    console.log('✅ Users table count:', users[0].count);
    
    res.json({ 
      message: 'Database connection works',
      userCount: users[0].count 
    });
  } catch (error) {
    console.error('❌ Database connection error:', error);
    res.status(500).json({ error: 'Database connection failed', details: error.message });
  }
});

// Debug route to check all appointments
router.get('/all-appointments', async (req, res) => {
  try {
    console.log('🔍 Fetching ALL appointments for debugging...');
    
    const appointments = await sql`
      SELECT * FROM appointment
    `;
    
    console.log('📊 Total appointments found:', appointments.length);
    console.log('📋 All appointments data:', JSON.stringify(appointments, null, 2));
    
    // Let's also check what columns exist
    if (appointments.length > 0) {
      console.log('� Columns in first row:', Object.keys(appointments[0]));
    }
    
    res.json(appointments);
  } catch (error) {
    console.error('❌ Server error:', error);
    console.error('❌ Error details:', error.message);
    res.status(500).json({ error: 'Server error', details: error.message });
  }
});

// Route to fetch confirmed appointments
router.get('/confirmed-appointments', async (req, res) => {
  try {
    console.log('🔍 Fetching confirmed appointments...');
    
    const appointments = await sql`
      SELECT doc_id, user_id, status, date, time 
      FROM appointment 
      WHERE status = 'confirmed'
    `;
    
    console.log('📊 Found confirmed appointments:', appointments.length);
    console.log('📋 Confirmed appointments data:', JSON.stringify(appointments, null, 2));
    
    res.json(appointments);
  } catch (error) {
    console.error('❌ Server error:', error);
    console.error('❌ Error details:', error.message);
    res.status(500).json({ error: 'Server error', details: error.message });
  }
});

// Route to fetch confirmed appointments for a specific doctor
router.get('/confirmed-appointments/doctor/:docId', async (req, res) => {
  try {
    const { docId } = req.params;
    console.log(`🔍 Fetching confirmed appointments for doctor ID: ${docId}`);
    
    const appointments = await sql`
      SELECT doc_id, user_id, status, date, time 
      FROM appointment 
      WHERE status = 'confirmed' AND doc_id = ${docId}
    `;
    
    console.log('📊 Found confirmed appointments for doctor:', appointments.length);
    
    res.json(appointments);
  } catch (error) {
    console.error('❌ Server error:', error);
    res.status(500).json({ error: 'Server error', details: error.message });
  }
});

// Route to fetch confirmed appointments for a specific user
router.get('/confirmed-appointments/user/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    console.log(`🔍 Fetching confirmed appointments for user ID: ${userId}`);
    
    const appointments = await sql`
      SELECT doc_id, user_id, status, date, time 
      FROM appointment 
      WHERE status = 'confirmed' AND user_id = ${userId}
    `;
    
    console.log('📊 Found confirmed appointments for user:', appointments.length);
    
    res.json(appointments);
  } catch (error) {
    console.error('❌ Server error:', error);
    res.status(500).json({ error: 'Server error', details: error.message });
  }
});

module.exports = router;

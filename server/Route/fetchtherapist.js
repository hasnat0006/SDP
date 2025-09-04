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
      SELECT *, doc_id, user_id, status, date, time, reminder 
      FROM appointment 
      WHERE status = 'Confirmed'
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
      SELECT *, doc_id, user_id, status, date, time, reminder 
      FROM appointment 
      WHERE status = 'Confirmed' AND doc_id = ${docId}
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
      SELECT *, doc_id, user_id, status, date, time, reminder 
      FROM appointment 
      WHERE status = 'Confirmed' AND user_id = ${userId}
    `;
    
    console.log('📊 Found confirmed appointments for user:', appointments.length);
    
    res.json(appointments);
  } catch (error) {
    console.error('❌ Server error:', error);
    res.status(500).json({ error: 'Server error', details: error.message });
  }
});

// Route to fetch confirmed appointments where user is the patient
router.get('/my-appointments/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    console.log(`🔍 Fetching my appointments for user ID: ${userId}`);
    
    const appointments = await sql`
      SELECT *, doc_id, user_id, status, date, time, reminder 
      FROM appointment 
      WHERE status = 'Confirmed' AND doc_id = ${userId}
    `;
    
    console.log('📊 Found my appointments:', appointments.length);
    
    res.json(appointments);
  } catch (error) {
    console.error('❌ Server error:', error);
    res.status(500).json({ error: 'Server error', details: error.message });
  }
});

// Route to fetch pending appointments for a specific doctor
router.get('/pending-appointments/doctor/:docId', async (req, res) => {
  try {
    const { docId } = req.params;
    console.log(`🔍 Fetching pending appointments for doctor ID: ${docId}`);
    
    // Quick debug to see all statuses in the database
    const allStatuses = await sql`
      SELECT DISTINCT status FROM appointment
    `;
    console.log('📊 All status values in database:', allStatuses.map(row => row.status));
    
    const appointments = await sql`
      SELECT *, doc_id, user_id, status, date, time, reminder 
      FROM appointment 
      WHERE status = 'Pending' AND doc_id = ${docId}
    `;
    
    console.log('📊 Found pending appointments for doctor:', appointments.length);
    if (appointments.length > 0) {
      console.log('📋 First appointment status:', appointments[0].status);
    }
    
    res.json(appointments);
  } catch (error) {
    console.error('❌ Server error:', error);
    res.status(500).json({ error: 'Server error', details: error.message });
  }
});

// Route to get user details by user ID
router.get('/user/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    console.log(`🔍 Fetching user details for ID: ${userId}`);
    
    const user = await sql`
      SELECT name 
      FROM users 
      WHERE id = ${userId}
    `;
    
    if (user.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    console.log('✅ Found user:', user[0]);
    res.json(user[0]);
  } catch (error) {
    console.error('❌ Server error:', error);
    res.status(500).json({ error: 'Server error', details: error.message });
  }
});

// Route to get patient details by user ID
router.get('/patient/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    console.log(`🔍 Fetching patient details for user ID: ${userId}`);
    
    // Fetch from both users and patient tables
    // users table has: name, id
    // patient table has: user_id, profession, gender, dob
    const patientData = await sql`
      SELECT 
        u.name,
        p.gender, 
        p.dob, 
        p.profession 
      FROM users u
      LEFT JOIN patient p ON u.id = p.user_id
      WHERE u.id = ${userId}
    `;
    
    if (patientData.length === 0) {
      return res.status(404).json({ error: 'Patient not found' });
    }
    
    console.log('✅ Found patient data:', patientData[0]);
    res.json(patientData[0]);
  } catch (error) {
    console.error('❌ Server error:', error);
    res.status(500).json({ error: 'Server error', details: error.message });
  }
});

// Route to cancel appointment by app_id
router.put('/cancel-appointment/:appId', async (req, res) => {
  try {
    const { appId } = req.params;
    console.log(`🔍 Cancelling appointment with ID: ${appId}`);
    
    // Update the appointment status to 'cancelled' using the primary key
    const result = await sql`
      UPDATE appointment 
      SET status = 'Cancelled'
      WHERE app_id = ${appId}
    `;
    
    if (result.count === 0) {
      return res.status(404).json({ error: 'Appointment not found' });
    }
    
    console.log('✅ Appointment cancelled successfully');
    res.json({ 
      success: true, 
      message: 'Appointment cancelled successfully',
      appointmentId: appId
    });
  } catch (error) {
    console.error('❌ Server error:', error);
    res.status(500).json({ error: 'Server error', details: error.message });
  }
});

// Route to update reminder status for an appointment
router.put('/update-reminder/:appId', async (req, res) => {
  try {
    const { appId } = req.params;
    const { reminder } = req.body;
    
    console.log(`🔍 Updating reminder for appointment ID: ${appId} to: ${reminder}`);
    
    // Validate reminder value
    if (!reminder || (reminder !== 'on' && reminder !== 'off')) {
      return res.status(400).json({ error: 'Reminder must be "on" or "off"' });
    }
    
    // Update the appointment reminder status using the primary key
    const result = await sql`
      UPDATE appointment 
      SET reminder = ${reminder}
      WHERE app_id = ${appId}
    `;
    
    if (result.count === 0) {
      return res.status(404).json({ error: 'Appointment not found' });
    }
    
    console.log('✅ Appointment reminder updated successfully');
    res.json({ 
      success: true, 
      message: 'Reminder status updated successfully',
      appointmentId: appId,
      reminder: reminder
    });
  } catch (error) {
    console.error('❌ Server error:', error);
    res.status(500).json({ error: 'Server error', details: error.message });
  }
});

// Route to update appointment status (for accept/reject)
router.put('/update-appointment-status/:appId', async (req, res) => {
  try {
    const { appId } = req.params;
    const { status } = req.body;
    
    console.log(`🔍 Updating appointment status for ID: ${appId} to: ${status}`);
    
    // Validate status value
    if (!status || !['Confirmed', 'Cancelled', 'Rejected', 'Pending'].includes(status)) {
      return res.status(400).json({ error: 'Invalid status value' });
    }
    
    // Update the appointment status using the primary key
    const result = await sql`
      UPDATE appointment 
      SET status = ${status}
      WHERE app_id = ${appId}
    `;
    
    if (result.count === 0) {
      return res.status(404).json({ error: 'Appointment not found' });
    }
    
    console.log('✅ Appointment status updated successfully');
    res.json({ 
      success: true, 
      message: 'Appointment status updated successfully',
      appointmentId: appId,
      status: status
    });
  } catch (error) {
    console.error('❌ Server error:', error);
    res.status(500).json({ error: 'Server error', details: error.message });
  }
});

// Route to get monthly appointments for a doctor
router.get('/doctor/monthly-stats/:docId', async (req, res) => {
  try {
    const { docId } = req.params;
    console.log(`🔍 Fetching monthly stats for doctor: ${docId}`);
    
    const doctor = await sql`
      SELECT monthly_appointments 
      FROM doctor 
      WHERE doc_id = ${docId}
    `;
    
    if (doctor.length === 0) {
      // If doctor not found, return default array
      console.log('⚠️ Doctor not found, returning default array');
      return res.json(Array(12).fill(0));
    }
    
    const monthlyStats = doctor[0].monthly_appointments || Array(12).fill(0);
    console.log('✅ Found monthly stats:', monthlyStats);
    res.json(monthlyStats);
  } catch (error) {
    console.error('❌ Server error:', error);
    res.status(500).json({ error: 'Server error', details: error.message });
  }
});

// Route to increment monthly appointment count - FIXED VERSION
router.post('/doctor/increment-monthly/:docId', async (req, res) => {
  try {
    const { docId } = req.params;
    const { month } = req.body; // month should be 1-12
    
    console.log(`🔍 Incrementing appointment count for doctor: ${docId}, month: ${month}`);
    
    if (!month || month < 1 || month > 12) {
      return res.status(400).json({ error: 'Invalid month. Must be between 1-12' });
    }
    
    // First, get current array and check if doctor exists
    const doctor = await sql`
      SELECT monthly_appointments, doc_id 
      FROM doctor 
      WHERE doc_id = ${docId}
    `;
    
    console.log('🔍 Doctor query result:', doctor);
    
    if (doctor.length === 0) {
      console.log('❌ Doctor not found in database');
      return res.status(404).json({ error: 'Doctor not found' });
    }
    
    let currentStats = Array(12).fill(0);
    if (doctor[0].monthly_appointments) {
      currentStats = doctor[0].monthly_appointments;
    }
    
    // Increment the specific month
    currentStats[month - 1] += 1;
    
    console.log('🔄 Updated monthly stats:', currentStats);
    
    // Update the database
    const result = await sql`
      UPDATE doctor 
      SET monthly_appointments = ${currentStats}::integer[]
      WHERE doc_id = ${docId}
    `;
    
    console.log('✅ Database update result:', result);
    
    res.json({ 
      success: true, 
      message: 'Monthly appointment count updated successfully',
      docId,
      month,
      newCount: currentStats[month - 1]
    });
  } catch (error) {
    console.error('❌ Server error:', error);
    res.status(500).json({ error: 'Server error', details: error.message });
  }
});

// Route to decrement monthly appointment count - FIXED VERSION
router.post('/doctor/decrement-monthly/:docId', async (req, res) => {
  try {
    const { docId } = req.params;
    const { month } = req.body; // month should be 1-12
    
    console.log(`🔍 Decrementing appointment count for doctor: ${docId}, month: ${month}`);
    
    if (!month || month < 1 || month > 12) {
      return res.status(400).json({ error: 'Invalid month. Must be between 1-12' });
    }
    
    // First, get current array and check if doctor exists
    const doctor = await sql`
      SELECT monthly_appointments, doc_id 
      FROM doctor 
      WHERE doc_id = ${docId}
    `;
    
    console.log('🔍 Doctor query result:', doctor);
    
    if (doctor.length === 0) {
      console.log('❌ Doctor not found in database');
      return res.status(404).json({ error: 'Doctor not found' });
    }
    
    let currentStats = Array(12).fill(0);
    if (doctor[0].monthly_appointments) {
      currentStats = [...doctor[0].monthly_appointments]; // Create a copy
      console.log('📊 Current stats before decrement:', currentStats);
    } else {
      console.log('📊 No existing stats, using default array');
    }
    
    // Decrement the specific month (month-1 because array is 0-indexed), but don't go below 0
    const oldValue = currentStats[month - 1];
    currentStats[month - 1] = Math.max(0, currentStats[month - 1] - 1);
    console.log(`📉 Decrementing month ${month}: ${oldValue} -> ${currentStats[month - 1]}`);
    console.log('📊 New stats array:', currentStats);
    
    // Update the database with explicit array casting
    const result = await sql`
      UPDATE doctor 
      SET monthly_appointments = ${currentStats}::integer[]
      WHERE doc_id = ${docId}
    `;
    
    console.log('✅ Update result - rows affected:', result.count);
    
    if (result.count === 0) {
      console.log('❌ No rows were updated');
      return res.status(500).json({ error: 'Failed to update doctor record' });
    }
    
    // Verify the update by querying again
    const verifyUpdate = await sql`
      SELECT monthly_appointments 
      FROM doctor 
      WHERE doc_id = ${docId}
    `;
    console.log('🔍 Verification - updated stats in DB:', verifyUpdate[0]?.monthly_appointments);
    
    console.log('✅ Monthly stats decremented successfully');
    res.json({ 
      success: true, 
      monthlyStats: currentStats,
      updatedMonth: month,
      newCount: currentStats[month - 1],
      rowsUpdated: result.count,
      verifiedStats: verifyUpdate[0]?.monthly_appointments
    });
  } catch (error) {
    console.error('❌ Server error in decrement:', error);
    res.status(500).json({ error: 'Server error', details: error.message });
  }
});

// Add this debug route to manually test array updates
router.post('/debug/test-array-update/:docId', async (req, res) => {
  try {
    const { docId } = req.params;
    
    console.log(`🔍 Testing array update for doctor: ${docId}`);
    
    // Get current data
    const before = await sql`
      SELECT * FROM doctor WHERE doc_id = ${docId}
    `;
    console.log('📊 Before update:', before);
    
    // Try a simple array update
    const testArray = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    
    const result = await sql`
      UPDATE doctor 
      SET monthly_appointments = ${testArray}::integer[]
      WHERE doc_id = ${docId}
    `;
    
    console.log('✅ Update result:', result);
    
    // Get data after update
    const after = await sql`
      SELECT * FROM doctor WHERE doc_id = ${docId}
    `;
    console.log('📊 After update:', after);
    
    res.json({
      before: before[0],
      after: after[0],
      updateResult: result,
      testArray
    });
  } catch (error) {
    console.error('❌ Test error:', error);
    res.status(500).json({ error: 'Test error', details: error.message });
  }
});



module.exports = router;module.exports = router;

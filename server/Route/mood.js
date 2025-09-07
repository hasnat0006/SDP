const express = require("express");
const sql = require("../DB/connection");
const { sendEmergencyAlert } = require("./auth/mail");
const router = express.Router();

// Helper function to analyze mood patterns for emergency alerts
const analyzeMoodPatterns = (moodData) => {
  console.log('🔍 ANALYZE - Starting mood pattern analysis with', moodData.length, 'entries');
  
  if (!moodData || moodData.length < 5) {
    console.log('⚠️ ANALYZE - Not enough data for analysis (<5 entries)');
    return { needsAlert: false, alertType: null, relevantData: [] };
  }

  // Sort by date to ensure chronological order
  const sortedData = moodData.sort((a, b) => new Date(a.date) - new Date(b.date));
  console.log('🔍 ANALYZE - Sorted data sample:', sortedData.slice(0, 3));
  
  // Get last 7 days of data
  const last7Days = sortedData.slice(-7);
  console.log('🔍 ANALYZE - Last 7 days data:', last7Days.map(d => `${d.formatted_date}: ${d.mood_status}(${d.mood_level})`));
  
  // Check for Condition 1: 5 or More Days of Negative Moods with High Intensity
  const negativeMoods = ['sad', 'angry', 'depressed', 'stressed'];
  const negativeHighIntensityDays = last7Days.filter(mood => 
    negativeMoods.includes(mood.mood_status.toLowerCase()) && mood.mood_level >= 3
  );
  
  console.log('� ANALYZE - Negative high-intensity days found:', negativeHighIntensityDays.length);
  console.log('🔍 ANALYZE - Details:', negativeHighIntensityDays.map(d => `${d.formatted_date}: ${d.mood_status}(${d.mood_level})`));
  
  if (negativeHighIntensityDays.length >= 5) {
    console.log('🚨 ANALYZE - CONDITION 1 TRIGGERED: 5+ days of negative high-intensity moods');
    return {
      needsAlert: true,
      alertType: 'negative_mood_pattern',
      relevantData: negativeHighIntensityDays
    };
  }

  console.log('� ANALYZE - Condition 1 not met, checking condition 2...');
  
  // For now, let's just focus on condition 1 to debug
  console.log('⚠️ ANALYZE - No emergency conditions met');
  return { needsAlert: false, alertType: null, relevantData: [] };
};

// Helper function to get user's emergency contact
const getUserEmergencyContact = async (userId) => {
  try {
    const result = await sql`
      SELECT emergency_email, email as user_email
      FROM users 
      WHERE id = ${userId}
    `;
    
    if (result.length > 0 && result[0].emergency_email) {
      return {
        emergencyEmail: result[0].emergency_email,
        userEmail: result[0].user_email
      };
    }
    return null;
  } catch (err) {
    console.error("Error getting emergency contact:", err);
    return null;
  }
};

// Helper function to get user's name for personalized alerts
const getUserName = async (userId) => {
  try {
    const result = await sql`
      SELECT name
      FROM users 
      WHERE id = ${userId}
    `;
    
    if (result.length > 0 && result[0].name) {
      return result[0].name;
    }
    return 'User';
  } catch (err) {
    console.error("Error getting user name:", err);
    return 'User';
  }
};

// Store mood tracking data
router.post("/track", async (req, res) => {
  try {
    const { user_id, mood_status, mood_level, reason, date } = req.body;
    
    console.log('📝 Received mood data:', {
      user_id,
      mood_status,
      mood_level,
      reason,
      date
    });
    
    // Ensure reason is properly formatted as an array
    const reasonArray = Array.isArray(reason) ? reason : [];
    
    const result = await sql`
      INSERT INTO mood_tracker (
        user_id, 
        mood_status, 
        mood_level, 
        reason, 
        date
      ) 
      VALUES (
        ${user_id}, 
        ${mood_status}, 
        ${mood_level}, 
        ${reasonArray}, 
        ${date}
      )
      RETURNING *
    `;

    console.log('✅ Mood data saved successfully:', result[0]);
    res.status(201).json(result[0]);
  } catch (err) {
    console.error("❌ Error saving mood data:", err);
    res.status(500).json({ error: err.message });
  }
});

// Get mood data for a specific user (latest entry)
router.get("/data/:userId", async (req, res) => {
  try {
    const { userId } = req.params;
    console.log("User ID:", userId);
    const result = await sql`
      SELECT * FROM mood_tracker 
      WHERE user_id = ${userId}
      ORDER BY date DESC
      LIMIT 1
    `;

    if (result.length === 0) {
      return res.status(404).json({ 
        message: "No mood data found for this user",
        data: null 
      });
    }

    // Ensure reason is always an array
    const moodData = result[0];
    if (moodData.reason && !Array.isArray(moodData.reason)) {
      moodData.reason = [moodData.reason];
    } else if (!moodData.reason) {
      moodData.reason = [];
    }

    console.log('✅ Latest mood data retrieved:', moodData);
    res.json(moodData);
  } catch (err) {
    console.error("Error retrieving mood data:", err);
    res.status(500).json({ error: err.message });
  }
});

// Get mood data for a specific user and date
router.get("/data/:userId/:date", async (req, res) => {
  try {
    const { userId, date } = req.params;
    console.log("User ID:", userId, "Date:", date);
    
    const result = await sql`
      SELECT * FROM mood_tracker 
      WHERE user_id = ${userId} AND DATE(date) = ${date}
      ORDER BY date DESC
      LIMIT 1
    `;

    if (result.length === 0) {
      return res.status(404).json({ 
        message: "No mood data found for this date",
        data: null 
      });
    }

    // Ensure reason is always an array
    const moodData = result[0];
    if (moodData.reason && !Array.isArray(moodData.reason)) {
      moodData.reason = [moodData.reason];
    } else if (!moodData.reason) {
      moodData.reason = [];
    }

    console.log('✅ Mood data for date retrieved:', moodData);
    res.json(moodData);
  } catch (err) {
    console.error("Error retrieving mood data for date:", err);
    res.status(500).json({ error: err.message });
  }
});

// Get weekly mood data for a user (current week Monday to Sunday)
router.get("/weekly/:userId", async (req, res) => {
  try {
    const { userId } = req.params;
    
    // Get data for a wider range to ensure we catch all relevant data
    const result = await sql`
      SELECT 
        DATE(date) as date,
        mood_status,
        mood_level,
        reason,
        TO_CHAR(date, 'YYYY-MM-DD') as formatted_date
      FROM mood_tracker 
      WHERE user_id = ${userId} 
        AND date >= CURRENT_DATE - INTERVAL '10 days'
        AND date <= CURRENT_DATE + INTERVAL '3 days'
      ORDER BY date ASC
    `;
    
    // Process data efficiently without excessive logging
    const processedData = result.map(entry => {
      if (entry.reason && !Array.isArray(entry.reason)) {
        entry.reason = [entry.reason];
      } else if (!entry.reason) {
        entry.reason = [];
      }
      return entry;
    });

    console.log('🔍 DEBUG - Mood data retrieved for analysis:', processedData.length, 'entries');
    console.log('🔍 DEBUG - First few entries:', processedData.slice(0, 3));

    // Analyze mood patterns for emergency conditions
    const moodAnalysis = analyzeMoodPatterns(processedData);
    
    console.log('🔍 DEBUG - Mood analysis result:', moodAnalysis);
    
    if (moodAnalysis.needsAlert) {
      console.log(`🚨 Emergency alert conditions met for user ${userId}`);
      console.log(`🔍 Alert type: ${moodAnalysis.alertType}`);
      console.log(`🔍 Relevant data count: ${moodAnalysis.relevantData.length}`);
      
      // Get emergency contact and user name
      const emergencyContact = await getUserEmergencyContact(userId);
      console.log(`🔍 Emergency contact lookup result:`, emergencyContact);
      
      const userName = await getUserName(userId);
      console.log(`🔍 User name lookup result: ${userName}`);
      
      if (emergencyContact && emergencyContact.emergencyEmail) {
        console.log(`📧 Attempting to send emergency alert to: ${emergencyContact.emergencyEmail}`);
        
        // Send emergency alert email
        const emailSent = await sendEmergencyAlert(
          emergencyContact.emergencyEmail,
          userName,
          moodAnalysis.alertType,
          moodAnalysis.relevantData
        );
        
        if (emailSent) {
          console.log(`✅ Emergency alert sent successfully for user ${userId}`);
        } else {
          console.log(`❌ Failed to send emergency alert for user ${userId}`);
        }
      } else {
        console.log(`⚠️ No emergency contact found for user ${userId}, alert not sent`);
        console.log(`🔍 Emergency contact details:`, emergencyContact);
      }
    } else {
      console.log(`ℹ️ No emergency conditions detected for user ${userId}`);
    }

    console.log(`✅ Weekly mood data retrieved: ${processedData.length} entries for user ${userId}`);
    res.json(processedData);
  } catch (err) {
    console.error("❌ Error retrieving weekly mood data:", err);
    res.status(500).json({ error: err.message });
  }
});

// Get monthly mood data for weekly overview
router.get("/monthly/:userId/:year/:month", async (req, res) => {
  try {
    const { userId, year, month } = req.params;
    
    const result = await sql`
      SELECT 
        DATE(date) as date,
        mood_status,
        mood_level,
        reason,
        EXTRACT(WEEK FROM date) - EXTRACT(WEEK FROM DATE_TRUNC('month', date)) + 1 as week_number
      FROM mood_tracker 
      WHERE user_id = ${userId} 
        AND EXTRACT(YEAR FROM date) = ${year}
        AND EXTRACT(MONTH FROM date) = ${month}
      ORDER BY date ASC
    `;

    if (result.length === 0) {
      return res.status(404).json({ 
        message: "No mood data found for this month",
        data: [] 
      });
    }

    // Group by weeks
    const weeklyData = {};
    result.forEach(entry => {
      // Ensure reason is always an array
      if (entry.reason && !Array.isArray(entry.reason)) {
        entry.reason = [entry.reason];
      } else if (!entry.reason) {
        entry.reason = [];
      }
      
      const week = `Week ${entry.week_number}`;
      if (!weeklyData[week]) {
        weeklyData[week] = [];
      }
      weeklyData[week].push(entry);
    });

    console.log('✅ Monthly mood data retrieved:', weeklyData);
    res.json(weeklyData);
  } catch (err) {
    console.error("Error retrieving monthly mood data:", err);
    res.status(500).json({ error: err.message });
  }
});

// Get yearly mood data (12 months)
router.get("/yearly/:userId/:year", async (req, res) => {
  try {
    const { userId, year } = req.params;
    
    const result = await sql`
      SELECT 
        EXTRACT(MONTH FROM date) as month,
        AVG(mood_level::float) as avg_mood_level,
        COUNT(*) as entry_count
      FROM mood_tracker 
      WHERE user_id = ${userId} 
        AND EXTRACT(YEAR FROM date) = ${year}
      GROUP BY EXTRACT(MONTH FROM date)
      ORDER BY month ASC
    `;

    if (result.length === 0) {
      return res.status(404).json({ 
        message: "No mood data found for this year",
        data: [] 
      });
    }

    console.log('✅ Yearly mood data retrieved:', result);
    res.json(result);
  } catch (err) {
    console.error("❌ Error retrieving yearly mood data:", err);
    res.status(500).json({ error: err.message });
  }
});

// Get all-time mood data
router.get("/all-time/:userId", async (req, res) => {
  try {
    const { userId } = req.params;
    
    const result = await sql`
      SELECT 
        EXTRACT(YEAR FROM date) as year,
        AVG(mood_level::float) as avg_mood_level,
        COUNT(*) as entry_count
      FROM mood_tracker 
      WHERE user_id = ${userId}
      GROUP BY EXTRACT(YEAR FROM date)
      ORDER BY year ASC
    `;

    if (result.length === 0) {
      return res.status(404).json({ 
        message: "No mood data found",
        data: [] 
      });
    }

    console.log('✅ All-time mood data retrieved:', result);
    res.json(result);
  } catch (err) {
    console.error("❌ Error retrieving all-time mood data:", err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;

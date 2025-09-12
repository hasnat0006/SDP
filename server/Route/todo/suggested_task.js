const express = require("express");
const sql = require("../../DB/connection");
const router = express.Router();

const { GoogleGenerativeAI, SchemaType } = require("@google/generative-ai");
const genAI = new GoogleGenerativeAI(process.env.GOOGLE_GENERATIVE_API_KEY);
const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

function getLastMoodData(userId) {
  return sql`SELECT mood_status, mood_level, reason FROM mood_tracker WHERE user_id = ${userId} ORDER BY date DESC LIMIT 1`;
}

function getLastStressData(userId) {
  return sql`SELECT stress_level, cause FROM stress_tracker WHERE user_id = ${userId} ORDER BY date DESC LIMIT 1`;
}

function getLastSleepData(userId) {
  return sql`SELECT sleep_hours FROM sleep_tracker WHERE user_id = ${userId} ORDER BY date DESC LIMIT 1`;
}

async function getUserWellnessData(userId) {
  const [mood, stress, sleep] = await Promise.all([
    getLastMoodData(userId),
    getLastStressData(userId),
    getLastSleepData(userId),
  ]);
  return { mood, stress, sleep };
}

function calculateDueDate(urgency, suggestedTime) {
  const now = new Date();
  const [hours, minutes] = suggestedTime.split(":").map(Number);

  switch (urgency) {
    case "now":
      // Due within the next 30 minutes
      return new Date(now.getTime() + 30 * 60 * 1000);

    case "today":
      // Due at the suggested time today, or tomorrow if the time has passed
      const todayAtSuggestedTime = new Date(now);
      todayAtSuggestedTime.setHours(hours, minutes, 0, 0);

      if (todayAtSuggestedTime <= now) {
        // If the suggested time has already passed, set for tomorrow
        todayAtSuggestedTime.setDate(todayAtSuggestedTime.getDate() + 1);
      }

      return todayAtSuggestedTime;

    case "this_week":
      // Due at suggested time within the next 3 days
      const futureDate = new Date(now);
      futureDate.setDate(now.getDate() + Math.floor(Math.random() * 3) + 1);
      futureDate.setHours(hours, minutes, 0, 0);
      return futureDate;

    default:
      // Default to today at suggested time
      const defaultDate = new Date(now);
      defaultDate.setHours(hours, minutes, 0, 0);
      if (defaultDate <= now) {
        defaultDate.setDate(defaultDate.getDate() + 1);
      }
      return defaultDate;
  }
}

function createWellnessPrompt(moodData, stressData, sleepData) {
  let prompt = `You are a wellness assistant. Based on the user's recent wellness data, suggest exactly 3 actionable tasks that would help improve their mental and physical well-being. 

Current wellness status:
- Mood: ${
    moodData
      ? `${moodData.mood_status} (level: ${moodData.mood_level}/10)${
          moodData.reason ? `, reason: ${moodData.reason}` : ""
        }`
      : "No recent mood data"
  }
- Stress: ${
    stressData
      ? `Level ${stressData.stress_level}/10${
          stressData.cause ? `, cause: ${stressData.cause}` : ""
        }`
      : "No recent stress data"
  }
- Sleep: ${
    sleepData ? `${sleepData.sleep_hours} hours` : "No recent sleep data"
  }

Please provide exactly 3 task suggestions in JSON format with the following structure:
{
  "tasks": [
    {
      "title": "Brief, actionable task title (max 50 characters)",
      "description": "Detailed explanation of the task and its benefits (max 150 characters)",
      "priority": "low|medium|high",
      "estimated_duration": "Duration in minutes as number (e.g., 15, 30, 60)",
      "suggested_time": "Best time to do this task in 24hr format (e.g., '09:00', '14:30', '20:00')",
      "urgency": "when this should be done: 'now', 'today', 'this_week'"
    }
  ]
}

Guidelines:
- Tasks should be specific, actionable, and contextually appropriate
- Prioritize tasks based on the user's current wellness needs
- For low mood: suggest mood-boosting activities (morning/afternoon preferred)
- For high stress: suggest immediate stress-relief activities (suggest 'now' or 'today')
- For poor sleep: suggest sleep hygiene tasks for evening (18:00-22:00)
- Each task should take between 5-60 minutes
- Set realistic times based on task type:
  * Morning energy activities: 07:00-10:00
  * Stress relief: current time or within 2 hours
  * Physical activities: 08:00-11:00 or 16:00-19:00
  * Evening wind-down: 18:00-22:00
  * Mindfulness/meditation: 06:00-09:00 or 17:00-21:00
- Set urgency appropriately:
  * High stress/anxiety: 'now'
  * Low mood: 'today' 
  * Sleep issues: 'today' (evening)
  * General wellness: 'this_week'
- Avoid suggesting medication or medical advice
- Focus on behavioral and lifestyle interventions

Current time context: ${
    new Date().toTimeString().split(" ")[0]
  } (use this to suggest appropriate timing)

Return ONLY the JSON response, no additional text.`;

  return prompt;
}

async function generateTaskSuggestions(prompt) {
  try {
    const result = await model.generateContent(prompt);
    const response = await result.response;
    const text = response.text();

    console.log("Gemini raw response:", text);

    // Parse the JSON response
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (!jsonMatch) {
      throw new Error("No valid JSON found in Gemini response");
    }

    const parsedResponse = JSON.parse(jsonMatch[0]);

    if (!parsedResponse.tasks || !Array.isArray(parsedResponse.tasks)) {
      throw new Error("Invalid response structure from Gemini");
    }

    // Validate and format tasks
    const validatedTasks = parsedResponse.tasks
      .slice(0, 3)
      .map((task, index) => {
        // Validate required fields
        if (!task.title || !task.description) {
          throw new Error(`Task ${index + 1} missing required fields`);
        }

        // Validate priority
        const validPriorities = ["low", "medium", "high"];
        if (!validPriorities.includes(task.priority)) {
          task.priority = "medium"; // Default fallback
        }

        // Validate estimated_duration
        const duration = parseInt(task.estimated_duration);
        if (isNaN(duration) || duration < 5 || duration > 120) {
          task.estimated_duration = 30; // Default fallback
        } else {
          task.estimated_duration = duration;
        }

        // Validate and parse suggested_time
        let suggestedTime = task.suggested_time || "12:00";
        const timeRegex = /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/;
        if (!timeRegex.test(suggestedTime)) {
          suggestedTime = "12:00"; // Default fallback
        }

        // Validate urgency
        const validUrgencies = ["now", "today", "this_week"];
        const urgency = validUrgencies.includes(task.urgency)
          ? task.urgency
          : "today";

        // Calculate due date based on urgency and suggested time
        const dueDate = calculateDueDate(urgency, suggestedTime);

        // Truncate fields if too long
        if (task.title.length > 50) {
          task.title = task.title.substring(0, 47) + "...";
        }

        if (task.description.length > 150) {
          task.description = task.description.substring(0, 147) + "...";
        }

        return {
          id: `suggestion_${Date.now()}_${index}`,
          title: task.title,
          description: task.description,
          priority: task.priority,
          estimated_duration: task.estimated_duration,
          dueDate: dueDate.toISOString(),
          createdAt: new Date().toISOString(),
          suggested_time: suggestedTime,
          urgency: urgency,
        };
      });

    return validatedTasks;
  } catch (error) {
    console.error("Error in generateTaskSuggestions:", error);

    // Return fallback suggestions if AI fails
    return getFallbackSuggestions();
  }
}

function getFallbackSuggestions() {
  const now = new Date();
  const currentHour = now.getHours();

  // Determine appropriate times based on current time
  const walkTime =
    currentHour < 17 ? `${Math.max(currentHour + 1, 8)}:00` : "18:00";
  const breathingTime = `${Math.min(currentHour + 1, 23)}:00`;
  const gratitudeTime = currentHour < 21 ? "21:00" : "09:00";

  return [
    {
      id: `fallback_${Date.now()}_1`,
      title: "Take a 10-minute mindful walk",
      description:
        "Step outside and focus on your breathing and surroundings to reduce stress and improve mood",
      priority: "medium",
      estimated_duration: 10,
      dueDate: calculateDueDate("today", walkTime).toISOString(),
      createdAt: now.toISOString(),
      suggested_time: walkTime,
      urgency: "today",
    },
    {
      id: `fallback_${Date.now()}_2`,
      title: "Practice deep breathing for 5 minutes",
      description:
        "Use the 4-7-8 breathing technique to calm your mind and reduce anxiety",
      priority: "high",
      estimated_duration: 5,
      dueDate: calculateDueDate("now", breathingTime).toISOString(),
      createdAt: now.toISOString(),
      suggested_time: breathingTime,
      urgency: "now",
    },
    {
      id: `fallback_${Date.now()}_3`,
      title: "Write 3 things you're grateful for",
      description:
        "Reflect on positive aspects of your day to boost mood and mental well-being",
      priority: "low",
      estimated_duration: 10,
      dueDate: calculateDueDate(
        currentHour < 21 ? "today" : "this_week",
        gratitudeTime
      ).toISOString(),
      createdAt: now.toISOString(),
      suggested_time: gratitudeTime,
      urgency: currentHour < 21 ? "today" : "this_week",
    },
  ];
}

router.get("/wellness", async (req, res) => {
  const userId = req.query.user_id;
  console.log("id: ", userId);
  if (!userId) {
    return res.status(400).json({ error: "User ID is required" });
  }

  try {
    const result = await getUserWellnessData(userId);
    console.log("Wellness data:", result);

    // Prepare wellness context for AI
    const moodData = result.mood[0] || null;
    const stressData = result.stress[0] || null;
    const sleepData = result.sleep[0] || null;

    // Create a detailed prompt for Gemini
    const prompt = createWellnessPrompt(moodData, stressData, sleepData);

    // Generate suggestions using Gemini
    const suggestions = await generateTaskSuggestions(prompt);

    res.json({
      success: true,
      suggestions: suggestions,
      wellnessData: {
        mood: moodData,
        stress: stressData,
        sleep: sleepData,
      },
    });
  } catch (error) {
    console.error("Error generating task suggestions:", error);
    res.status(500).json({
      error: "Failed to generate task suggestions",
      message: error.message,
    });
  }
});

module.exports = router;

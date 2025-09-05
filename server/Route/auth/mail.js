const nodemailer = require("nodemailer");


const transporter = nodemailer.createTransport({
  host: "smtp.gmail.com",
  port: 465,
  secure: true,
  auth: {
    user: process.env.GMAIL,
    pass: process.env.GMAIL_PASS,
  },
});


const sendMail = async (to, subject, otp) => {
    const text = `Your OTP is: ${otp}`;
    try {
        await transporter.sendMail({
        from: process.env.GMAIL,
        to,
        subject,
        text,
        });
        console.log("Email sent successfully");
        return true;
    } catch (error) {
        console.error("Error sending email:", error);
        return false;
    }
};

const sendEmergencyAlert = async (to, userName, alertType, moodData) => {
    let subject = "🚨 Mindora Emergency Alert - Mood Concern Detected";
    let text = "";

    if (alertType === "negative_mood_pattern") {
        text = `Dear Emergency Contact,

This is an automated alert from Mindora regarding ${userName}'s mental health status.

⚠️ CONCERN DETECTED: Prolonged Negative Mood Pattern

We have detected that ${userName} has experienced 5 or more days of negative moods (Sad, Angry, Depressed) with high intensity (level 3 or higher) in the past week.

Recent mood pattern:
${moodData.map(mood => `• ${mood.date}: ${mood.mood_status} (Intensity: ${mood.mood_level})`).join('\n')}

This pattern may indicate that ${userName} could benefit from additional support or professional assistance.

Please consider reaching out to ${userName} to check on their wellbeing.

For immediate mental health crisis support:
• National Suicide Prevention Lifeline: 988
• Crisis Text Line: Text HOME to 741741

This alert was sent automatically by Mindora's mental health monitoring system.

Best regards,
Mindora Mental Health Team`;
    } else if (alertType === "sudden_negative_shift") {
        text = `Dear Emergency Contact,

This is an automated alert from Mindora regarding ${userName}'s mental health status.

⚠️ CONCERN DETECTED: Sudden Negative Mood Shift

We have detected a concerning pattern where ${userName} had 3 or more consecutive days of positive/neutral moods, followed by a sudden shift to negative moods (Sad, Angry, Depressed) with high intensity (level 3+) for 3 or more consecutive days.

Recent mood pattern:
${moodData.map(mood => `• ${mood.date}: ${mood.mood_status} (Intensity: ${mood.mood_level})`).join('\n')}

This sudden shift in mood patterns may indicate that ${userName} could benefit from additional support or professional assistance.

Please consider reaching out to ${userName} to check on their wellbeing.

For immediate mental health crisis support:
• National Suicide Prevention Lifeline: 988
• Crisis Text Line: Text HOME to 741741

This alert was sent automatically by Mindora's mental health monitoring system.

Best regards,
Mindora Mental Health Team`;
    }

    try {
        await transporter.sendMail({
            from: process.env.GMAIL,
            to,
            subject,
            text,
        });
        console.log(`🚨 Emergency alert sent successfully to ${to} for user ${userName}`);
        return true;
    } catch (error) {
        console.error("❌ Error sending emergency alert:", error);
        return false;
    }
};

module.exports = {
    sendMail,
    sendEmergencyAlert
};

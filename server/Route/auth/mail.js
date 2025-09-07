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
    let htmlContent = "";

    if (alertType === "negative_mood_pattern") {
        htmlContent = `
        <div style="font-family: Arial, sans-serif; color: #000000; line-height: 1.6; max-width: 600px;">
            <p style="color: #000000;">Dear Emergency Contact,</p>
            
            <p style="color: #000000;">This is an automated alert from <strong><em>Mindora</em></strong> regarding <strong>${userName}</strong>'s mental health status.</p>
            
            <p style="color: #000000; font-weight: bold;">⚠️ CONCERN DETECTED: Prolonged Negative Mood Pattern</p>
            
            <p style="color: #000000;">We have detected that <strong>${userName}</strong> has experienced 5 or more days of negative moods (Sad, Angry, Depressed) with high intensity (level 3 or higher) in the past week.</p>
            
            <p style="color: #000000; font-weight: bold;">Recent mood pattern:</p>
            <ul style="color: #000000;">
            ${moodData.map(mood => {
                const dateOnly = new Date(mood.date).toLocaleDateString('en-GB');
                return `<li style="color: #000000;">${dateOnly}: ${mood.mood_status} (Intensity Level: ${mood.mood_level})</li>`;
            }).join('')}
            </ul>
            
            <p style="color: #000000;">This pattern may indicate that <strong>${userName}</strong> could benefit from additional support or professional assistance.</p>
            
            <p style="color: #000000;">Please consider reaching out to <strong>${userName}</strong> to check on their wellbeing. You can also book therapy appointments for <strong>${userName}</strong> through <strong><em>Mindora</em></strong> - please sign up if you haven't already.</p>
            
            <p style="color: #000000; font-weight: bold;">For immediate mental health crisis support in Bangladesh:</p>
            <ul style="color: #000000;">
                <li style="color: #000000;">Kaan Pete Roi Helpline: 09611-677678</li>
                <li style="color: #000000;">Suicide Prevention Hotline Bangladesh: 01779554391</li>
                <li style="color: #000000;">Moner Bondhu: 01833-334343</li>
            </ul>
            
            <p style="color: #000000;">This alert was sent automatically by <strong>Mindora</strong>'s mental health monitoring system.</p>
            
            <p style="color: #000000;">Best regards,<br>
            <strong><em>Mindora</em></strong> Mental Health Team</p>
        </div>`;
    } else if (alertType === "sudden_negative_shift") {
        htmlContent = `
        <div style="font-family: Arial, sans-serif; color: #000000; line-height: 1.6; max-width: 600px;">
            <p style="color: #000000;">Dear Emergency Contact,</p>
            
            <p style="color: #000000;">This is an automated alert from <strong><em>Mindora</em></strong> regarding <strong>${userName}</strong>'s mental health status.</p>
            
            <p style="color: #000000; font-weight: bold;">⚠️ CONCERN DETECTED: Sudden Negative Mood Shift</p>
            
            <p style="color: #000000;">We have detected a concerning pattern where <strong>${userName}</strong> had 3 or more consecutive days of positive/neutral moods, followed by a sudden shift to negative moods (Sad, Angry, Depressed) with high intensity (level 3+) for 3 or more consecutive days.</p>
            
            <p style="color: #000000; font-weight: bold;">Recent mood pattern:</p>
            <ul style="color: #000000;">
            ${moodData.map(mood => {
                const dateOnly = new Date(mood.date).toLocaleDateString('en-GB');
                return `<li style="color: #000000;">${dateOnly}: ${mood.mood_status} (Intensity Level: ${mood.mood_level})</li>`;
            }).join('')}
            </ul>
            
            <p style="color: #000000;">This sudden shift in mood patterns may indicate that <strong>${userName}</strong> could benefit from additional support or professional assistance.</p>
            
            <p style="color: #000000;">Please consider reaching out to <strong>${userName}</strong> to check on their wellbeing. You can also book therapy appointments for <strong>${userName}</strong> through <strong><em>Mindora</em></strong> - please sign up if you haven't already.</p>
            
            <p style="color: #000000; font-weight: bold;">For immediate mental health crisis support in Bangladesh:</p>
            <ul style="color: #000000;">
                <li style="color: #000000;">Kaan Pete Roi Helpline: 09611-677678</li>
                <li style="color: #000000;">Suicide Prevention Hotline Bangladesh: 01779554391</li>
                <li style="color: #000000;">Moner Bondhu: 01833-334343</li>
            </ul>
            
            <p style="color: #000000;">This alert was sent automatically by <strong><em>Mindora</em></strong>'s mental health monitoring system.</p>
            
            <p style="color: #000000;">Best regards,<br>
            <strong><em>Mindora</em></strong> Mental Health Team</p>
        </div>`;
    }

    try {
        await transporter.sendMail({
            from: process.env.GMAIL,
            to,
            subject,
            html: htmlContent,
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

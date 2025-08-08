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

module.exports = {
    sendMail
};

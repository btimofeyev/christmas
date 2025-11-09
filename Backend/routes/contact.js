import express from 'express';
import nodemailer from 'nodemailer';

const router = express.Router();

// Create a transporter using SMTP (we'll use Gmail for simplicity)
const createTransporter = () => {
    // For development, we'll use a test configuration
    // In production, you should set up proper SMTP credentials
    return nodemailer.createTransporter({
        service: 'gmail',
        auth: {
            user: process.env.EMAIL_USER || 'btimofeyev@gmail.com',
            pass: process.env.EMAIL_PASS // You'll need to set this up with an app password
        }
    });
};

// POST /contact/send
// Send contact form email
router.post('/send', async (req, res) => {
    try {
        const { name, email, subject, message } = req.body;

        // Validate required fields
        if (!name || !email || !subject || !message) {
            return res.status(400).json({
                success: false,
                error: 'All fields are required'
            });
        }

        // Validate email format
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            return res.status(400).json({
                success: false,
                error: 'Invalid email address'
            });
        }

        console.log('📧 Contact form submission:', {
            name,
            email,
            subject,
            messageLength: message.length
        });

        // For now, just log the message and return success
        // In production, you would set up actual email sending
        console.log('📨 New contact message from HolidayHome AI:');
        console.log(`From: ${name} (${email})`);
        console.log(`Subject: ${subject}`);
        console.log(`Message: ${message}`);
        console.log('---');

        // TODO: Set up actual email sending in production
        // Uncomment this code when you have proper SMTP credentials:

        /*
        const transporter = createTransporter();

        const mailOptions = {
            from: process.env.EMAIL_USER || 'btimofeyev@gmail.com',
            to: 'btimofeyev@gmail.com',
            subject: `HolidayHome AI Contact: ${subject}`,
            html: `
                <h2>New Contact Form Submission</h2>
                <p><strong>Name:</strong> ${name}</p>
                <p><strong>Email:</strong> ${email}</p>
                <p><strong>Subject:</strong> ${subject}</p>
                <h3>Message:</h3>
                <p>${message.replace(/\n/g, '<br>')}</p>
                <hr>
                <p><em>Sent from HolidayHome AI contact form</em></p>
            `
        };

        await transporter.sendMail(mailOptions);
        */

        res.json({
            success: true,
            message: 'Message sent successfully'
        });

    } catch (error) {
        console.error('❌ Error sending contact email:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to send message'
        });
    }
});

export default router;
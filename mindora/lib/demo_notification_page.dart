import 'package:flutter/material.dart';
import 'package:client/services/notification_service.dart';

class DemoNotificationPage extends StatelessWidget {
  const DemoNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Demo Notification',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF4A148C),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF4A148C).withOpacity(0.1),
              const Color(0xFFBA68C8).withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A148C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.notifications,
                    size: 60,
                    color: Color(0xFF4A148C),
                  ),
                ),

                const SizedBox(height: 30),

                // Title
                const Text(
                  'Demo Notification',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A148C),
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Description
                const Text(
                  'Tap the button below to send a demo notification to your device. Make sure you have allowed notifications for this app.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF757575),
                    fontFamily: 'Poppins',
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Notification Button
                ElevatedButton(
                  onPressed: () async {
                    await NotificationService.showNotification(
                      title: '🌟 MindOra Demo',
                      body:
                          'This is a demo notification from your Mental Health Dashboard!',
                      summary: 'Demo notification sent successfully',
                    );

                    // Show success message
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Demo notification sent! Check your notification panel.',
                            style: TextStyle(fontFamily: 'Poppins'),
                          ),
                          backgroundColor: const Color(0xFF4A148C),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A148C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 3,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.send, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Send Demo Notification',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Additional notification examples
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'More Notification Types',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A148C),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Reminder notification
                        _buildNotificationTile(
                          context,
                          'Meditation Reminder',
                          '🧘‍♀️ Time for your daily meditation session!',
                          Icons.self_improvement,
                        ),

                        const SizedBox(height: 8),

                        // Mood check notification
                        _buildNotificationTile(
                          context,
                          'Mood Check-in',
                          '💭 How are you feeling today? Track your mood now.',
                          Icons.emoji_emotions,
                        ),

                        const SizedBox(height: 8),

                        // Sleep reminder
                        _buildNotificationTile(
                          context,
                          'Sleep Reminder',
                          '😴 Time to wind down for a good night\'s sleep.',
                          Icons.bedtime,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    String title,
    String body,
    IconData icon,
  ) {
    return InkWell(
      onTap: () async {
        await NotificationService.showNotification(title: title, body: body);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$title notification sent!',
                style: const TextStyle(fontFamily: 'Poppins'),
              ),
              backgroundColor: const Color(0xFF4A148C),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF4A148C).withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF4A148C).withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF4A148C), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF4A148C),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    body,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.send, color: Color(0xFF4A148C), size: 18),
          ],
        ),
      ),
    );
  }
}

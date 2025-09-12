import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:client/services/user_service.dart';
import 'package:intl/intl.dart'; // Import DateFormat for parsing the time
import '../backend.dart';

class AppointmentNotificationService {
  static const String _appointmentNotificationId = 'appointment_reminder';

  /// Schedule appointment reminder notification 30 minutes before the appointment
  static Future<void> scheduleAppointmentReminder() async {
    try {
      // Get the current user ID from UserService (assuming it's already stored)
      final userData = await UserService.getUserData();
      final userId = userData['userId'] ?? '';

      if (userId.isEmpty) {
        print('❌ No user ID found, skipping appointment reminder check');
        return;
      }
      // Fetch the user's appointments
      final appointments = await GetAppointments(userId);

      if (appointments.isEmpty) {
        print('❌ No appointments found for the user');
        return;
      }

      final now = DateTime.now();

      // Loop through all appointments
      for (var appointment in appointments) {
        // Assuming each appointment has a 'time' field in the format '10:00 AM'
        final appointmentTimeString = appointment['time'];

        print("Appointment time is: ");
        print(appointmentTimeString);

        // Parse the appointment time into a DateTime object (same day as now)
        final appointmentTime = _parseAppointmentTime(appointmentTimeString);

        print("After formatting: ");
        print(appointmentTime);

        // Calculate the time difference between the appointment time and now
        final timeDifference = appointmentTime.difference(now);

        // Check if the appointment is within 30 minutes
        if (timeDifference.inMinutes == 30) {
          // Schedule the notification
          await _showAppointmentReminderNotification(appointment);

          
        }
      }
    } catch (e) {
      print('❌ Error scheduling appointment reminder: $e');
    }
  }

  /// Parse the appointment time string (e.g., '10:00 AM') into a DateTime object
  static DateTime _parseAppointmentTime(String timeString) {
    final now = DateTime.now();
    final formatter = DateFormat('h:mm a'); // Format used to parse '10:00 AM'
    final appointmentTime = formatter.parse(
      timeString,
    ); // Parse the string to DateTime

    // Return a DateTime object with today's date and the parsed time
    return DateTime(
      now.year,
      now.month,
      now.day,
      appointmentTime.hour,
      appointmentTime.minute,
    );
  }

  /// Show immediate appointment reminder notification
  static Future<void> _showAppointmentReminderNotification(
    Map<String, dynamic> appointment,
  ) async {
    final appointmentTitle = appointment['title'] ?? 'Your Appointment';
    final appointmentTime = appointment['time'] ?? 'Unknown Time';

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'high_importance_channel',
        title: '📅 Appointment Reminder',
        body:
            'You have an appointment in 30 minutes: $appointmentTitle at $appointmentTime',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        payload: {
          'type': 'appointment_reminder',
          'navigate': 'true',
          'page': 'appointment_details', // You can change this if needed
        },
      ),
    );
    print('✅ Appointment reminder notification sent');
  }

  /// Cancel all scheduled appointment reminders
  static Future<void> cancelAppointmentReminder() async {
    await AwesomeNotifications().cancelAll();
  }
}

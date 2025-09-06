import 'package:awesome_notifications/awesome_notifications.dart';
import '../therapist/backend.dart';

class AppointmentNotificationService {
  /// Schedule a notification for 1 hour before appointment
  static Future<void> scheduleAppointmentReminder(Appointment appointment) async {
    try {
      // Parse the appointment date and time
      DateTime appointmentDateTime = _parseAppointmentDateTime(
        appointment.originalDate, 
        appointment.time
      );
      
      // Calculate 1 hour before the appointment
      DateTime reminderDateTime = appointmentDateTime.subtract(const Duration(hours: 1));
      
      // Only schedule if the reminder time is in the future
      final now = DateTime.now();
      if (reminderDateTime.isAfter(now)) {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: appointment.appId.hashCode,
            channelKey: 'high_importance_channel',
            title: 'Upcoming Appointment Reminder',
            body: 'You have an appointment with ${appointment.userName} at ${appointment.time}',
            notificationLayout: NotificationLayout.Default,
            category: NotificationCategory.Reminder,
            payload: {
              'appointment_id': appointment.appId,
              'patient_name': appointment.userName,
              'appointment_time': appointment.time,
              'appointment_date': appointment.date,
              'type': 'appointment_reminder',
              'navigate': 'true',
            },
          ),
          schedule: NotificationCalendar(
            year: reminderDateTime.year,
            month: reminderDateTime.month,
            day: reminderDateTime.day,
            hour: reminderDateTime.hour,
            minute: reminderDateTime.minute,
            second: 0,
            millisecond: 0,
          ),
        );
        
        print('✅ Appointment reminder scheduled for ${appointment.userName} at $reminderDateTime');
      } else {
        print('⚠️ Reminder time is in the past, skipping notification for ${appointment.userName}');
      }
    } catch (e) {
      print('❌ Error scheduling appointment reminder: $e');
    }
  }

  /// Cancel appointment notification
  static Future<void> cancelAppointmentNotification(String appointmentId) async {
    try {
      await AwesomeNotifications().cancel(appointmentId.hashCode);
      print('✅ Cancelled notification for appointment: $appointmentId');
    } catch (e) {
      print('❌ Error cancelling appointment notification: $e');
    }
  }

  /// Schedule notifications for multiple appointments
  static Future<void> scheduleMultipleAppointmentReminders(List<Appointment> appointments) async {
    int scheduledCount = 0;
    for (Appointment appointment in appointments) {
      // Only schedule for appointments that have reminder enabled ('yes' or 'on')
      if (appointment.reminder == 'yes' || appointment.reminder == 'on') {
        await scheduleAppointmentReminder(appointment);
        scheduledCount++;
      }
    }
    
    // Show immediate test notification to confirm notifications are working
    if (scheduledCount > 0) {
      await showTestNotification(scheduledCount);
    }
  }

  /// Show an immediate test notification to verify notifications are working
  static Future<void> showTestNotification(int appointmentCount) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'high_importance_channel',
          title: '🔔 Notifications Working!',
          body: 'Scheduled $appointmentCount appointment reminder(s). You will receive notifications 1 hour before each appointment.',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Status,
          payload: {
            'type': 'test_notification',
          },
        ),
      );
      print('✅ Test notification sent - $appointmentCount reminders scheduled');
    } catch (e) {
      print('❌ Error showing test notification: $e');
    }
  }

  /// Show immediate test notification for a single appointment (for manual testing)
  static Future<void> showImmediateTestNotification(Appointment appointment) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'high_importance_channel',
          title: '🧪 TEST: Appointment Reminder',
          body: 'You have an appointment with ${appointment.userName} at ${appointment.time}',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
          payload: {
            'appointment_id': appointment.appId,
            'patient_name': appointment.userName,
            'appointment_time': appointment.time,
            'appointment_date': appointment.date,
            'type': 'test_appointment_reminder',
            'navigate': 'true',
          },
        ),
      );
      print('✅ Immediate test notification sent for appointment with ${appointment.userName}');
    } catch (e) {
      print('❌ Error showing immediate test notification: $e');
    }
  }

  /// Cancel all appointment notifications for a doctor
  static Future<void> cancelAllAppointmentNotifications(List<Appointment> appointments) async {
    for (Appointment appointment in appointments) {
      await cancelAppointmentNotification(appointment.appId);
    }
  }

  /// Parse appointment date and time into a DateTime object
  static DateTime _parseAppointmentDateTime(String originalDate, String time) {
    try {
      // Parse the original ISO date
      DateTime dateOnly = DateTime.parse(originalDate);
      
      // Parse the time (assuming format like "14:30" or "2:30")
      List<String> timeParts = time.split(':');
      int hour = int.parse(timeParts[0]);
      int minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;
      
      // Combine date and time
      DateTime appointmentDateTime = DateTime(
        dateOnly.year,
        dateOnly.month,
        dateOnly.day,
        hour,
        minute,
      );
      
      return appointmentDateTime;
    } catch (e) {
      print('❌ Error parsing appointment date/time: $e');
      // Return current time as fallback
      return DateTime.now();
    }
  }

  /// Show immediate notification for appointment starting now
  static Future<void> showAppointmentStartingNotification(Appointment appointment) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'high_importance_channel',
          title: 'Appointment Starting Now! 📅',
          body: 'Your appointment with ${appointment.userName} is starting now',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Alarm,
          payload: {
            'appointment_id': appointment.appId,
            'patient_name': appointment.userName,
            'appointment_time': appointment.time,
            'type': 'appointment_starting',
            'navigate': 'true',
          },
        ),
      );
    } catch (e) {
      print('❌ Error showing appointment starting notification: $e');
    }
  }

  /// Check if there are any appointments starting soon and notify
  static Future<void> checkUpcomingAppointments(List<Appointment> appointments) async {
    final now = DateTime.now();
    
    for (Appointment appointment in appointments) {
      try {
        DateTime appointmentDateTime = _parseAppointmentDateTime(
          appointment.originalDate, 
          appointment.time
        );
        
        // Check if appointment is starting within next 5 minutes
        Duration difference = appointmentDateTime.difference(now);
        if (difference.inMinutes >= 0 && difference.inMinutes <= 5) {
          await showAppointmentStartingNotification(appointment);
        }
      } catch (e) {
        print('❌ Error checking upcoming appointment: $e');
      }
    }
  }
}

import 'package:awesome_notifications/awesome_notifications.dart';
import '../therapist/backend.dart';

class AppointmentNotificationService {
  /// Schedule a notification for 10 minutes before appointment
  static Future<void> scheduleAppointmentReminder(Appointment appointment) async {
    try {
      print('🔍 === APPOINTMENT NOTIFICATION SCHEDULING ===');
      print('📋 Appointment ID: ${appointment.appId}');
      print('👤 Patient: ${appointment.userName}');
      print('📅 Display Date: ${appointment.date}');
      print('📅 Original Date: ${appointment.originalDate}');
      print('🕐 Time: ${appointment.time}');
      print('🔔 Reminder Status: ${appointment.reminder}');
      
      // Parse the appointment date and time
      DateTime appointmentDateTime = _parseAppointmentDateTime(
        appointment.originalDate, 
        appointment.time
      );
      
      // Calculate 10 minutes before the appointment
      DateTime reminderDateTime = appointmentDateTime.subtract(const Duration(minutes: 10));
      
      // Only schedule if the reminder time is in the future
      final now = DateTime.now();
      print('🕐 Current time: $now');
      print('🕐 Appointment time: $appointmentDateTime');
      print('🕐 Reminder time: $reminderDateTime');
      print('🕐 Is reminder in future? ${reminderDateTime.isAfter(now)}');
      print('🕐 Time difference: ${reminderDateTime.difference(now)}');
      
      if (reminderDateTime.isAfter(now)) {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: appointment.appId.hashCode,
            channelKey: 'high_importance_channel',
            title: 'Upcoming Appointment Reminder',
            body: 'You have an appointment with ${appointment.userName} at ${appointment.time}',
            notificationLayout: NotificationLayout.Default,
            category: NotificationCategory.Reminder,
            wakeUpScreen: true,
            fullScreenIntent: true,
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
            allowWhileIdle: true,
            preciseAlarm: true,
          ),
        );
        
        print('✅ Appointment reminder scheduled for ${appointment.userName} at $reminderDateTime');
        print('📅 Scheduled notification with ID: ${appointment.appId.hashCode}');
        print('📱 Notification details: ${reminderDateTime.year}-${reminderDateTime.month.toString().padLeft(2, '0')}-${reminderDateTime.day.toString().padLeft(2, '0')} ${reminderDateTime.hour.toString().padLeft(2, '0')}:${reminderDateTime.minute.toString().padLeft(2, '0')}');
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
          body: 'Scheduled $appointmentCount appointment reminder(s). You will receive notifications 10 minutes before each appointment.',
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
      print('🔍 === DATE/TIME PARSING ===');
      print('📅 Input originalDate: "$originalDate"');
      print('🕐 Input time: "$time"');
      print('🌍 System timezone: ${DateTime.now().timeZoneName}');
      print('🌍 System timezone offset: ${DateTime.now().timeZoneOffset}');
      
      // Parse the date more robustly
      DateTime dateOnly;
      
      if (originalDate.contains('T')) {
        // ISO format like "2025-09-09T00:00:00.000Z"
        print('📋 Detected ISO format with T');
        DateTime parsedDateTime = DateTime.parse(originalDate).toLocal();
        // Extract ONLY the date components, ignore the time part from the date field
        dateOnly = DateTime(parsedDateTime.year, parsedDateTime.month, parsedDateTime.day);
        print('📅 Parsed ISO date: $parsedDateTime -> Extracted date only: $dateOnly');
      } else if (originalDate.contains('-') && originalDate.length >= 10) {
        // Date format like "2025-09-09"
        print('📋 Detected simple date format');
        List<String> parts = originalDate.substring(0, 10).split('-');
        if (parts.length == 3) {
          int year = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int day = int.parse(parts[2]);
          dateOnly = DateTime(year, month, day);
          print('📅 Parsed simple date: $dateOnly (Y:$year M:$month D:$day)');
        } else {
          dateOnly = DateTime.parse(originalDate);
        }
      } else {
        // Fallback to regular parsing
        print('📋 Using fallback parsing');
        dateOnly = DateTime.parse(originalDate);
      }
      
      // Parse the time (handle various formats like "9.00AM", "9:00 AM", "14:30", etc.)
      int hour = 0;
      int minute = 0;
      
      String timeStr = time.trim().toUpperCase();
      print('🕐 Processing time string: "$timeStr"');
      
      // Handle AM/PM format
      bool isPM = timeStr.contains('PM');
      bool isAM = timeStr.contains('AM');
      
      // Remove AM/PM and clean the string
      timeStr = timeStr.replaceAll('AM', '').replaceAll('PM', '').trim();
      
      // Handle different separators (: or .)
      List<String> timeParts;
      if (timeStr.contains(':')) {
        timeParts = timeStr.split(':');
      } else if (timeStr.contains('.')) {
        timeParts = timeStr.split('.');
      } else {
        // Just hour number
        timeParts = [timeStr];
      }
      
      if (timeParts.isNotEmpty) {
        hour = int.parse(timeParts[0]);
        if (timeParts.length > 1) {
          minute = int.parse(timeParts[1]);
        }
        
        // Convert 12-hour to 24-hour format
        if (isPM && hour != 12) {
          hour += 12;
        } else if (isAM && hour == 12) {
          hour = 0;
        }
      }
      
      print('🕐 Parsed time: ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} (24-hour format)');
      
      // Create appointment time using parsed date components
      DateTime appointmentDateTime = DateTime(
        dateOnly.year,
        dateOnly.month,
        dateOnly.day,
        hour,
        minute,
      );
      
      print('� Final combined DateTime: $appointmentDateTime');
      print('🌍 Final timezone: ${appointmentDateTime.timeZoneName}');
      print('🌍 Final timezone offset: ${appointmentDateTime.timeZoneOffset}');
      print('🔍 === END PARSING ===');
      
      return appointmentDateTime;
    } catch (e) {
      print('❌ Error parsing appointment date/time: originalDate="$originalDate", time="$time", error: $e');
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

  /// Create a test notification scheduled for a specific time
  static Future<void> createTestNotificationAt(int hour, int minute) async {
    try {
      // Get current date and set specific time
      DateTime now = DateTime.now();
      DateTime testTime = DateTime(now.year, now.month, now.day, hour, minute, 0);
      
      // If it's already past the time today, schedule for tomorrow
      if (now.isAfter(testTime)) {
        testTime = testTime.add(const Duration(days: 1));
      }
      
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 999999, // Unique ID for test notification
          channelKey: 'high_importance_channel',
          title: '🧪 Scheduled Test Notification',
          body: 'This is your test notification scheduled for ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}!',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
          fullScreenIntent: true,
          criticalAlert: true,
          payload: {
            'type': 'test_scheduled_notification',
            'scheduled_time': testTime.toString(),
          },
        ),
        schedule: NotificationCalendar(
          year: testTime.year,
          month: testTime.month,
          day: testTime.day,
          hour: testTime.hour,
          minute: testTime.minute,
          second: 0,
          millisecond: 0,
          repeats: false,
          allowWhileIdle: true,
          preciseAlarm: true,
        ),
      );
      
      print('✅ Test notification scheduled for: $testTime');
      
      // Show immediate confirmation
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'high_importance_channel',
          title: '✅ Test Scheduled Successfully',
          body: 'Notification scheduled for ${testTime.hour.toString().padLeft(2, '0')}:${testTime.minute.toString().padLeft(2, '0')} ${testTime.day == now.day ? 'today' : 'tomorrow'}',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Status,
        ),
      );
      
    } catch (e) {
      print('❌ Error creating test notification: $e');
    }
  }

  /// Create a test notification for 2 minutes from now
  static Future<void> createTestNotificationSoon() async {
    try {
      DateTime now = DateTime.now();
      DateTime testTime = now.add(const Duration(minutes: 2));
      
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 888888, // Unique ID for soon test notification
          channelKey: 'high_importance_channel',
          title: '🚀 2-Minute Test Notification',
          body: 'This notification was scheduled 2 minutes ago and should appear now!',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
          fullScreenIntent: true,
          criticalAlert: true,
          payload: {
            'type': 'test_scheduled_notification_soon',
            'scheduled_time': testTime.toString(),
          },
        ),
        schedule: NotificationCalendar(
          year: testTime.year,
          month: testTime.month,
          day: testTime.day,
          hour: testTime.hour,
          minute: testTime.minute,
          second: 0,
          millisecond: 0,
          repeats: false,
          allowWhileIdle: true,
          preciseAlarm: true,
        ),
      );
      
      print('✅ Test notification scheduled for 2 minutes from now: $testTime');
      
      // Show immediate confirmation
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'high_importance_channel',
          title: '⏰ 2-Minute Test Set',
          body: 'You should receive a notification in 2 minutes at ${testTime.hour.toString().padLeft(2, '0')}:${testTime.minute.toString().padLeft(2, '0')}',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Status,
        ),
      );
      
    } catch (e) {
      print('❌ Error creating 2-minute test notification: $e');
    }
  }

  /// Create a test notification scheduled for any specific time
  static Future<void> createTestNotificationForTime(DateTime scheduledTime) async {
    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: scheduledTime.millisecondsSinceEpoch.remainder(100000),
          channelKey: 'high_importance_channel',
          title: '🧪 Scheduled Test Notification',
          body: 'This test notification was scheduled for ${scheduledTime.hour}:${scheduledTime.minute.toString().padLeft(2, '0')}',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
          fullScreenIntent: true,
          payload: {
            'type': 'test_scheduled_notification',
            'scheduled_time': scheduledTime.toString(),
          },
        ),
        schedule: NotificationCalendar(
          year: scheduledTime.year,
          month: scheduledTime.month,
          day: scheduledTime.day,
          hour: scheduledTime.hour,
          minute: scheduledTime.minute,
          second: 0,
          millisecond: 0,
          repeats: false,
          allowWhileIdle: true,
          preciseAlarm: true,
        ),
      );
      
      print('✅ Test notification scheduled for: $scheduledTime');
      
    } catch (e) {
      print('❌ Error creating test notification: $e');
    }
  }

  /// Debug function to check notification permissions and scheduled notifications
  static Future<void> debugNotificationSystem() async {
    try {
      print('🔍 === NOTIFICATION SYSTEM DEBUG ===');
      
      // Check permissions
      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
      print('📱 Notification permission: $isAllowed');
      
      // Check if we can schedule exact alarms (Android 12+)
      bool canScheduleExactAlarms = false;
      try {
        canScheduleExactAlarms = await AwesomeNotifications().isNotificationAllowed();
        print('⏰ Basic notification permission: $canScheduleExactAlarms');
      } catch (e) {
        print('⏰ Could not check exact alarm permission: $e');
      }
      
      // Get timezone info
      String timeZone = await AwesomeNotifications().getLocalTimeZoneIdentifier();
      print('🌍 Device timezone: $timeZone');
      
      // Check current time in different formats
      DateTime now = DateTime.now();
      DateTime utcNow = DateTime.now().toUtc();
      print('🕐 Local time: $now');
      print('🕐 UTC time: $utcNow');
      print('🕐 Timezone offset: ${now.timeZoneOffset}');
      
      print('🔍 === END DEBUG ===');
      
      // Show immediate notification with this info
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'high_importance_channel',
          title: '🔍 System Debug',
          body: 'Permissions: $isAllowed | Exact alarms: $canScheduleExactAlarms | TZ: $timeZone',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Status,
        ),
      );
      
    } catch (e) {
      print('❌ Error in notification system debug: $e');
    }
  }

  /// Test notification scheduling with detailed logging
  static Future<void> testNotificationScheduling() async {
    try {
      DateTime now = DateTime.now();
      DateTime testTime = now.add(const Duration(minutes: 1)); // 1 minute from now
      
      print('🧪 === NOTIFICATION SCHEDULING TEST ===');
      print('🕐 Current time: $now');
      print('🕐 Test notification scheduled for: $testTime');
      print('🔍 Difference: ${testTime.difference(now).inSeconds} seconds');
      
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 123456, // Fixed ID for testing
          channelKey: 'high_importance_channel',
          title: '🧪 Scheduling Test',
          body: 'This notification was scheduled for ${testTime.hour.toString().padLeft(2, '0')}:${testTime.minute.toString().padLeft(2, '0')}',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
          fullScreenIntent: true,
          criticalAlert: true,
        ),
        schedule: NotificationCalendar(
          year: testTime.year,
          month: testTime.month,
          day: testTime.day,
          hour: testTime.hour,
          minute: testTime.minute,
          second: 0,
          millisecond: 0,
          allowWhileIdle: true,
          preciseAlarm: true,
        ),
      );
      
      print('✅ Test notification scheduled successfully');
      
      // Also create an immediate confirmation
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          channelKey: 'high_importance_channel',
          title: '⏰ Test Scheduled',
          body: 'Notification set for ${testTime.hour.toString().padLeft(2, '0')}:${testTime.minute.toString().padLeft(2, '0')} (1 minute from now)',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Status,
        ),
      );
      
    } catch (e) {
      print('❌ Error in test notification scheduling: $e');
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

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:client/services/user_service.dart';
import '../backend.dart';

class SleepNotificationService {
  static const String _dailyNotificationId = 'daily_sleep_reminder';

  /// Schedule daily sleep reminder notification at 8:00 AM
  static Future<void> scheduleDailySleepReminder() async {
    print('📅 Creating scheduled sleep notification...');
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _dailyNotificationId.hashCode,
        channelKey: 'high_importance_channel',
        title: '🌅 Good Morning!',
        body: 'Have you logged your sleep hours today? Check your tracker!',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        payload: {
          'type': 'sleep_reminder',
          'navigate': 'true',
          'page': 'sleep_tracker',
        },
      ),
      schedule: NotificationCalendar(
        hour: 8,
        minute: 0,
        second: 0,
        millisecond: 0,
        repeats: true, // Repeat daily
      ),
    );
    print('✅ Scheduled sleep notification created for 8:00 AM');
  }

  /// Initialize sleep notification service - call this once in main.dart
  static Future<void> initializeSleepNotifications() async {
    // Schedule the daily reminder
    await scheduleDailySleepReminder();
    print('✅ Daily sleep reminder scheduled for 8:00 AM');
    print('🕐 Current time: ${DateTime.now()}');
  }

  /// Check if user has logged sleep hours today and show notification if not
  static Future<void> checkAndNotifySleepReminder() async {
    try {
      final userData = await UserService.getUserData();
      final userId = userData['userId'] ?? '';

      if (userId.isEmpty) {
        print('❌ No user ID found, skipping sleep reminder check');
        return;
      }

      final today = DateTime.now();

      // Check if sleep hours are already logged for today
      final hasLoggedSleep = await hasSleepRecord(userId: userId, date: today);

      if (hasLoggedSleep) {
        // Sleep data already logged today, don't send notification
        print('✅ Sleep hours already logged today, skipping notification');
        return;
      }

      // Only send notification if it's 8 AM or later and no sleep logged
      final now = DateTime.now();
      if (now.hour >= 7) {
        await _showSleepReminderNotification();
      }
    } catch (e) {
      print('❌ Error checking sleep reminder: $e');
    }
  }

  /// Show immediate sleep reminder notification
  static Future<void> _showSleepReminderNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'high_importance_channel',
        title: '🌙 Sleep Check-in',
        body:
            'You haven\'t logged your sleep hours today. How much sleep did you get?',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        payload: {
          'type': 'sleep_reminder',
          'navigate': 'true',
          'page': 'sleep_tracker',
        },
      ),
    );
  }

  /// Cancel daily sleep reminders
  static Future<void> cancelDailySleepReminder() async {
    await AwesomeNotifications().cancel(_dailyNotificationId.hashCode);
  }

  /// Show sleep completion celebration notification
  static Future<void> showSleepCompletedNotification(int hoursSlept) async {
    String emoji = _getSleepEmoji(hoursSlept);
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'high_importance_channel',
        title: 'Sleep Logged! $emoji',
        body: 'Great job! You logged $hoursSlept hours of sleep. Keep it up!',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Status,
      ),
    );
  }

  /// Get appropriate emoji for sleep status based on hours
  static String _getSleepEmoji(int hoursSlept) {
    if (hoursSlept >= 7) {
      return '😴'; // Good sleep
    } else if (hoursSlept >= 5) {
      return '😌'; // Fair sleep
    } else {
      return '🥱'; // Not enough sleep
    }
  }
}

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:client/stress/backend.dart';
import 'package:client/services/user_service.dart';

class StressNotificationService {
  static const String _dailyNotificationId = 'daily_stress_reminder';

  /// Schedule daily stress reminder notification at 8:00 PM
  static Future<void> scheduleDailyStressReminder() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _dailyNotificationId.hashCode,
        channelKey: 'high_importance_channel',
        title: '🧘 Evening Check-in',
        body:
            'How was your stress level today? Take a moment to track your well-being.',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        payload: {
          'type': 'stress_reminder',
          'navigate': 'true',
          'page': 'stress_tracker',
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
  }

  /// Initialize stress notification service - call this once in main.dart
  static Future<void> initializeStressNotifications() async {
    // Schedule the daily reminder
    await scheduleDailyStressReminder();
    print('✅ Daily stress reminder scheduled for 7:00 AM');
    print('🕐 Current time: ${DateTime.now()}');

    // Test immediate notification - commented out for production
    // await testImmediateNotification();
  }

  /// Test function to create immediate notification
  static Future<void> testImmediateNotification() async {
    try {
      print('📱 Testing immediate stress notification...');
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 9998,
          channelKey: 'high_importance_channel',
          title: '🧪 TEST: Stress Notification',
          body:
              'This is a test stress notification. If you see this, notifications are working!',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
          payload: {'page': 'stress_tracker', 'test': 'true'},
        ),
      );
      print('✅ Test stress notification created successfully!');
    } catch (e) {
      print('❌ Error creating test notification: $e');
    }
  }

  /// Check if user has logged stress today and show notification if not
  static Future<void> checkAndNotifyStressReminder() async {
    try {
      final userData = await UserService.getUserData();
      final userId = userData['userId'] ?? '';

      if (userId.isEmpty) {
        print('❌ No user ID found, skipping stress reminder check');
        return;
      }

      // Check if stress is already logged for today
      final result = await StressTrackerBackend.getTodayStressData(userId);

      if (result['success'] == true && result['data'] != null) {
        // Stress already logged today, don't send notification
        print('✅ Stress already logged today, skipping notification');
        return;
      }

      // Only send notification if it's 7 AM or later and no stress logged
      final now = DateTime.now();
      if (now.hour >= 7) {
        await _showStressReminderNotification();
      }
    } catch (e) {
      print('❌ Error checking stress reminder: $e');
    }
  }

  /// Show immediate stress reminder notification
  static Future<void> _showStressReminderNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'high_importance_channel',
        title: '🌙 Stress Check-in',
        body:
            'You haven\'t logged your stress level today. How are you feeling?',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        payload: {
          'type': 'stress_reminder',
          'navigate': 'true',
          'page': 'stress_tracker',
        },
      ),
    );
  }

  /// Cancel daily stress reminders
  static Future<void> cancelDailyStressReminder() async {
    await AwesomeNotifications().cancel(_dailyNotificationId.hashCode);
  }

  /// Show stress completion celebration notification
  static Future<void> showStressCompletedNotification(int stressLevel) async {
    String emoji = _getStressEmoji(stressLevel);
    String message = _getStressMessage(stressLevel);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'high_importance_channel',
        title: 'Stress Level Logged! $emoji',
        body: message,
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Status,
      ),
    );
  }

  /// Get appropriate emoji for stress level
  static String _getStressEmoji(int stressLevel) {
    if (stressLevel <= 2) {
      return '😌'; // Very low stress
    } else if (stressLevel <= 4) {
      return '😊'; // Low stress
    } else if (stressLevel <= 6) {
      return '😐'; // Moderate stress
    } else if (stressLevel <= 8) {
      return '😰'; // High stress
    } else {
      return '😵'; // Very high stress
    }
  }

  /// Get appropriate message for stress level
  static String _getStressMessage(int stressLevel) {
    if (stressLevel <= 2) {
      return 'Great to see you\'re feeling calm and relaxed! Keep it up!';
    } else if (stressLevel <= 4) {
      return 'You\'re managing your stress well. Take care of yourself!';
    } else if (stressLevel <= 6) {
      return 'Moderate stress detected. Consider some relaxation techniques.';
    } else if (stressLevel <= 8) {
      return 'High stress level noted. Please take time for self-care.';
    } else {
      return 'Very high stress detected. Consider reaching out for support.';
    }
  }
}

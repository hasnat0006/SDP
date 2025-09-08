import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:client/mood/backend.dart';
import 'package:client/services/user_service.dart';

class MoodNotificationService {
  static const String _dailyNotificationId = 'daily_mood_reminder';

  /// Schedule daily mood reminder notification at 8:00 AM
  static Future<void> scheduleDailyMoodReminder() async {
    print('📅 Creating scheduled mood notification...');
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _dailyNotificationId.hashCode,
        channelKey: 'high_importance_channel',
        title: '🌅 Good Morning!',
        body: 'How are you feeling today? Take a moment to log your mood.',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        payload: {
          'type': 'mood_reminder',
          'navigate': 'true',
          'page': 'mood_spinner',
        },
      ),
      schedule: NotificationCalendar(
        hour: 7,
        minute: 0,
        second: 0,
        millisecond: 0,
        repeats: true, // Repeat daily
      ),
    );
    print('✅ Scheduled mood notification created for 11:17 AM');
  }

  /// Initialize mood notification service - call this once in main.dart
  static Future<void> initializeMoodNotifications() async {
    // Schedule the daily reminder
    await scheduleDailyMoodReminder();
    print('✅ Daily mood reminder scheduled for 11:22 AM');
    print('🕐 Current time: ${DateTime.now()}');
  }

  /// Check if user has logged mood today and show notification if not
  static Future<void> checkAndNotifyMoodReminder() async {
    try {
      final userData = await UserService.getUserData();
      final userId = userData['userId'] ?? '';
      
      if (userId.isEmpty) {
        print('❌ No user ID found, skipping mood reminder check');
        return;
      }

      final today = DateTime.now();
      
      // Check if mood is already logged for today
      final result = await MoodTrackerBackend.getMoodDataForDate(userId, today);
      
      if (result['success'] == true && result['data'] != null) {
        // Mood already logged today, don't send notification
        print('✅ Mood already logged today, skipping notification');
        return;
      }

      // Only send notification if it's 8 AM or later and no mood logged
      final now = DateTime.now();
      if (now.hour >= 7) {
        await _showMoodReminderNotification();
      }
    } catch (e) {
      print('❌ Error checking mood reminder: $e');
    }
  }

  /// Show immediate mood reminder notification
  static Future<void> _showMoodReminderNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'high_importance_channel',
        title: '🌟 Mood Check-in',
        body: 'You haven\'t logged your mood today. How are you feeling?',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        payload: {
          'type': 'mood_reminder',
          'navigate': 'true',
          'page': 'mood_spinner',
        },
      ),
    );
  }

  /// Cancel daily mood reminders
  static Future<void> cancelDailyMoodReminder() async {
    await AwesomeNotifications().cancel(_dailyNotificationId.hashCode);
  }

  /// Show mood completion celebration notification
  static Future<void> showMoodCompletedNotification(String moodStatus) async {
    String emoji = _getMoodEmoji(moodStatus);
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'high_importance_channel',
        title: 'Mood Logged! $emoji',
        body: 'Thank you for sharing how you feel. Take care of yourself!',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Status,
      ),
    );
  }

  /// Get appropriate emoji for mood status
  static String _getMoodEmoji(String moodStatus) {
    switch (moodStatus.toLowerCase()) {
      case 'happy':
      case 'joyful':
        return '😊';
      case 'excited':
        return '😄';
      case 'content':
      case 'satisfied':
        return '😌';
      case 'calm':
      case 'relaxed':
        return '😊';
      case 'neutral':
        return '😐';
      case 'sad':
        return '😢';
      case 'angry':
        return '😠';
      case 'anxious':
      case 'worried':
        return '😰';
      case 'frustrated':
        return '😤';
      case 'overwhelmed':
        return '😵';
      default:
        return '🌟';
    }
  }
}
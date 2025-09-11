import 'package:client/appointment/service/realtimenotification.dart';
import 'package:client/services/user_service.dart';

class NotificationManager {
  static bool _isInitialized = false;
  static String? _currentUserId;

  /// Initialize notifications for the current user
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final userData = await UserService.getUserData();
      final userId = userData['userId'] ?? '';
      final userType = userData['userType'] ?? '';

      if (userId.isNotEmpty && userType == 'user') {
        // Only initialize for regular users, not therapists
        _currentUserId = userId;
        RealTimeNotificationService.initializeForUser(userId);
        _isInitialized = true;
        print('✅ Notification manager initialized for user: $userId');
      }
    } catch (e) {
      print('❌ Error initializing notification manager: $e');
    }
  }

  /// Reinitialize notifications (useful after login)
  static Future<void> reinitialize() async {
    dispose();
    await initialize();
  }

  /// Clean up notifications
  static void dispose() {
    if (_isInitialized) {
      RealTimeNotificationService.dispose();
      _isInitialized = false;
      _currentUserId = null;
      print('🧹 Notification manager disposed');
    }
  }

  /// Check if notifications are initialized
  static bool get isInitialized => _isInitialized;

  /// Get current user ID
  static String? get currentUserId => _currentUserId;
}

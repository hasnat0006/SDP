import '../services/user_service.dart';
import '../services/notification_manager.dart';

/// Example utility class showing how to use stored user data throughout the app
class AppUtils {
  /// Get the current user's ID for API calls
  static Future<String?> getCurrentUserId() async {
    return await UserService.getUserId();
  }

  /// Get the current user's type (patient or therapist)
  static Future<String?> getCurrentUserType() async {
    return await UserService.getUserType();
  }

  /// Check if user is authenticated
  static Future<bool> isUserAuthenticated() async {
    return await UserService.isLoggedIn();
  }

  /// Get user data for API calls
  static Future<Map<String, String?>> getCurrentUserData() async {
    return await UserService.getUserData();
  }

  /// Example: Make API call with user ID
  static Future<void> makeAuthenticatedApiCall() async {
    final userData = await getCurrentUserData();
    final userId = userData['userId'];
    final userType = userData['userType'];

    if (userId != null) {
      // Use userId and userType in your API calls
      print('Making API call for user: $userId (Type: $userType)');
      // Example: await SomeApiService.getData(userId: userId, userType: userType);
    } else {
      print('User not logged in');
      // Handle unauthenticated state
    }
  }

  /// Example: Check authentication before navigation
  static Future<bool> requiresLogin() async {
    final isLoggedIn = await isUserAuthenticated();
    if (!isLoggedIn) {
      // Navigate to login page
      return false;
    }
    return true;
  }

  /// Logout user and clear stored data
  static Future<void> logoutUser() async {
    // Dispose real-time notifications
    NotificationManager.dispose();
    await UserService.clearUserData();
    // Navigate to login page
    print('User logged out and data cleared');
  }

  /// Check if current user is a patient
  static Future<bool> isPatient() async {
    final userType = await getCurrentUserType();
    return userType == 'patient';
  }

  /// Check if current user is a doctor
  static Future<bool> isDoctor() async {
    final userType = await getCurrentUserType();
    return userType == 'doctor';
  }
}

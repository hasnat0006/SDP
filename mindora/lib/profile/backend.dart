import 'package:client/backend/main_query.dart';

class ProfileBackend {
  Future<Map<String, dynamic>> getUserProfile(
    String userId,
    String userType,
  ) async {
    final response = await getFromBackend(
      'profile/get-info?user_id=$userId&user_type=$userType',
    );
    return response;
  }

  Future<Map<String, dynamic>> getUserMoodData(String userId) async {
    final response = await getFromBackend('profile/get-mood?user_id=$userId');
    return response;
  }

  Future<Map<String, dynamic>> updateUserProfile(
    String userId,
    String userType,
    Map<String, dynamic> data,
  ) async {
    print("I am here");
    print(data);
    try {
      final response = await postToBackend('profile/update-info', {
        'user_id': userId,
        'user_type': userType,
        ...data,
      });
      return {
        'success': true,
        'message': 'Profile updated successfully!',
        'data': response,
      };
    } catch (e) {
      print('Error updating profile: $e');
      return {
        'success': false,
        'message': 'Failed to update profile: $e',
        'data': null,
      };
    }
  }

  /// Update profile with image URL
  Future<Map<String, dynamic>> updateUserProfileWithImage(
    String userId,
    String userType,
    String? profileImageUrl,
  ) async {
    print("Updating profile with image URL: $profileImageUrl");

    final profileData = {'user_id': userId, 'user_type': userType};

    // Add profile image URL if provided
    if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      profileData['profileImage'] = profileImageUrl;
    }

    print("Profile data being sent: $profileData");

    try {
      final response = await postToBackend(
        'profile/update-profile-image',
        profileData,
      );
      return {
        'success': true,
        'message': 'Profile image updated successfully!',
        'data': response,
      };
    } catch (e) {
      print('Error updating profile image: $e');
      return {
        'success': false,
        'message': 'Failed to update profile image: $e',
        'data': null,
      };
    }
  }
}

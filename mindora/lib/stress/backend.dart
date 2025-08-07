import '../services/main_query.dart';
import 'package:flutter/material.dart';
import '../../backend/main_query.dart';

class StressTrackerBackend {
  // Store stress tracking data
  static Future<Map<String, dynamic>> saveStressData({
    required String userId,  // Changed to String for UUID
    required int stressLevel,
    required List<String> cause,  // Changed to match DB column name
    required List<String> loggedSymptoms,  // Changed to match DB column name
    required List<String> Notes,  // Changed to match DB column name and type
    required DateTime date,
  }) async {
    try {
      final response = await postToBackend('stress/track', {
        'user_id': userId,  // Changed to match DB column name
        'stress_level': stressLevel,  // Changed to match DB column name
        'cause': cause,  // Now sending as array
        'logged_symptoms': loggedSymptoms,  // Changed to match DB column name
        'Notes': Notes,  // Changed to match DB column name
        'date': date.toIso8601String(),
      });

      return {
        'success': true,
        'message': 'Stress data saved successfully!',
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to save stress data: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  // Get stress tracking data for insights
  static Future<Map<String, dynamic>> getStressData(String userId) async {  // Changed to String for UUID
    try {
      final response = await getFromBackend('stress/data/$userId');
      // The response will include all fields as per the database schema
      // id, user_id, stress_level, date, cause, logged_symptoms, Notes
      return {
        'success': true,
        'message': 'Stress data retrieved successfully!',
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to retrieve stress data',
        'error': e.toString(),
      };
    }
  }

  // Get weekly stress data for graph
  static Future<Map<String, dynamic>> getWeeklyStressData(String userId) async {  // Changed to String for UUID
    try {
      final response = await getFromBackend('stress/weekly/$userId');
      // The response will include weekly aggregated data from the stress_tracker table
      return {
        'success': true,
        'message': 'Weekly stress data retrieved successfully!',
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to retrieve weekly stress data',
        'error': e.toString(),
      };
    }
  }

  // Helper function to parse stress causes
  static Map<String, IconData> getCauseIcons() {
    return {
      'Work/Study': Icons.work,
      'Relationships': Icons.people,
      'Health': Icons.favorite,
      'Family': Icons.home,
      'Financial': Icons.money,
      'Social Media': Icons.phone_android,
      'Academic': Icons.school,
      'Environmental': Icons.nature,
      'Sleep': Icons.bedtime,
      'Time Management': Icons.access_time,
      'Other': Icons.more_horiz,
    };
  }

  // Helper function to parse symptoms
  static Map<String, IconData> getSymptomIcons() {
    return {
      'Headache': Icons.sick,
      'Tension': Icons.fitness_center,
      'Fatigue': Icons.battery_alert,
      'Anxiety': Icons.psychology,
      'Sleep Issues': Icons.bedtime,
      'Appetite Changes': Icons.restaurant,
      'Mood Swings': Icons.mood_bad,
      'Restlessness': Icons.running_with_errors,
      'Physical Pain': Icons.healing,
      'Poor Concentration': Icons.psychology_outlined,
    };
  }

  // Get recommended activities based on stress level
  static List<Map<String, dynamic>> getRecommendedActivities(int stressLevel) {
    final List<Map<String, dynamic>> baseActivities = [
      {'name': 'Deep Breathing', 'icon': Icons.accessibility, 'duration': '5 mins'},
      {'name': 'Nature Walk', 'icon': Icons.directions_walk, 'duration': '15 mins'},
      {'name': 'Yoga', 'icon': Icons.self_improvement, 'duration': '10 mins'},
      {'name': 'Meditation', 'icon': Icons.spa, 'duration': '20 mins'},
      {'name': 'Stretching', 'icon': Icons.accessibility_new, 'duration': '7 mins'},
      {'name': 'Jogging', 'icon': Icons.directions_run, 'duration': '30 mins'},
    ];

    // Return activities based on stress level
    if (stressLevel <= 2) {
      return baseActivities.take(3).toList();
    } else if (stressLevel <= 4) {
      return baseActivities.take(4).toList();
    } else {
      return baseActivities;
    }
  }
}

import 'package:flutter/material.dart';
import '../../backend/main_query.dart';

class MoodTrackerBackend {
  // Store mood tracking data
  static Future<Map<String, dynamic>> saveMoodData({
    required String userId,  // Changed to String for UUID
    required String moodStatus,
    required int moodLevel,
    required List<String> reason,  // Changed to match DB column name
    required DateTime date,
  }) async {
    try {
      final response = await postToBackend('mood/track', {
        'user_id': userId,
        'mood_status': moodStatus,
        'mood_level': moodLevel,
        'reason': reason.isNotEmpty ? reason : <String>[], // Ensure it's List<String>
        'date': date.toIso8601String(),
      });

      return {
        'success': true,
        'data': response,
        'message': 'Mood data saved successfully'
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to save mood data'
      };
    }
  }

  // Get mood tracking data for insights
  static Future<Map<String, dynamic>> getMoodData(String userId) async {  // Changed to String for UUID
    try {
      final response = await getFromBackend('mood/data/$userId');
      
      // Cast the reason field to List<String> if it exists
      if (response.containsKey('reason') && response['reason'] != null) {
        final reasonData = response['reason'];
        if (reasonData is List) {
          response['reason'] = reasonData.map((item) => item.toString()).toList();
        } else {
          response['reason'] = <String>[];
        }
      } else {
        response['reason'] = <String>[];
      }
      
      // The response will include all fields as per the database schema
      // id, user_id, mood_status, mood_level, date, reason
      return {
        'success': true,
        'data': response,
        'message': 'Mood data retrieved successfully'
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to retrieve mood data'
      };
    }
  }

  // Get weekly mood data for graph
  static Future<Map<String, dynamic>> getWeeklyMoodData(String userId) async {  // Changed to String for UUID
    try {
      final response = await getFromBackend('mood/weekly/$userId');
      
      // Cast the reason field to List<String> for each entry if it exists
      if (response is List) {
        for (var entry in response) {
          if (entry is Map && entry.containsKey('reason') && entry['reason'] != null) {
            final reasonData = entry['reason'];
            if (reasonData is List) {
              entry['reason'] = reasonData.map((item) => item.toString()).toList();
            } else {
              entry['reason'] = <String>[];
            }
          } else if (entry is Map) {
            entry['reason'] = <String>[];
          }
        }
      }
      
      // The response will include weekly aggregated data from the mood_tracker table
      return {
        'success': true,
        'data': response,
        'message': 'Weekly mood data retrieved successfully'
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to retrieve weekly mood data'
      };
    }
  }

  // Get mood data for a specific date
  static Future<Map<String, dynamic>> getMoodDataForDate(String userId, DateTime date) async {
    try {
      final response = await getFromBackend('mood/data/$userId/${date.toIso8601String().split('T')[0]}');
      
      // Cast the reason field to List<String> if it exists
      if (response.containsKey('reason') && response['reason'] != null) {
        final reasonData = response['reason'];
        if (reasonData is List) {
          response['reason'] = reasonData.map((item) => item.toString()).toList();
        } else {
          response['reason'] = <String>[];
        }
      } else {
        response['reason'] = <String>[];
      }
      
      return {
        'success': true,
        'data': response,
        'message': 'Mood data for date retrieved successfully'
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to retrieve mood data for date'
      };
    }
  }

  // Get stress data for current date
  static Future<Map<String, dynamic>> getStressDataForDate(String userId, DateTime date) async {
    try {
      final response = await getFromBackend('stress/data/$userId/${date.toIso8601String().split('T')[0]}');
      return {
        'success': true,
        'data': response,
        'message': 'Stress data for date retrieved successfully'
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to retrieve stress data for date'
      };
    }
  }

  // Get sleep data for current date
  static Future<Map<String, dynamic>> getSleepDataForDate(String userId, DateTime date) async {
    try {
      final response = await getFromBackend('sleep/data/$userId/${date.toIso8601String().split('T')[0]}');
      return {
        'success': true,
        'data': response,
        'message': 'Sleep data for date retrieved successfully'
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to retrieve sleep data for date'
      };
    }
  }

  // Get monthly mood data for weekly overview
  static Future<Map<String, dynamic>> getMonthlyMoodData(String userId, DateTime date) async {
    try {
      final response = await getFromBackend('mood/monthly/$userId/${date.year}/${date.month}');
      
      // Process the response to ensure all reason fields are List<String>
      if (response is Map<String, dynamic>) {
        response.forEach((week, weekData) {
          if (weekData is List) {
            for (var entry in weekData) {
              if (entry is Map && entry.containsKey('reason') && entry['reason'] != null) {
                final reasonData = entry['reason'];
                if (reasonData is List) {
                  entry['reason'] = reasonData.map((item) => item.toString()).toList();
                } else {
                  entry['reason'] = <String>[];
                }
              } else if (entry is Map) {
                entry['reason'] = <String>[];
              }
            }
          }
        });
      }
      
      return {
        'success': true,
        'data': response,
        'message': 'Monthly mood data retrieved successfully'
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to retrieve monthly mood data'
      };
    }
  }

  // Helper function to get mood emoji
  static String getMoodEmoji(String moodStatus) {
    switch (moodStatus.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'sad':
        return '😢';
      case 'angry':
        return '😠';
      case 'anxious':
        return '😰';
      case 'excited':
        return '🤗';
      case 'calm':
        return '😌';
      case 'confused':
        return '😕';
      case 'tired':
        return '😴';
      case 'grateful':
        return '🙏';
      default:
        return '😐';
    }
  }

  // Helper function to get mood color
  static Color getMoodColor(String moodStatus) {
    switch (moodStatus.toLowerCase()) {
      case 'happy':
        return Colors.yellow;
      case 'sad':
        return Colors.blue;
      case 'angry':
        return Colors.red;
      case 'anxious':
        return Colors.orange;
      case 'excited':
        return Colors.green;
      case 'calm':
        return Colors.lightBlue;
      case 'confused':
        return Colors.purple;
      case 'tired':
        return Colors.grey;
      case 'grateful':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  // Helper function to parse mood causes
  static Map<String, IconData> getCauseIcons() {
    return {
      'Work': Icons.work,
      'Family': Icons.family_restroom,
      'Health': Icons.health_and_safety,
      'Financial': Icons.attach_money,
      'Medication': Icons.local_pharmacy,
      'Social': Icons.group,
      'Personal': Icons.person,
      'Academic': Icons.school,
      'Deadlines': Icons.alarm,
      'Weather': Icons.cloud,
      'Other': Icons.add_circle_outline,
    };
  }

  // Get mood intensity description
  static String getMoodIntensityDescription(String moodStatus, int moodLevel) {
    switch (moodLevel) {
      case 1:
        return "I feel just a little $moodStatus today.";
      case 2:
        return "I feel mildly $moodStatus today.";
      case 3:
        return "I feel moderately $moodStatus today.";
      case 4:
        return "I feel pretty $moodStatus today.";
      case 5:
        return "I feel extremely $moodStatus today.";
      default:
        return "I feel $moodStatus today.";
    }
  }

  // Get stress level description
  static String getStressLevelDescription(int stressLevel) {
    switch (stressLevel) {
      case 1:
        return "Very low stress - You're feeling relaxed and peaceful.";
      case 2:
        return "Low stress - You're feeling calm with minor concerns.";
      case 3:
        return "Moderate stress - You're managing well but feeling some pressure.";
      case 4:
        return "High stress - You're feeling overwhelmed and need some relief.";
      case 5:
        return "Very high stress - You're feeling extremely stressed and need immediate attention.";
      default:
        return "Stress level recorded.";
    }
  }

  // Get sleep hours description
  static String getSleepHoursDescription(double sleepHours) {
    if (sleepHours < 6) {
      return "You got ${sleepHours.toStringAsFixed(1)} hours of sleep - Try to get more rest tonight.";
    } else if (sleepHours < 7) {
      return "You got ${sleepHours.toStringAsFixed(1)} hours of sleep - A bit more rest would be beneficial.";
    } else if (sleepHours <= 9) {
      return "You got ${sleepHours.toStringAsFixed(1)} hours of sleep - Great job on getting adequate rest!";
    } else {
      return "You got ${sleepHours.toStringAsFixed(1)} hours of sleep - That's quite a lot of rest!";
    }
  }
}

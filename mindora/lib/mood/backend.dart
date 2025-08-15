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
      
      print('🔍 Backend Debug - Raw response: $response');
      
      // Cast the reason field to List<String> if it exists
      if (response.containsKey('reason') && response['reason'] != null) {
        final reasonData = response['reason'];
        print('🔍 Backend Debug - reasonData: $reasonData');
        if (reasonData is List) {
          response['reason'] = reasonData.map((item) => item.toString()).toList();
          print('✅ Backend Debug - Processed reason as List: ${response['reason']}');
        } else {
          response['reason'] = <String>[];
          print('⚠️ Backend Debug - reasonData is not a List, set to empty');
        }
      } else {
        response['reason'] = <String>[];
        print('⚠️ Backend Debug - No reason field found, set to empty');
      }
      
      return {
        'success': true,
        'data': response,
        'message': 'Mood data for date retrieved successfully'
      };
    } catch (e) {
      print('❌ Backend Debug - Exception caught: $e');
      // Check if it's a 404 error (no data found)
      if (e.toString().contains('404')) {
        print('ℹ️ Backend Debug - No mood data found for this date');
        return {
          'success': true,
          'data': null,
          'message': 'No mood data found for this date'
        };
      }
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
        return '�'; // Big smile
      case 'sad':
        return '�'; // Crying loudly
      case 'angry':
        return '�'; // Red angry face
      case 'anxious':
        return '😰'; // Anxious with sweat
      case 'excited':
        return '�'; // Star-struck excited
      case 'calm':
        return '🧘'; // Meditation pose
      case 'confused':
        return '🤔'; // Thinking face
      case 'tired':
        return '😴'; // Sleeping
      case 'grateful':
        return '🙏'; // Prayer hands
      case 'stressed':
        return '😫'; // Stressed/overwhelmed
      default:
        return '😐'; // Neutral
    }
  }

  // Helper function to get mood color
  static Color getMoodColor(String moodStatus) {
    switch (moodStatus.toLowerCase()) {
      case 'happy':
        return const Color(0xFFFFD700); // Bright gold instead of yellow
      case 'sad':
        return const Color(0xFF4A90E2); // Bright blue
      case 'angry':
        return const Color(0xFFE74C3C); // Bright red
      case 'anxious':
        return const Color(0xFFFF8C00); // Bright orange
      case 'excited':
        return const Color(0xFF2ECC71); // Bright green
      case 'calm':
        return const Color(0xFF87CEEB); // Sky blue
      case 'confused':
        return const Color(0xFF9B59B6); // Purple
      case 'tired':
        return const Color(0xFF95A5A6); // Light grey
      case 'grateful':
        return const Color(0xFFE91E63); // Bright pink
      case 'stressed':
        return const Color(0xFFFF6B6B); // Coral red
      default:
        return const Color(0xFFBDC3C7); // Light grey
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

  // Get mood intensity description for historical viewing
  static String getMoodIntensityDescriptionForHistory(String moodStatus, int moodLevel) {
    final lowerCaseMood = moodStatus.toLowerCase();
    switch (moodLevel) {
      case 1:
        return "You felt just a little $lowerCaseMood on this day.";
      case 2:
        return "You felt mildly $lowerCaseMood on this day.";
      case 3:
        return "You felt moderately $lowerCaseMood on this day.";
      case 4:
        return "You felt pretty $lowerCaseMood on this day.";
      case 5:
        return "You felt extremely $lowerCaseMood on this day.";
      default:
        return "You felt $lowerCaseMood on this day.";
    }
  }

  // Get stress level description for historical viewing
  static String getStressLevelDescriptionForHistory(int stressLevel) {
    switch (stressLevel) {
      case 1:
        return "Very low stress - You were feeling relaxed and peaceful on this day.";
      case 2:
        return "Low stress - You were feeling calm with minor concerns on this day.";
      case 3:
        return "Moderate stress - You were managing well but feeling some pressure on this day.";
      case 4:
        return "High stress - You were feeling overwhelmed on this day.";
      case 5:
        return "Very high stress - You were feeling extremely stressed on this day.";
      default:
        return "Stress level recorded for this day.";
    }
  }

  // Get sleep hours description for historical viewing
  static String getSleepHoursDescriptionForHistory(double sleepHours) {
    if (sleepHours < 6) {
      return "You got ${sleepHours.toStringAsFixed(1)} hours of sleep on this day - quite short rest.";
    } else if (sleepHours < 7) {
      return "You got ${sleepHours.toStringAsFixed(1)} hours of sleep on this day - a bit below optimal.";
    } else if (sleepHours <= 9) {
      return "You got ${sleepHours.toStringAsFixed(1)} hours of sleep on this day - good rest!";
    } else {
      return "You got ${sleepHours.toStringAsFixed(1)} hours of sleep on this day - quite a lot of rest!";
    }
  }

  // Get mood intensity description
  static String getMoodIntensityDescription(String moodStatus, int moodLevel) {
    final lowerCaseMood = moodStatus.toLowerCase();
    switch (moodLevel) {
      case 1:
        return "I feel just a little $lowerCaseMood today.";
      case 2:
        return "I feel mildly $lowerCaseMood today.";
      case 3:
        return "I feel moderately $lowerCaseMood today.";
      case 4:
        return "I feel pretty $lowerCaseMood today.";
      case 5:
        return "I feel extremely $lowerCaseMood today.";
      default:
        return "I feel $lowerCaseMood today.";
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

  // Get dynamic mood-based notes
  static String getMoodBasedNote(String moodStatus, int moodLevel) {
    final lowerCaseMood = moodStatus.toLowerCase();
    
    switch (lowerCaseMood) {
      case 'happy':
        if (moodLevel >= 4) {
          return "Your positive energy is amazing!\nKeep spreading those good vibes.";
        } else {
          return "It's wonderful that you're feeling good.\nTake time to appreciate these moments.";
        }
      
      case 'sad':
        if (moodLevel >= 4) {
          return "It's okay to feel deeply sad sometimes.\nConsider reaching out to someone you trust.";
        } else {
          return "Remember that these feelings will pass.\nBe gentle with yourself today.";
        }
      
      case 'angry':
        if (moodLevel >= 4) {
          return "Strong anger can be overwhelming.\nTry some deep breathing or physical exercise.";
        } else {
          return "It's normal to feel frustrated sometimes.\nTake a moment to identify what's bothering you.";
        }
      
      case 'anxious':
        if (moodLevel >= 4) {
          return "High anxiety can feel intense.\nGrounding techniques or talking to someone might help.";
        } else {
          return "Mild anxiety is manageable.\nTry some calming activities or mindfulness.";
        }
      
      case 'excited':
        if (moodLevel >= 4) {
          return "It's great to feel enthusiastic.\nEnjoy this uplifting feeling";
        } else {
          return "It's great to feel enthusiastic.\nEnjoy this uplifting feeling.";
        }
      
      case 'calm':
        return "Peace of mind is precious.\nTake advantage of this tranquil state.";
      
      case 'confused':
        if (moodLevel >= 4) {
          return "Feeling very confused can be stressful.\nBreak things down into smaller, manageable pieces.";
        } else {
          return "It's okay to feel uncertain sometimes.\nTrust that clarity will come with time.";
        }
      
      case 'tired':
        if (moodLevel >= 4) {
          return "Deep fatigue needs attention.\nMake sure you're getting enough rest and nutrition.";
        } else {
          return "A little tiredness is normal.\nConsider what your body might need right now.";
        }
      
      case 'grateful':
        return "Gratitude is a beautiful feeling.\nTake a moment to appreciate what you're thankful for.";
      
      case 'stressed':
        if (moodLevel >= 4) {
          return "High stress levels need attention.\nConsider stress-reduction techniques or seeking support.";
        } else {
          return "Some stress is manageable.\nTry to identify what's causing it and how to address it.";
        }
      
      default:
        return "It's perfectly normal to feel this way.\nTake care of yourself today.";
    }
  }

  // Get dynamic stress-based notes
  static String getStressBasedNote(int stressLevel) {
    switch (stressLevel) {
      case 1:
        return "You're in a great peaceful state.\nThis is the perfect time for planning and creativity.";
      case 2:
        return "You're handling things well with minimal stress.\nKeep maintaining your healthy coping strategies.";
      case 3:
        return "Moderate stress is manageable but worth addressing.\nConsider taking short breaks and practicing mindfulness.";
      case 4:
        return "High stress levels need your attention.\nTry relaxation techniques, exercise, or talking to someone.";
      case 5:
        return "Very high stress requires immediate self-care.\nConsider deep breathing, seeking support, or professional help.";
      default:
        return "Monitor your stress levels regularly.\nYour mental health matters.";
    }
  }
}

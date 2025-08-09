import 'package:flutter/material.dart';

class MoodDetector {
  static const Map<String, List<String>> moodKeywords = {
    'happy': ['happy', 'joy', 'excited', 'great', 'amazing', 'wonderful', 'fantastic', 'good', 'pleased', 'delighted', 'cheerful', 'glad', 'awesome', 'brilliant', 'excellent', 'love', 'loved', 'loving'],
    'sad': ['sad', 'depressed', 'down', 'upset', 'crying', 'tears', 'hurt', 'disappointed', 'lonely', 'miserable', 'gloomy', 'devastated', 'heartbroken', 'sorrow', 'grief'],
    'angry': ['angry', 'mad', 'furious', 'rage', 'annoyed', 'irritated', 'frustrated', 'hate', 'pissed', 'outraged', 'livid', 'enraged', 'infuriated'],
    'anxious': ['anxious', 'worried', 'nervous', 'stressed', 'panic', 'fear', 'scared', 'overwhelmed', 'tense', 'uneasy', 'restless', 'troubled'],
    'calm': ['calm', 'peaceful', 'relaxed', 'serene', 'tranquil', 'content', 'balanced', 'zen', 'comfortable', 'composed']
  };

  static const Map<String, Color> moodColors = {
    'happy': Color(0xFFFDD835), // Bright Yellow
    'sad': Color(0xFF1976D2),   // Blue
    'angry': Color(0xFFD32F2F), // Red
    'anxious': Color(0xFFFF9800), // Orange
    'calm': Color(0xFF388E3C),  // Green
    'neutral': Color(0xFFEEDCF9), // Default lavender
  };

  static const Map<String, IconData> moodIcons = {
    'happy': Icons.sentiment_very_satisfied,
    'sad': Icons.sentiment_very_dissatisfied,
    'angry': Icons.sentiment_very_dissatisfied,
    'anxious': Icons.sentiment_dissatisfied,
    'calm': Icons.sentiment_satisfied,
    'neutral': Icons.sentiment_neutral,
  };

  static String detectMood(String text) {
    if (text.trim().isEmpty) return 'neutral';
    
    final words = text.toLowerCase().split(RegExp(r'[^\w]+'));
    String lastFoundMood = 'neutral';
    
    // Scan through all words in the text
    for (String word in words) {
      // Check each mood category for matches
      for (String mood in moodKeywords.keys) {
        if (moodKeywords[mood]!.contains(word)) {
          // Update to the last found mood
          lastFoundMood = mood;
        }
      }
    }

    return lastFoundMood;
  }

  static Color getMoodColor(String mood) {
    return moodColors[mood] ?? moodColors['neutral']!;
  }

  static IconData getMoodIcon(String mood) {
    return moodIcons[mood] ?? moodIcons['neutral']!;
  }

  static String getMoodDisplayName(String mood) {
    switch (mood) {
      case 'happy': return 'Happy 😊';
      case 'sad': return 'Sad 😢';
      case 'angry': return 'Angry 😠';
      case 'anxious': return 'Anxious 😰';
      case 'calm': return 'Calm 😌';
      default: return 'Neutral 😐';
    }
  }
}
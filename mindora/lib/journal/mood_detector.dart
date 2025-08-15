import 'package:flutter/material.dart';
import 'dart:math' as math;

class MoodDetector {
  static const Map<String, List<String>> moodKeywords = {
    'happy': ['happy', 'joy', 'excited', 'great', 'amazing', 'wonderful', 'fantastic', 'good', 'pleased', 'delighted', 'cheerful', 'glad', 'awesome', 'brilliant', 'excellent', 'love', 'loved', 'loving'],
    'sad': ['sad', 'depressed', 'down', 'upset', 'crying', 'tears', 'hurt', 'disappointed', 'lonely', 'miserable', 'gloomy', 'devastated', 'heartbroken', 'sorrow', 'grief'],
    'angry': ['angry', 'mad', 'furious', 'rage', 'annoyed', 'irritated', 'frustrated', 'hate', 'pissed', 'outraged', 'livid', 'enraged', 'infuriated'],
    'stressed': ['stressed', 'anxious', 'worried', 'nervous', 'panic', 'fear', 'scared', 'overwhelmed', 'tense', 'uneasy', 'restless', 'troubled', 'pressure', 'burden', 'panicking'],
    'excited': ['excited', 'thrilled', 'pumped', 'energetic', 'enthusiastic', 'eager', 'hyped', 'exhilarated', 'elated', 'animated', 'vibrant', 'dynamic', 'charged', 'yay'],
    'neutral': ['okay', 'fine', 'alright', 'normal', 'regular', 'usual', 'ordinary', 'standard', 'typical', 'average', 'meh', 'whatever', 'indifferent', 'unchanged', 'steady', 'stable', 'routine', 'mundane', 'bland', 'plain']
  };

  static const Map<String, Color> moodColors = {
    'happy': Color(0xFFFDD835), // Bright Yellow
    'sad': Color(0xFF1976D2),   // Blue
    'angry': Color(0xFFD32F2F), // Red
    'stressed': Color(0xFFFF9800), // Orange
    'excited': Color(0xFFFF6F00), // Bright Orange
    'neutral': Color(0xFFEEDCF9), // Default lavender
  };

  static const Map<String, IconData> moodIcons = {
    'happy': Icons.sentiment_very_satisfied,
    'sad': Icons.sentiment_very_dissatisfied,
    'angry': Icons.sentiment_very_dissatisfied,
    'stressed': Icons.sentiment_dissatisfied,
    'excited': Icons.sentiment_satisfied,
    'neutral': Icons.sentiment_neutral,
  };

  static String detectMood(String text) {
    if (text.trim().isEmpty) return 'neutral';
    
    final lowerText = text.toLowerCase();
    final words = lowerText.split(RegExp(r'[^\w]+'));
    String lastFoundMood = 'neutral';
    
    
    final negationWords = ['not', 'never', 'no', 'don\'t', 'doesn\'t', 'didn\'t', 'won\'t', 'can\'t', 'couldn\'t', 'shouldn\'t', 'wouldn\'t', 'isn\'t', 'aren\'t', 'wasn\'t', 'weren\'t', 'haven\'t', 'hasn\'t', 'hadn\'t'];
    
   
    for (int i = 0; i < words.length; i++) {
      String word = words[i];
      
     
      for (String mood in moodKeywords.keys) {
        if (moodKeywords[mood]!.contains(word)) {
         
          bool isNegated = false;
          for (int j = math.max(0, i - 3); j < i; j++) {
            if (negationWords.contains(words[j])) {
              isNegated = true;
              break;
            }
          }
          
          // If negated, set to neutral, otherwise use the detected mood
          lastFoundMood = isNegated ? 'neutral' : mood;
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
      case 'stressed': return 'Stressed 😰';
      case 'excited': return 'Excited 🤩';
      default: return 'Neutral 😐';
    }
  }
}
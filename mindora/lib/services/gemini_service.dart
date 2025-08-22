import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static const String _apiKey = "AIzaSyCfVufSlPBJAktd2Bs776JGvX2ubUx9W_o";
  static late GenerativeModel _model;

  static void initialize() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  static Future<String> predictMood({
    required double sleepHours,
    required int stressLevel,
  }) async {
    try {
      // Create a detailed prompt for mood prediction
      final prompt = '''
You are an AI assistant that predicts mood based on sleep and stress data. 
Given the following information:

Sleep Hours: ${sleepHours.toStringAsFixed(1)} hours
Stress Level: $stressLevel (on a scale of 1-5, where 1 is very low stress and 5 is extreme stress)

Based on this data, predict the most likely mood from the following options:
- Happy
- Sad  
- Angry
- Excited
- Stressed

Consider these patterns:
- Happy: Good sleep (7-8h) + low stress (1-2)
- Excited: Excellent sleep (8-9h) + very low stress (1) OR slightly less sleep (6-7h) + low stress (1-2) 
- Sad: Poor sleep (<6h OR >10h) + moderate to high stress (3-5)
- Angry: Any sleep + high stress (4-5), especially if sleep is also poor
- Stressed: Poor sleep (<6h) + high stress (4-5) OR good sleep but very high stress (5)

Be diverse in your predictions. Don't always choose the same moods. Consider the full range of possibilities.

Respond with ONLY the mood name (Happy, Sad, Angry, Excited, or Stressed). No explanation or additional text.
''';

      print('🤖 Gemini Request Data:');
      print('Sleep Hours: ${sleepHours.toStringAsFixed(1)}');
      print('Stress Level: $stressLevel');
      print('Prompt: $prompt');
      print('---');

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      final predictedMood = response.text?.trim() ?? 'Happy';
      
      print('🤖 Gemini Response:');
      print('Raw response: ${response.text}');
      print('Cleaned mood: $predictedMood');
      print('---');

      // Validate the response and return a valid mood
      const validMoods = ['Happy', 'Sad', 'Angry', 'Excited', 'Stressed'];
      if (validMoods.contains(predictedMood)) {
        return predictedMood;
      } else {
        // Fallback logic if Gemini returns invalid mood
        print('⚠️ Invalid mood returned by Gemini: $predictedMood');
        return _fallbackMoodPrediction(sleepHours, stressLevel);
      }
    } catch (e) {
      print('❌ Error calling Gemini API: $e');
      // Fallback to rule-based prediction
      return _fallbackMoodPrediction(sleepHours, stressLevel);
    }
  }

  static String _fallbackMoodPrediction(double sleepHours, int stressLevel) {
    print('🔄 Using fallback mood prediction logic');
    
    // More diverse fallback logic
    if (stressLevel == 5) {
      // Extreme stress - could be angry or stressed
      return sleepHours < 6 ? 'Stressed' : 'Angry';
    } else if (stressLevel == 4) {
      // High stress - likely angry or stressed  
      return sleepHours >= 7 ? 'Angry' : 'Stressed';
    } else if (stressLevel == 3) {
      // Moderate stress - depends more on sleep
      if (sleepHours < 6) return 'Sad';
      if (sleepHours > 9) return 'Excited';
      return 'Happy';
    } else if (stressLevel <= 2) {
      // Low stress - mood depends on sleep quality
      if (sleepHours < 5) return 'Sad';
      if (sleepHours >= 8 && sleepHours <= 9) return 'Excited';
      if (sleepHours >= 6 && sleepHours <= 8) return 'Happy';
      if (sleepHours > 10) return 'Sad'; // Too much sleep
      return 'Happy';
    }
    
    return 'Happy'; // Default fallback
  }
}

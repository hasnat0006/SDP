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

Consider the following guidelines:
- If sleep hours are 7-9 and stress level is 1-2: likely Happy or Excited
- If sleep hours are <6 or >10: likely Tired or Stressed
- If stress level is 4-5: likely Stressed or Angry
- If sleep hours are adequate (6-9) but stress is moderate (3): likely neutral to Happy
- If sleep hours are poor (<6) and stress is high (4-5): likely Stressed or Sad

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
    
    if (stressLevel >= 4) {
      return 'Stressed';
    } else if (sleepHours < 6) {
      return stressLevel >= 3 ? 'Stressed' : 'Sad';
    } else if (sleepHours >= 7 && sleepHours <= 9 && stressLevel <= 2) {
      return 'Happy';
    } else if (sleepHours > 9) {
      return 'Excited';
    } else {
      return 'Happy';
    }
  }
}

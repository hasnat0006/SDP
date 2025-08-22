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
    bool hasSleepData = true,
    bool hasStressData = true,
  }) async {
    try {
      // Create a detailed prompt for mood prediction
      String dataInfo = "";
      String predictionContext = "";
      
      if (hasSleepData && hasStressData) {
        dataInfo = "Sleep Hours: ${sleepHours.toStringAsFixed(1)} hours\nStress Level: $stressLevel (on a scale of 1-5)";
        predictionContext = "Based on both sleep and stress data";
      } else if (hasSleepData && !hasStressData) {
        dataInfo = "Sleep Hours: ${sleepHours.toStringAsFixed(1)} hours\nStress Level: No data available";
        predictionContext = "Based on sleep data only";
      } else if (!hasSleepData && hasStressData) {
        dataInfo = "Sleep Hours: No data available\nStress Level: $stressLevel (on a scale of 1-5)";
        predictionContext = "Based on stress data only";
      }
      
      final prompt = '''
You are an AI assistant that predicts mood based on available sleep and stress data. 
Given the following information:

$dataInfo

$predictionContext, predict the most likely mood from the following options:
- Happy
- Sad  
- Angry
- Excited
- Stressed

Consider these patterns:
${hasSleepData && hasStressData ? '''
- Happy: Good sleep (7-8h) + low stress (1-2)
- Excited: Excellent sleep (8-9h) + very low stress (1) OR slightly less sleep (6-7h) + low stress (1-2) 
- Sad: Poor sleep (<6h OR >10h) + moderate to high stress (3-5)
- Angry: Any sleep + high stress (4-5), especially if sleep is also poor
- Stressed: Poor sleep (<6h) + high stress (4-5) OR good sleep but very high stress (5)
''' : hasSleepData ? '''
- Happy: Good sleep (7-9h)
- Excited: Excellent sleep (8-9h)
- Sad: Poor sleep (<6h OR >10h)
- Stressed: Very poor sleep (<5h)
- Angry: Moderately poor sleep (5-6h)
''' : '''
- Happy: Low stress (1-2)
- Excited: Very low stress (1)
- Stressed: High stress (4-5)
- Angry: High stress (4-5)
- Sad: Moderate to high stress (3-5)
'''}

Be diverse in your predictions. Don't always choose the same moods. Consider the full range of possibilities.

Respond with ONLY the mood name (Happy, Sad, Angry, Excited, or Stressed). No explanation or additional text.
''';

      print('🤖 Gemini Request Data:');
      print('Sleep Hours: ${hasSleepData ? sleepHours.toStringAsFixed(1) : "No data"}');
      print('Stress Level: ${hasStressData ? stressLevel.toString() : "No data"}');
      print('Has Sleep Data: $hasSleepData');
      print('Has Stress Data: $hasStressData');
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
        return _fallbackMoodPrediction(sleepHours, stressLevel, hasSleepData, hasStressData);
      }
    } catch (e) {
      print('❌ Error calling Gemini API: $e');
      // Fallback to rule-based prediction
      return _fallbackMoodPrediction(sleepHours, stressLevel, hasSleepData, hasStressData);
    }
  }

  static String _fallbackMoodPrediction(double sleepHours, int stressLevel, bool hasSleepData, bool hasStressData) {
    print('🔄 Using fallback mood prediction logic');
    
    // Handle partial data cases
    if (hasSleepData && !hasStressData) {
      // Only sleep data available
      if (sleepHours < 5) return 'Sad';
      if (sleepHours >= 8 && sleepHours <= 9) return 'Excited';
      if (sleepHours >= 6 && sleepHours <= 8) return 'Happy';
      if (sleepHours > 10) return 'Sad';
      return 'Happy';
    } else if (!hasSleepData && hasStressData) {
      // Only stress data available
      if (stressLevel == 5) return 'Stressed';
      if (stressLevel == 4) return 'Angry';
      if (stressLevel == 3) return 'Sad';
      if (stressLevel <= 2) return 'Happy';
      if (stressLevel == 1) return 'Excited';
      return 'Happy';
    }
    
    // Both data available - original logic
    if (stressLevel == 5) {
      return sleepHours < 6 ? 'Stressed' : 'Angry';
    } else if (stressLevel == 4) {
      return sleepHours >= 7 ? 'Angry' : 'Stressed';
    } else if (stressLevel == 3) {
      if (sleepHours < 6) return 'Sad';
      if (sleepHours > 9) return 'Excited';
      return 'Happy';
    } else if (stressLevel <= 2) {
      if (sleepHours < 5) return 'Sad';
      if (sleepHours >= 8 && sleepHours <= 9) return 'Excited';
      if (sleepHours >= 6 && sleepHours <= 8) return 'Happy';
      if (sleepHours > 10) return 'Sad';
      return 'Happy';
    }
    
    return 'Happy'; // Default fallback
  }
}

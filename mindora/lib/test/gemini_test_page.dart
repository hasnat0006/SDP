import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

class GeminiTestPage extends StatefulWidget {
  @override
  _GeminiTestPageState createState() => _GeminiTestPageState();
}

class _GeminiTestPageState extends State<GeminiTestPage> {
  String result = '';
  bool isLoading = false;

  Future<void> testGemini() async {
    setState(() {
      isLoading = true;
      result = '';
    });

    try {
      GeminiService.initialize();
      final mood = await GeminiService.predictMood(
        sleepHours: 6.5,
        stressLevel: 3,
      );
      setState(() {
        result = 'Predicted mood: $mood';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        result = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gemini Test'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: isLoading ? null : testGemini,
              child: Text('Test Gemini Prediction'),
            ),
            SizedBox(height: 20),
            if (isLoading) CircularProgressIndicator(),
            if (result.isNotEmpty) 
              Text(
                result,
                style: TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}

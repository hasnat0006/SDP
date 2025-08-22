import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../mood/backend.dart';
import '../services/user_service.dart';
import '../services/gemini_service.dart';

class DebugApiTestPage extends StatefulWidget {
  @override
  _DebugApiTestPageState createState() => _DebugApiTestPageState();
}

class _DebugApiTestPageState extends State<DebugApiTestPage> {
  String debugText = '';
  bool isLoading = false;

  void addDebugLine(String line) {
    setState(() {
      debugText += '$line\n';
    });
    print(line);
  }

  Future<void> testApiCalls() async {
    setState(() {
      isLoading = true;
      debugText = '';
    });

    try {
      addDebugLine('=== Starting API Debug Test ===');

      // Test user data
      addDebugLine('🔍 Testing user data...');
      final userData = await UserService.getUserData();
      final userId = userData['userId'] ?? '';
      final userType = userData['userType'] ?? '';
      addDebugLine('User ID: $userId');
      addDebugLine('User Type: $userType');

      if (userId.isEmpty) {
        addDebugLine('❌ Error: User not logged in');
        setState(() => isLoading = false);
        return;
      }

      // Test date formatting
      final today = DateTime.now();
      final dateString = today.toIso8601String().split('T')[0];
      addDebugLine('Today\'s date: $dateString');

      // Test sleep API
      addDebugLine('\n🛏️ Testing sleep API...');
      final sleepResult = await MoodTrackerBackend.getSleepDataForDate(userId, today);
      addDebugLine('Sleep API result: $sleepResult');
      
      if (sleepResult['success'] == true && sleepResult['data'] != null) {
        final sleepHours = sleepResult['data']['sleep_hours'];
        addDebugLine('Sleep hours found: $sleepHours');
      } else {
        addDebugLine('No sleep data found or API failed');
      }

      // Test stress API
      addDebugLine('\n😰 Testing stress API...');
      final stressResult = await MoodTrackerBackend.getStressDataForDate(userId, today);
      addDebugLine('Stress API result: $stressResult');
      
      if (stressResult['success'] == true && stressResult['data'] != null) {
        final stressLevel = stressResult['data']['stress_level'];
        addDebugLine('Stress level found: $stressLevel');
      } else {
        addDebugLine('No stress data found or API failed');
      }

      // Test Gemini API
      addDebugLine('\n🤖 Testing Gemini API...');
      GeminiService.initialize();
      final predictedMood = await GeminiService.predictMood(
        sleepHours: 7.0,
        stressLevel: 3,
      );
      addDebugLine('Gemini predicted mood: $predictedMood');

      addDebugLine('\n✅ All tests completed!');

    } catch (e) {
      addDebugLine('❌ Error during testing: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API Debug Test'),
        backgroundColor: const Color(0xFFD39AD5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: isLoading ? null : testApiCalls,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD39AD5),
              ),
              child: isLoading 
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                      SizedBox(width: 8),
                      Text('Testing...', style: TextStyle(color: Colors.white)),
                    ],
                  )
                : Text('Run API Tests', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    debugText.isEmpty ? 'Click "Run API Tests" to start debugging...' : debugText,
                    style: GoogleFonts.sourceCodePro(fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

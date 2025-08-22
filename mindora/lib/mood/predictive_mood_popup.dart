import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/gemini_service.dart';
import '../mood/backend.dart';
import '../services/user_service.dart';
import 'Mood_intensity.dart';

class PredictiveMoodPopup extends StatefulWidget {
  final VoidCallback onManualSelection;
  
  const PredictiveMoodPopup({
    super.key,
    required this.onManualSelection,
  });

  @override
  State<PredictiveMoodPopup> createState() => _PredictiveMoodPopupState();
}

class _PredictiveMoodPopupState extends State<PredictiveMoodPopup> 
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  String errorMessage = '';
  double sleepHours = 0.0;
  int stressLevel = 1;
  String predictedMood = '';
  String userId = '';
  bool isManualButtonHovering = false;
  bool isLogButtonHovering = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _animationController.forward();
    _loadDataAndPredict();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDataAndPredict() async {
    try {
      // Get user ID
      final userData = await UserService.getUserData();
      userId = userData['userId'] ?? '';
      
      if (userId.isEmpty) {
        setState(() {
          errorMessage = 'User not logged in';
          isLoading = false;
        });
        return;
      }

      // Get today's date in the correct format
      final today = DateTime.now();
      final dateString = today.toIso8601String().split('T')[0]; // YYYY-MM-DD format
      
      print('🔍 Loading data for user: $userId on date: $dateString');
      
      // Fetch sleep and stress data in parallel
      final results = await Future.wait([
        MoodTrackerBackend.getSleepDataForDate(userId, today),
        MoodTrackerBackend.getStressDataForDate(userId, today),
      ]);

      final sleepResult = results[0];
      final stressResult = results[1];

      print('🔍 Sleep data result: $sleepResult');
      print('🔍 Sleep data type: ${sleepResult.runtimeType}');
      print('🔍 Stress data result: $stressResult');  
      print('🔍 Stress data type: ${stressResult.runtimeType}');

      try {
        // Extract sleep hours with null safety
        if (sleepResult['success'] == true && 
            sleepResult['data'] != null) {
          final sleepData = sleepResult['data']['sleep_hours'];
          print('🔍 Raw sleep_hours value: $sleepData (${sleepData.runtimeType})');
          if (sleepData != null) {
            sleepHours = double.tryParse(sleepData.toString()) ?? 7.0;
          } else {
            sleepHours = 7.0;
          }
          print('ℹ️ Found sleep data: $sleepHours hours');
        } else {
          // Default to 7 hours if no data
          sleepHours = 7.0;
          print('ℹ️ No sleep data found for today, using default: $sleepHours hours');
        }

        // Extract stress level with null safety
        if (stressResult['success'] == true && 
            stressResult['data'] != null) {
          final stressData = stressResult['data']['stress_level'];
          print('🔍 Raw stress_level value: $stressData (${stressData.runtimeType})');
          if (stressData != null) {
            stressLevel = int.tryParse(stressData.toString()) ?? 2;
          } else {
            stressLevel = 2;
          }
          print('ℹ️ Found stress data: level $stressLevel');
        } else {
          // Default to level 2 if no data
          stressLevel = 2;
          print('ℹ️ No stress data found for today, using default: level $stressLevel');
        }
      } catch (dataProcessingError) {
        print('❌ Error processing sleep/stress data: $dataProcessingError');
        // Use defaults if data processing fails
        sleepHours = 7.0;
        stressLevel = 2;
      }

      // Initialize Gemini and predict mood
      GeminiService.initialize();
      predictedMood = await GeminiService.predictMood(
        sleepHours: sleepHours,
        stressLevel: stressLevel,
      );

      setState(() {
        isLoading = false;
      });

    } catch (e) {
      print('❌ Error in _loadDataAndPredict: $e');
      setState(() {
        errorMessage = 'Failed to load data: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  String _getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'sad':
        return '😢';
      case 'angry':
        return '😠';
      case 'excited':
        return '😃';
      case 'stressed':
        return '😟';
      default:
        return '😊';
    }
  }

  String _getStressLevelText(int level) {
    switch (level) {
      case 1:
        return 'Very Low';
      case 2:
        return 'Low';
      case 3:
        return 'Moderate';
      case 4:
        return 'High';
      case 5:
        return 'Extreme';
      default:
        return 'Unknown';
    }
  }

  Future<void> _logPredictedMood() async {
    try {
      Navigator.of(context).pop(); // Close the popup first
      
      // Navigate directly to MoodIntensityPage with predicted mood
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MoodIntensityPage(
            moodLabel: predictedMood,
            moodEmoji: _getMoodEmoji(predictedMood),
          ),
        ),
      );
    } catch (e) {
      print('❌ Error logging predicted mood: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging mood: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AlertDialog(
        backgroundColor: const Color(0xFFFFF9F4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '🤖 ',
            style: TextStyle(fontSize: 24),
          ),
          Text(
            'AI Mood Prediction',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6D3670),
            ),
          ),
          Text(
            ' 🧠',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
      content: SizedBox(
        width: 320,
        child: isLoading 
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD39AD5)),
                ),
                const SizedBox(height: 16),
                Text(
                  'Analyzing your data...',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            )
          : errorMessage.isNotEmpty
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red[300],
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.red[600],
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Data summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFD1F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Sleep:',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${sleepHours.toStringAsFixed(1)} hours',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF6D3670),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Stress:',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Level $stressLevel (${_getStressLevelText(stressLevel)})',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF6D3670),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Prediction result
                  Text(
                    'You seem',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getMoodEmoji(predictedMood),
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        predictedMood,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6D3670),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'today!',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Info section at bottom
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue[200]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[600],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Prediction is based on your logged data in Sleep and Stress trackers',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.blue[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      actions: isLoading || errorMessage.isNotEmpty
        ? [
            if (errorMessage.isNotEmpty)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onManualSelection();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6D3670),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Manual Selection',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ]
        : [
            // Custom button layout - side by side
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // No, I'll log manually button
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: MouseRegion(
                        onEnter: (_) => setState(() => isManualButtonHovering = true),
                        onExit: (_) => setState(() => isManualButtonHovering = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              widget.onManualSelection();
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isManualButtonHovering 
                                    ? const Color(0xFF6D3670) 
                                    : Colors.grey[400]!, 
                                width: isManualButtonHovering ? 2 : 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: isManualButtonHovering 
                                  ? const Color(0xFF6D3670).withOpacity(0.1)
                                  : Colors.transparent,
                            ),
                            child: Text(
                              "Manual",
                              style: GoogleFonts.poppins(
                                color: isManualButtonHovering 
                                    ? const Color(0xFF6D3670) 
                                    : Colors.grey[600],
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Yes, log this button
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: MouseRegion(
                        onEnter: (_) => setState(() => isLogButtonHovering = true),
                        onExit: (_) => setState(() => isLogButtonHovering = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: ElevatedButton(
                            onPressed: _logPredictedMood,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isLogButtonHovering 
                                  ? const Color(0xFFCB8DD0)
                                  : const Color(0xFFD39AD5),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: isLogButtonHovering ? 8 : 4,
                              shadowColor: const Color(0xFFD39AD5).withOpacity(0.4),
                            ),
                            child: Text(
                              'Yes, log this',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
      ),
    );
  }
}

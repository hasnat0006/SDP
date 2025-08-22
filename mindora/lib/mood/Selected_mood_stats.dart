import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'backend.dart';
import '../services/user_service.dart';

class MoodStatsPage extends StatefulWidget {
  final DateTime selectedDate;

  const MoodStatsPage({super.key, required this.selectedDate});

  @override
  State<MoodStatsPage> createState() => _MoodStatsPageState();
}

class _MoodStatsPageState extends State<MoodStatsPage> {
  Map<String, dynamic>? moodData;
  Map<String, dynamic>? stressData;
  Map<String, dynamic>? sleepData;
  Map<String, dynamic>? monthlyData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Helper method to safely parse double values
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      String? userId = await UserService.getUserId();
      
      // Use fallback user ID for testing if no user is logged in
      userId ??= 'test_user_123';

      print('🔍 Loading data for user: $userId, date: ${widget.selectedDate}');

      // Get mood data for selected date
      try {
        final moodResult = await MoodTrackerBackend.getMoodDataForDate(userId, widget.selectedDate);
        print('📊 Mood result: $moodResult');
        if (moodResult['success'] && moodResult['data'] != null) {
          moodData = moodResult['data'];
          print('✅ Mood data loaded: $moodData');
        } else {
          print('❌ Failed to load mood data: ${moodResult['message']}');
        }
      } catch (e) {
        print('🚨 Error loading mood data: $e');
      }

      // Get stress data for selected date
      try {
        final stressResult = await MoodTrackerBackend.getStressDataForDate(userId, widget.selectedDate);
        if (stressResult['success'] && stressResult['data'] != null) {
          stressData = stressResult['data'];
          print('✅ Stress data loaded: $stressData');
        } else {
          print('❌ Failed to load stress data: ${stressResult['message']}');
        }
      } catch (e) {
        print('🚨 Error loading stress data: $e');
      }

      // Get sleep data for selected date
      try {
        final sleepResult = await MoodTrackerBackend.getSleepDataForDate(userId, widget.selectedDate);
        if (sleepResult['success'] && sleepResult['data'] != null) {
          sleepData = sleepResult['data'];
          print('✅ Sleep data loaded: $sleepData');
        } else {
          print('❌ Failed to load sleep data: ${sleepResult['message']}');
        }
      } catch (e) {
        print('🚨 Error loading sleep data: $e');
      }

      // Get monthly data for weekly overview
      try {
        final monthlyResult = await MoodTrackerBackend.getMonthlyMoodData(userId, widget.selectedDate);
        print('📅 Monthly result: $monthlyResult');
        if (monthlyResult['success'] && monthlyResult['data'] != null) {
          monthlyData = monthlyResult['data'];
          print('✅ Monthly data loaded: $monthlyData');
        } else {
          print('❌ Failed to load monthly data: ${monthlyResult['message']}');
        }
      } catch (e) {
        print('🚨 Error loading monthly data: $e');
      }

    } catch (e) {
      print('🚨 General error loading data: $e');
      print('📍 Stack trace: ${StackTrace.current}');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  List<Map<String, String>> _generateWeeklyOverview() {
    if (monthlyData == null) {
      return [
        {"week": "Week 1", "range": "No data", "summary": "No input found"},
        {"week": "Week 2", "range": "No data", "summary": "No input found"},
        {"week": "Week 3", "range": "No data", "summary": "No input found"},
        {"week": "Week 4", "range": "No data", "summary": "No input found"},
      ];
    }

    // Process monthly data to create weekly overview
    List<Map<String, String>> weeklyOverview = [];
    for (int week = 1; week <= 4; week++) {
      final weekKey = "Week $week";
      if (monthlyData!.containsKey(weekKey) && monthlyData![weekKey] != null) {
        try {
          final weekData = monthlyData![weekKey];
          if (weekData is List && weekData.isNotEmpty) {
            // Extract all mood data with levels
            final moodEntries = weekData
                .where((entry) => entry is Map && entry['mood_status'] != null)
                .map((entry) => {
                  'status': entry['mood_status'].toString(),
                  'level': entry['mood_level'] ?? 3,
                })
                .toList();
            
            // Calculate proper week boundaries
            final firstDayOfMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month, 1);
            final startOfFirstWeek = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday - 1));
            final weekStart = startOfFirstWeek.add(Duration(days: (week - 1) * 7));
            final weekEnd = weekStart.add(Duration(days: 6));
            
            // Format date range properly
            final range = "${DateFormat.MMMd().format(weekStart)} - ${DateFormat.MMMd().format(weekEnd)}";
            
            // Generate comprehensive summary
            String summary = _getAdvancedMoodSummary(moodEntries);
            
            weeklyOverview.add({
              "week": weekKey,
              "range": range,
              "summary": summary,
            });
          } else {
            // Calculate empty week range
            final firstDayOfMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month, 1);
            final startOfFirstWeek = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday - 1));
            final weekStart = startOfFirstWeek.add(Duration(days: (week - 1) * 7));
            final weekEnd = weekStart.add(Duration(days: 6));
            final range = "${DateFormat.MMMd().format(weekStart)} - ${DateFormat.MMMd().format(weekEnd)}";
            
            weeklyOverview.add({
              "week": weekKey,
              "range": range,
              "summary": "No mood data tracked",
            });
          }
        } catch (e) {
          print('Error processing week $week: $e');
          weeklyOverview.add({
            "week": weekKey,
            "range": "Error calculating range",
            "summary": "Unable to analyze",
          });
        }
      } else {
        // Calculate week range even when no data
        final firstDayOfMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month, 1);
        final startOfFirstWeek = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday - 1));
        final weekStart = startOfFirstWeek.add(Duration(days: (week - 1) * 7));
        final weekEnd = weekStart.add(Duration(days: 6));
        final range = "${DateFormat.MMMd().format(weekStart)} - ${DateFormat.MMMd().format(weekEnd)}";
        
        weeklyOverview.add({
          "week": weekKey,
          "range": range,
          "summary": "No mood data tracked",
        });
      }
    }
    
    return weeklyOverview;
  }

  String _getAdvancedMoodSummary(List<Map<String, dynamic>> moodEntries) {
    try {
      if (moodEntries.isEmpty) return "No mood data tracked";
      
      // Calculate basic statistics
      Map<String, int> moodCounts = {};
      Map<String, List<int>> moodLevels = {};
      int totalEntries = moodEntries.length;
      double totalMoodScore = 0;
      
      // Analyze each mood entry with detailed tracking
      for (var entry in moodEntries) {
        String mood = entry['status'].toString().toLowerCase();
        int level = entry['level'] ?? 3;
        
        moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
        moodLevels[mood] = (moodLevels[mood] ?? [])..add(level);
        totalMoodScore += level;
      }
      
      if (moodCounts.isEmpty) return "No valid mood data";
      
      // Calculate average mood intensity
      double averageIntensity = totalMoodScore / totalEntries;
      
      // Find dominant mood and secondary mood
      List<MapEntry<String, int>> sortedMoods = moodCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      String dominantMood = sortedMoods.first.key;
      int dominantCount = sortedMoods.first.value;
      String? secondaryMood = sortedMoods.length > 1 ? sortedMoods[1].key : null;
      int secondaryCount = sortedMoods.length > 1 ? sortedMoods[1].value : 0;
      
      // Count unique moods
      int uniqueMoods = moodCounts.keys.length;
      
      // Enhanced mood categorization
      Map<String, List<String>> moodCategories = {
        'very_positive': ['excited', 'grateful', 'euphoric', 'elated'],
        'positive': ['happy', 'calm', 'content', 'peaceful', 'relaxed'],
        'neutral': ['neutral', 'okay', 'fine', 'normal'],
        'negative': ['sad', 'tired', 'bored', 'disappointed', 'lonely'],
        'very_negative': ['angry', 'anxious', 'stressed', 'depressed', 'furious'],
        'complex': ['confused', 'overwhelmed', 'conflicted', 'uncertain']
      };
      
      // Categorize each mood entry
      Map<String, int> categoryCounts = {
        'very_positive': 0, 'positive': 0, 'neutral': 0, 
        'negative': 0, 'very_negative': 0, 'complex': 0
      };
      
      for (var entry in moodCounts.entries) {
        String mood = entry.key.toLowerCase();
        int count = entry.value;
        
        for (var category in moodCategories.entries) {
          if (category.value.contains(mood)) {
            categoryCounts[category.key] = (categoryCounts[category.key] ?? 0) + count;
            break;
          }
        }
      }
      
      // Calculate mood trends and patterns
      int positiveTotal = (categoryCounts['very_positive'] ?? 0) + (categoryCounts['positive'] ?? 0);
      int negativeTotal = (categoryCounts['negative'] ?? 0) + (categoryCounts['very_negative'] ?? 0);
      int neutralTotal = categoryCounts['neutral'] ?? 0;
      int complexTotal = categoryCounts['complex'] ?? 0;
      
      // Get intensity of dominant mood
      double dominantIntensity = moodLevels[dominantMood]?.isNotEmpty == true 
          ? moodLevels[dominantMood]!.reduce((a, b) => a + b) / moodLevels[dominantMood]!.length
          : 3.0;
      
      // Generate varied and specific summaries based on detailed analysis
      
      // Single mood entry
      if (totalEntries == 1) {
        return _getSingleMoodSummary(dominantMood, dominantIntensity);
      }
      
      // Two mood entries
      if (totalEntries == 2) {
        if (uniqueMoods == 1) {
          return _getConsistentMoodSummary(dominantMood, dominantIntensity);
        } else {
          return _getTwoMoodSummary(dominantMood, secondaryMood!, positiveTotal, negativeTotal);
        }
      }
      
      // Single dominant mood (>80% of entries)
      if (dominantCount >= (totalEntries * 0.8)) {
        return _getDominantMoodSummary(dominantMood, dominantIntensity, totalEntries);
      }
      
      // High emotional variability (4+ different moods)
      if (uniqueMoods >= 4) {
        return _getVariableMoodSummary(categoryCounts, totalEntries, dominantMood);
      }
      
      // Bi-modal pattern (two main moods)
      if (uniqueMoods == 2 && dominantCount > 0 && secondaryCount > 0) {
        return _getBimodalMoodSummary(dominantMood, secondaryMood!, dominantCount, secondaryCount, dominantIntensity);
      }
      
      // 3 different moods - analyze the pattern
      if (uniqueMoods == 3) {
        return _getTrimodalMoodSummary(sortedMoods, categoryCounts, averageIntensity);
      }
      
      // Fallback with more specific analysis
      return _getGeneralMoodSummary(categoryCounts, dominantMood, averageIntensity, totalEntries);
      
    } catch (e) {
      print('Error in _getAdvancedMoodSummary: $e');
      return "Unable to analyze mood data";
    }
  }
  
  String _getSingleMoodSummary(String mood, double intensity) {
    String intensityWord = _getDetailedIntensity(intensity);
    List<String> variations = [
      "$intensityWord $mood day",
      "Feeling $intensityWord $mood",
      "$intensityWord $mood throughout",
      "A $intensityWord $mood experience"
    ];
    return variations[(mood.hashCode % variations.length).abs()];
  }
  
  String _getConsistentMoodSummary(String mood, double intensity) {
    String intensityWord = _getDetailedIntensity(intensity);
    List<String> variations = [
      "Consistently $intensityWord $mood",
      "Stable $intensityWord $mood pattern",
      "Maintaining $intensityWord $mood state",
      "Steadily $intensityWord $mood"
    ];
    return variations[(mood.hashCode % variations.length).abs()];
  }
  
  String _getTwoMoodSummary(String mood1, String mood2, int positive, int negative) {
    if (positive > negative) {
      List<String> variations = [
        "Shifting between $mood1 and $mood2, mostly uplifting",
        "Alternating $mood1-$mood2 with positive lean",
        "Dynamic $mood1 to $mood2 emotional flow"
      ];
      return variations[((mood1 + mood2).hashCode % variations.length).abs()];
    } else if (negative > positive) {
      List<String> variations = [
        "Fluctuating $mood1-$mood2 with challenging moments",
        "Transitioning between $mood1 and $mood2 states",
        "Processing through $mood1 and $mood2 emotions"
      ];
      return variations[((mood1 + mood2).hashCode % variations.length).abs()];
    } else {
      List<String> variations = [
        "Balanced $mood1 and $mood2 experiences",
        "Even split between $mood1 and $mood2",
        "Contrasting $mood1-$mood2 emotional journey"
      ];
      return variations[((mood1 + mood2).hashCode % variations.length).abs()];
    }
  }
  
  String _getDominantMoodSummary(String mood, double intensity, int entries) {
    String intensityWord = _getDetailedIntensity(intensity);
    List<String> variations = [
      "Predominantly $intensityWord $mood week",
      "Strong $intensityWord $mood pattern ($entries days)",
      "Mainly experiencing $intensityWord $mood",
      "Sustained $intensityWord $mood throughout"
    ];
    return variations[(mood.hashCode % variations.length).abs()];
  }
  
  String _getVariableMoodSummary(Map<String, int> categories, int total, String dominant) {
    int positiveTotal = (categories['very_positive'] ?? 0) + (categories['positive'] ?? 0);
    int negativeTotal = (categories['negative'] ?? 0) + (categories['very_negative'] ?? 0);
    
    if (positiveTotal > negativeTotal * 1.5) {
      List<String> variations = [
        "Rich emotional week with positive highlights",
        "Diverse moods trending upward",
        "Varied emotions with uplifting moments",
        "Complex week leaning toward wellness"
      ];
      return variations[(total % variations.length).abs()];
    } else if (negativeTotal > positiveTotal * 1.5) {
      List<String> variations = [
        "Emotionally challenging week with varied experiences",
        "Complex emotional processing period",
        "Diverse feelings during difficult time",
        "Working through multiple emotional states"
      ];
      return variations[(total % variations.length).abs()];
    } else {
      List<String> variations = [
        "Emotionally rich and varied week",
        "Complex emotional landscape with $dominant peaks",
        "Diverse mood patterns throughout",
        "Full spectrum emotional experience"
      ];
      return variations[(total % variations.length).abs()];
    }
  }
  
  String _getBimodalMoodSummary(String mood1, String mood2, int count1, int count2, double intensity) {
    String primary = count1 > count2 ? mood1 : mood2;
    String secondary = count1 > count2 ? mood2 : mood1;
    String intensityWord = _getDetailedIntensity(intensity);
    
    List<String> variations = [
      "Primary $intensityWord $primary with $secondary moments",
      "Alternating between $intensityWord $primary and $secondary",
      "Dual pattern: $primary-$secondary emotional rhythm",
      "$intensityWord $primary dominant, occasional $secondary"
    ];
    return variations[((mood1 + mood2).hashCode % variations.length).abs()];
  }
  
  String _getTrimodalMoodSummary(List<MapEntry<String, int>> moods, Map<String, int> categories, double avgIntensity) {
    String top1 = moods[0].key;
    String top2 = moods[1].key;
    String top3 = moods[2].key;
    
    int positiveTotal = (categories['very_positive'] ?? 0) + (categories['positive'] ?? 0);
    int negativeTotal = (categories['negative'] ?? 0) + (categories['very_negative'] ?? 0);
    
    if (positiveTotal > negativeTotal) {
      List<String> variations = [
        "Triple pattern: $top1, $top2, $top3 with positive flow",
        "Triangular mood cycle leaning positive",
        "Three-way emotional balance trending up"
      ];
      return variations[((top1 + top2 + top3).hashCode % variations.length).abs()];
    } else {
      List<String> variations = [
        "Complex $top1-$top2-$top3 emotional cycle",
        "Three-dimensional mood experience",
        "Multifaceted $top1, $top2, and $top3 journey"
      ];
      return variations[((top1 + top2 + top3).hashCode % variations.length).abs()];
    }
  }
  
  String _getGeneralMoodSummary(Map<String, int> categories, String dominant, double avgIntensity, int total) {
    int positiveTotal = (categories['very_positive'] ?? 0) + (categories['positive'] ?? 0);
    int negativeTotal = (categories['negative'] ?? 0) + (categories['very_negative'] ?? 0);
    
    String intensityWord = _getDetailedIntensity(avgIntensity);
    
    if (positiveTotal >= negativeTotal * 2) {
      List<String> variations = [
        "Generally positive with $intensityWord $dominant highlights",
        "Upward trending week with $dominant focus",
        "Positive emotional trajectory"
      ];
      return variations[(dominant.hashCode % variations.length).abs()];
    } else if (negativeTotal >= positiveTotal * 2) {
      List<String> variations = [
        "Challenging period with $intensityWord $dominant experiences",
        "Processing difficult emotions, $dominant prominent",
        "Working through tough times with $dominant feelings"
      ];
      return variations[(dominant.hashCode % variations.length).abs()];
    } else {
      List<String> variations = [
        "Balanced emotional week with $intensityWord $dominant",
        "Moderate emotional range, $dominant centered",
        "Steady emotional pace with $dominant undertones",
        "Well-rounded emotional experience"
      ];
      return variations[(total % variations.length).abs()];
    }
  }
  
  String _getDetailedIntensity(double avgLevel) {
    if (avgLevel >= 4.5) return "intensely";
    if (avgLevel >= 4.0) return "strongly";
    if (avgLevel >= 3.5) return "notably";
    if (avgLevel >= 3.0) return "moderately";
    if (avgLevel >= 2.5) return "somewhat";
    return "mildly";
  }

  // Helper method to safely get reason list from mood data
  List<String> _getReasonList(Map<String, dynamic>? data) {
    if (data == null || !data.containsKey('reason')) return [];
    
    final reasonData = data['reason'];
    if (reasonData == null) return [];
    
    if (reasonData is List) {
      return reasonData.map((item) => item.toString()).toList();
    } else {
      return [reasonData.toString()];
    }
  }

  IconData _getMoodIcon(String moodStatus) {
    switch (moodStatus.toLowerCase()) {
      case 'happy':
        return Icons.sentiment_very_satisfied; // Big smile
      case 'sad':
        return Icons.sentiment_very_dissatisfied; // Crying face
      case 'angry':
        return Icons.local_fire_department; // Fire icon
      case 'anxious':
        return Icons.psychology; // Brain/worry icon
      case 'excited':
        return Icons.celebration; // Party/celebration icon
      case 'calm':
        return Icons.self_improvement; // Meditation icon
      case 'confused':
        return Icons.help_outline; // Question mark
      case 'tired':
        return Icons.bedtime; // Sleep icon
      case 'grateful':
        return Icons.volunteer_activism; // Heart hands icon
      case 'stressed':
        return Icons.warning; // Warning icon for stress
      default:
        return Icons.sentiment_neutral; // Neutral face
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat.yMMMMd().format(widget.selectedDate);
    final String selectedMonth = DateFormat.yMMMM().format(widget.selectedDate);
    final List<Map<String, String>> weeklyOverview = _generateWeeklyOverview();

    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF9F4),
        appBar: AppBar(
          backgroundColor: const Color(0xFFD39AD5),
          elevation: 0,
          toolbarHeight: 80,
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color.fromARGB(255, 10, 10, 10)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Mood Stats",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: const Color.fromARGB(255, 10, 10, 10),
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFFB79AE0),
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading your mood data...',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait while we fetch your stats',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD39AD5),
        elevation: 0,
        toolbarHeight: 80,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color.fromARGB(255, 10, 10, 10)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Mood Stats",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: const Color.fromARGB(255, 10, 10, 10),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "See your mood trend for selected date",
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    formattedDate,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.brown,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Info Cards
              Column(
                children: [
                  _InfoCard(
                    title: "Mood",
                    value: moodData != null 
                        ? "${moodData!['mood_status']} (${moodData!['mood_level']}/5)"
                        : "No input found",
                    description: moodData != null 
                        ? MoodTrackerBackend.getMoodIntensityDescriptionForHistory(
                            moodData!['mood_status'], 
                            moodData!['mood_level']
                          )
                        : null,
                    icon: moodData != null 
                        ? _getMoodIcon(moodData!['mood_status'])
                        : Icons.help_outline,
                    color: moodData != null 
                        ? MoodTrackerBackend.getMoodColor(moodData!['mood_status'])
                        : Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    title: "Stress Level",
                    value: stressData != null 
                        ? "${stressData!['stress_level']}/5"
                        : "No input found",
                    description: stressData != null 
                        ? MoodTrackerBackend.getStressLevelDescriptionForHistory(stressData!['stress_level'])
                        : null,
                    icon: Icons.bar_chart,
                    color: stressData != null ? Colors.redAccent : Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    title: "Sleep",
                    value: sleepData != null 
                        ? "${sleepData!['sleep_hours'] ?? 'N/A'} hours"
                        : "No input found",
                    description: sleepData != null 
                        ? MoodTrackerBackend.getSleepHoursDescriptionForHistory(_parseDouble(sleepData!['sleep_hours']))
                        : null,
                    icon: Icons.nightlight_round,
                    color: sleepData != null ? Colors.deepPurple : Colors.grey,
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/sunrise.png',
                      height: 190,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Text(
                moodData != null || stressData != null || sleepData != null
                    ? "Remember to take deep breaths and stay calm"
                    : "No data found for this date. Consider tracking your mood daily!",
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
              ),

              const SizedBox(height: 30),
              Text(
                "Weekly Overview for $selectedMonth",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 12),

              Column(
                children: weeklyOverview.map((weekData) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2E3F4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weekData["week"]!,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          weekData["range"]!,
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          weekData["summary"]!,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurple,
                          ),
                        )
                      ],
                    ),
                  );
                }).toList(),
              ),

              // Display mood reasons if available
              if (moodData != null && _getReasonList(moodData).isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  "Mood Reasons",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _getReasonList(moodData).map((reason) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.purple.shade200),
                      ),
                      child: Text(
                        reason,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.purple.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String? description;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.title,
    required this.value,
    this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.brown,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    description!,
                    maxLines: 2,
                    softWrap: true,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(icon, color: color, size: 24),
        ],
      ),
    );
  }
}

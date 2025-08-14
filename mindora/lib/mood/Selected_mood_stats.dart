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

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      String? userId = await UserService.getUserId();
      
      // Use fallback user ID for testing if no user is logged in
      userId ??= 'test_user_123';

      // Get mood data for selected date
      final moodResult = await MoodTrackerBackend.getMoodDataForDate(userId, widget.selectedDate);
      if (moodResult['success']) {
        moodData = moodResult['data'];
      }

      // Get stress data for selected date
      final stressResult = await MoodTrackerBackend.getStressDataForDate(userId, widget.selectedDate);
      if (stressResult['success']) {
        stressData = stressResult['data'];
      }

      // Get sleep data for selected date
      final sleepResult = await MoodTrackerBackend.getSleepDataForDate(userId, widget.selectedDate);
      if (sleepResult['success']) {
        sleepData = sleepResult['data'];
      }

      // Get monthly data for weekly overview
      final monthlyResult = await MoodTrackerBackend.getMonthlyMoodData(userId, widget.selectedDate);
      if (monthlyResult['success']) {
        monthlyData = monthlyResult['data'];
      }

    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
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
      if (monthlyData!.containsKey(weekKey)) {
        final weekData = monthlyData![weekKey];
        final moodStatuses = weekData.map((entry) => entry['mood_status']).toList();
        
        // Calculate date range for the week
        final startDate = DateTime(widget.selectedDate.year, widget.selectedDate.month, (week - 1) * 7 + 1);
        final endDate = DateTime(widget.selectedDate.year, widget.selectedDate.month, week * 7);
        final range = "${DateFormat.MMMd().format(startDate)}-${DateFormat.d().format(endDate)}";
        
        // Generate summary based on most common mood
        String summary = _getMoodSummary(moodStatuses);
        
        weeklyOverview.add({
          "week": weekKey,
          "range": range,
          "summary": summary,
        });
      } else {
        weeklyOverview.add({
          "week": weekKey,
          "range": "No data",
          "summary": "No input found",
        });
      }
    }
    
    return weeklyOverview;
  }

  String _getMoodSummary(List<String> moodStatuses) {
    if (moodStatuses.isEmpty) return "No input found";
    
    // Count mood occurrences
    Map<String, int> moodCounts = {};
    for (String mood in moodStatuses) {
      moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
    }
    
    // Find most common mood
    String mostCommonMood = moodCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    return "Mostly $mostCommonMood";
  }

  IconData _getMoodIcon(String moodStatus) {
    switch (moodStatus.toLowerCase()) {
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'sad':
        return Icons.sentiment_very_dissatisfied;
      case 'angry':
        return Icons.sentiment_dissatisfied;
      case 'anxious':
        return Icons.sentiment_neutral;
      case 'excited':
        return Icons.sentiment_satisfied;
      case 'calm':
        return Icons.sentiment_satisfied;
      case 'confused':
        return Icons.sentiment_neutral;
      case 'tired':
        return Icons.sentiment_dissatisfied;
      case 'grateful':
        return Icons.sentiment_very_satisfied;
      default:
        return Icons.sentiment_neutral;
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
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFB79AE0),
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
                    icon: Icons.bar_chart,
                    color: stressData != null ? Colors.redAccent : Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    title: "Sleep",
                    value: sleepData != null 
                        ? "${sleepData!['hours_slept']} hours"
                        : "No input found",
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
              )
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
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.title,
    required this.value,
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
          Column(
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
            ],
          ),
          Icon(icon, color: color, size: 24),
        ],
      ),
    );
  }
}

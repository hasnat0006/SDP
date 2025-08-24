import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'Selected_mood_stats.dart';
import 'backend.dart';
import '../services/user_service.dart';

// String extension for capitalizing first letter
extension StringCapitalization on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}

class MoodInsightsPage extends StatefulWidget {
  final String moodLabel;
  final String moodEmoji;
  final int moodIntensity;
  final List<String> selectedCauses;

  const MoodInsightsPage({
    Key? key,
    required this.moodLabel,
    required this.moodEmoji,
    required this.moodIntensity,
    required this.selectedCauses,
  }) : super(key: key);

  @override
  State<MoodInsightsPage> createState() => _MoodInsightsPageState();
}

class _MoodInsightsPageState extends State<MoodInsightsPage> {
  DateTime? selectedDate;
  Map<String, dynamic>? moodData;
  Map<String, dynamic>? stressData;
  Map<String, dynamic>? sleepData;
  List<Map<String, dynamic>>? weeklyMoodData;
  dynamic chartData; // For storing chart data based on filter
  bool isLoading = true;
  int touchedIndex = -1; // For pie chart interactions

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

  Future<void> _loadChartData() async {
    String? userId = await UserService.getUserId();
    userId ??= 'test_user_123';
    
    final now = DateTime.now();
    
    try {
      switch (selectedFilterIndex) {
        case 0: // Weekly
          final weeklyResult = await MoodTrackerBackend.getWeeklyMoodData(userId);
          if (weeklyResult['success']) {
            chartData = weeklyResult['data'];
          }
          break;
        case 1: // Monthly
          final monthlyResult = await MoodTrackerBackend.getMonthlyMoodData(userId, now);
          if (monthlyResult['success']) {
            chartData = monthlyResult['data'];
          }
          break;
      }
    } catch (e) {
      print('Error loading chart data: $e');
      chartData = null;
    }
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Load today's data
      final today = DateTime.now();
      String? userId = await UserService.getUserId();
      
      // Use fallback user ID for testing if no user is logged in
      userId ??= 'test_user_123';

      // Get mood data for today - with retry logic
      for (int retry = 0; retry < 3; retry++) {
        final moodResult = await MoodTrackerBackend.getMoodDataForDate(userId, today);
        if (moodResult['success'] && moodResult['data'] != null) {
          moodData = moodResult['data'];
          break;
        }
        // Wait a bit before retry to allow backend to sync
        if (retry < 2) await Future.delayed(Duration(milliseconds: 500));
      }

      // Get stress data for today
      final stressResult = await MoodTrackerBackend.getStressDataForDate(userId, today);
      if (stressResult['success']) {
        stressData = stressResult['data'];
      }

      // Get sleep data for today
      final sleepResult = await MoodTrackerBackend.getSleepDataForDate(userId, today);
      if (sleepResult['success']) {
        sleepData = sleepResult['data'];
      }

      // Get weekly mood data - optimized loading
      final weeklyResult = await MoodTrackerBackend.getWeeklyMoodData(userId);
      if (weeklyResult['success']) {
        weeklyMoodData = List<Map<String, dynamic>>.from(weeklyResult['data']);
        // Set chartData for weekly view immediately to avoid double loading
        if (selectedFilterIndex == 0) {
          chartData = weeklyMoodData;
        }
      }

      // Load initial chart data only if not weekly (since we just loaded it)
      if (selectedFilterIndex != 0) {
        await _loadChartData();
      }

    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  IconData _getCauseIcon(String cause) {
    switch (cause.toLowerCase()) {
      case 'work':
      case 'work/study':
        return Icons.work;
      case 'relationships':
        return Icons.favorite;
      case 'health':
        return Icons.health_and_safety;
      case 'family':
        return Icons.family_restroom;
      case 'financial':
      case 'money':
        return Icons.account_balance_wallet;
      case 'social':
        return Icons.group;
      case 'personal':
        return Icons.person;
      case 'academic':
        return Icons.school;
      case 'deadlines':
        return Icons.alarm;
      case 'weather':
        return Icons.cloud;
      case 'medication':
        return Icons.local_pharmacy;
      default:
        return Icons.add_circle_outline;
    }
  }

  List<String> _getDisplayedCauses() {
    print('🔍 Debug - moodData: $moodData');
    print('🔍 Debug - widget.selectedCauses: ${widget.selectedCauses}');
    
    // ALWAYS use backend data if available
    if (moodData != null && moodData!.containsKey('reason')) {
      final backendReasons = moodData!['reason'];
      print('🔍 Debug - backendReasons: $backendReasons');
      if (backendReasons is List) {
        print('✅ Using backend reasons: $backendReasons');
        return List<String>.from(backendReasons);
      }
    }
    
    // Return empty list if no backend data (don't use widget causes)
    print('⚠️ No backend data available, returning empty list');
    return <String>[];
  }

// Filter Tabs
final List<String> filters = ["Weekly", "Monthly"];
int selectedFilterIndex = 0; // Default to "Weekly"
String getCurrentWeekRange() {
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final endOfWeek = startOfWeek.add(const Duration(days: 6));
  final formatter = DateFormat.MMMd();
  return "${formatter.format(startOfWeek)} - ${formatter.format(endOfWeek)}";
}



 void _pickDate() async {
  DateTime now = DateTime.now();
  DateTime? picked = await showDatePicker(
    context: context,
    initialDate: selectedDate ?? now,
    firstDate: DateTime(now.year - 2),
    lastDate: DateTime(now.year + 2),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFB79AE0),
            onPrimary: Colors.white,
            surface: Color(0xFFFFF9F4),
            onSurface: Colors.brown,
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    setState(() => selectedDate = picked);

    // Navigate to MoodStatsPage after selection
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MoodStatsPage(selectedDate: picked),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
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
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color.fromARGB(255, 2, 2, 2)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Mood Today",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: const Color.fromARGB(255, 15, 15, 15),
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
      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color.fromARGB(255, 2, 2, 2)),
      onPressed: () => Navigator.pop(context),
    ),
    title: Text(
      "Mood Today",
      style: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: const Color.fromARGB(255, 15, 15, 15),
      ),
    ),
  ),
  body: SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
  

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.nightlight_round, color: Color(0xFFB79AE0)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            moodData != null 
                                ? MoodTrackerBackend.getMoodIntensityDescription(
                                    moodData!['mood_status'] ?? widget.moodLabel, 
                                    moodData!['mood_level'] ?? widget.moodIntensity
                                  )
                                : MoodTrackerBackend.getMoodIntensityDescription(
                                    widget.moodLabel, 
                                    widget.moodIntensity
                                  ),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      moodData != null 
                          ? MoodTrackerBackend.getMoodBasedNote(
                              moodData!['mood_status'] ?? widget.moodLabel, 
                              moodData!['mood_level'] ?? widget.moodIntensity
                            )
                          : MoodTrackerBackend.getMoodBasedNote(
                              widget.moodLabel, 
                              widget.moodIntensity
                            ),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/insights.png',
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.monitor_heart, color: Colors.deepPurple),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Stress Level",
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                stressData != null
                                    ? MoodTrackerBackend.getStressBasedNote(stressData!['stress_level'])
                                    : "You haven't given today's stress update yet",
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: const Color(0xFFEEE6FA),
                          radius: 18,
                          child: Text(
                            stressData != null ? stressData!['stress_level'].toString() : "-",
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 16),
Divider(
  thickness: 0.5,
  color: Colors.grey,
  height: 10,
),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.bedtime_rounded, color: Colors.deepPurple),
                                  const SizedBox(width: 6),
                                  Text(
                                    sleepData != null 
                                        ? "${sleepData!['sleep_hours'] ?? 'N/A'} hours of sleep"
                                        : "Sleep data not available",
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sleepData != null
                                    ? MoodTrackerBackend.getSleepHoursDescription(_parseDouble(sleepData!['sleep_hours']))
                                    : "You haven't given today's sleep update yet",
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: const Color(0xFFEEE6FA),
                          radius: 18,
                          child: Icon(
                            Icons.bedtime,
                            color: Colors.deepPurple,
                            size: 20,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Causes Section
              if (_getDisplayedCauses().isNotEmpty) Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Logged Causes",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.brown.shade800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _getDisplayedCauses().map((cause) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEE6FA),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getCauseIcon(cause),
                                size: 18,
                                color: const Color(0xFF8E72C7),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                cause,
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF8E72C7),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Align(
  alignment: Alignment.centerLeft,
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        "History: ",
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: const Color.fromARGB(255, 161, 91, 91),
        ),
      ),
      GestureDetector(
        onTap: _pickDate,
        child: const Icon(Icons.calendar_today, size: 19, color: Colors.deepPurple),
      ),
      const SizedBox(width: 5),
      GestureDetector(
        onTap: _pickDate,
        child: Text(
          selectedDate == null
              ? DateFormat.MMMd().format(DateTime.now())
              : DateFormat.MMMd().format(selectedDate!),
          style: GoogleFonts.poppins(
            color: Colors.deepPurple,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      )
    ],
  ),
),

              const SizedBox(height: 30),
              Text(
                "Mood Stats",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "See your mood trends across different time periods.",
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),



Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(32),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 6,
        offset: const Offset(0, 3),
      ),
    ],
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: List.generate(filters.length, (index) {
      final isSelected = index == selectedFilterIndex;

      return GestureDetector(
        onTap: () async {
          setState(() {
            selectedFilterIndex = index;
          });
          // Load new chart data for the selected filter
          await _loadChartData();
          setState(() {});
        },
        child: AnimatedContainer(
  duration: const Duration(milliseconds: 200),
  curve: Curves.easeOut,
  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8), // tighter
  margin: const EdgeInsets.symmetric(horizontal: 3), // tighter
  decoration: BoxDecoration(
    color: isSelected ? const Color(0xFFB79E91) : Colors.transparent,
    borderRadius: BorderRadius.circular(24),
  ),
  child: Text(
    filters[index],
    style: GoogleFonts.poppins(
      color: isSelected ? Colors.white : Colors.brown.shade700,
      fontWeight: FontWeight.w500,
      fontSize: 12.5,
    ),
  ),
),

      );
    }),
  ),
),

const SizedBox(height: 20),

_buildMoodChart(),

const SizedBox(height: 10),

            ],
          ),
        ),
      ),
    );
  }

  // Dynamic mood chart widget based on selected filter - optimized
  Widget _buildMoodChart() {
    // For weekly view, use weeklyMoodData if chartData is null
    if (chartData == null && selectedFilterIndex == 0 && weeklyMoodData != null) {
      chartData = weeklyMoodData;
    }

    if (chartData == null) {
      return Container(
        width: double.infinity,
        height: 310,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'No data available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    switch (selectedFilterIndex) {
      case 0: // Weekly
        return _buildWeeklyChart();
      case 1: // Monthly 
        return _buildMonthlyPieChart();
      default:
        return _buildWeeklyChart();
    }
  }

  // Weekly chart (7 days) - Color coordinated version
  Widget _buildWeeklyChart() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final List<double> data = List.filled(7, 0.0);
    final List<String> moodTypes = List.filled(7, ''); // Store mood types for colors
    
    if (chartData is List) {
      final weeklyList = chartData as List<dynamic>;
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      
      // Create a map of dates in this week for faster lookup
      final Map<String, int> weekDayMap = {};
      for (int i = 0; i < 7; i++) {
        final dayDate = startOfWeek.add(Duration(days: i));
        final dateString = dayDate.toIso8601String().split('T')[0];
        weekDayMap[dateString] = i;
      }
      
      // Process data more efficiently
      for (var dayData in weeklyList) {
        if (dayData is Map<String, dynamic> && dayData['date'] != null) {
          try {
            String dateString;
            if (dayData['date'] is String) {
              dateString = dayData['date'].split('T')[0]; // Handle both formats
            } else {
              final DateTime date = dayData['date'];
              dateString = date.toIso8601String().split('T')[0];
            }
            
            if (weekDayMap.containsKey(dateString)) {
              final int dayIndex = weekDayMap[dateString]!;
              final double moodLevel = double.tryParse(dayData['mood_level']?.toString() ?? '0') ?? 0.0;
              final String moodStatus = dayData['mood_status']?.toString() ?? '';
              data[dayIndex] = moodLevel;
              moodTypes[dayIndex] = moodStatus;
            }
          } catch (e) {
            // Silently continue on error to avoid performance impact
            continue;
          }
        }
      }
    }
    
    final double maxVal = data.every((element) => element == 0.0) 
        ? 5.0 
        : data.reduce(math.max).clamp(1.0, 5.0);

    return Container(
      width: double.infinity,
      height: 360,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Mood Overview',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade800,
            ),
          ),
          const SizedBox(height: 12),
          // Chart area
          Expanded(
            flex: 3,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final double barHeight = data[i] == 0 
                    ? 20.0 
                    : maxVal > 0 
                        ? ((data[i] / maxVal) * 120) + 20 
                        : 20.0;
                
                // Get mood-specific pastel color
                Color getBarColor(String moodType, double moodValue) {
                  if (moodValue == 0 || moodType.isEmpty) {
                    return const Color(0xFFE8E8E8); // Light grey for no data
                  }
                   const Color(0xFFE2D5F1);
                  // Pastel colors matching your app's soothing theme
                  switch (moodType.toLowerCase()) {
                    case 'happy':
                      return const Color.fromARGB(255, 240, 201, 221); // Soft pastel yellow
                    case 'sad':
                      return const Color(0xFFD4E6F1); // Soft pastel blue
                    case 'angry':
                      return const Color.fromARGB(255, 240, 158, 166); // Soft pastel pink/red
                    case 'excited':
                      return  const Color(0xFFE2D5F1); // Soft pastel purple
                    case 'stressed':
                      return const Color(0xFFD5F4E6); // Soft pastel green
                    default:
                      return const Color(0xFFF0F0F0); // Default light grey
                  }
                }
                
                final barColor = getBarColor(moodTypes[i], data[i]);
                
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: barHeight,
                          width: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                barColor,
                                barColor.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: barColor.withOpacity(0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: barColor.withOpacity(0.2),
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: data[i] > 0 ? Center(
                            child: Text(
                              data[i].toInt().toString(),
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.brown.shade600,
                              ),
                            ),
                          ) : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          days[i],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.brown.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          // Legend area
          _buildMoodLegend(moodTypes),
        ],
      ),
    );
  }

  // Helper method to build simple mood color legend
  Widget _buildMoodLegend(List<String> moodTypes) {
    // Define the 5 main moods with their pastel colors
    final Map<String, Color> mainMoods = {
      'Happy': const Color.fromARGB(255, 240, 201, 221),
      'Sad': const Color(0xFFD4E6F1),
      'Angry': const Color.fromARGB(255, 240, 158, 166),
      'Excited':  const Color(0xFFE2D5F1),
      'Stressed':  const Color(0xFFD5F4E6),
    };
   
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mood Colours:',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.brown.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 4,
          children: mainMoods.entries.map((entry) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: entry.value,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: entry.value.withOpacity(0.6),
                      width: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  entry.key,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.brown.shade600,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  // Monthly pie chart - Interactive and animated
  Widget _buildMonthlyPieChart() {
    // Aggregate mood data for the current month
    Map<String, int> moodCounts = {};
    int totalEntries = 0;

    if (chartData is Map<String, dynamic>) {
      final weeklyData = chartData as Map<String, dynamic>;
      
      weeklyData.forEach((week, weekData) {
        if (weekData is List) {
          for (var entry in weekData) {
            if (entry is Map && entry['mood_status'] != null) {
              String moodStatus = entry['mood_status'].toString().toLowerCase();
              moodCounts[moodStatus] = (moodCounts[moodStatus] ?? 0) + 1;
              totalEntries++;
            }
          }
        }
      });
    }

    // If no data, show empty state
    if (totalEntries == 0 || moodCounts.isEmpty) {
      return Container(
        width: double.infinity,
        height: 380,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mood,
                size: 48,
                color: Colors.brown.withOpacity(0.3),
              ),
              const SizedBox(height: 12),
              Text(
                'No mood data available',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.brown.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Define mood colors matching the weekly chart theme
    Color getMoodColor(String mood) {
      switch (mood.toLowerCase()) {
        case 'happy':
          return const Color.fromARGB(255, 240, 201, 221);
        case 'sad':
          return const Color(0xFFD4E6F1);
        case 'angry':
          return const Color.fromARGB(255, 240, 158, 166);
        case 'excited':
          return const Color(0xFFE2D5F1);
        case 'stressed':
          return const Color(0xFFD5F4E6);
        default:
          return const Color(0xFFF0F0F0);
      }
    }

    // Create pie sections with proper theming
    List<PieChartSectionData> sections = [];
    List<MapEntry<String, int>> sortedMoods = moodCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (int i = 0; i < sortedMoods.length; i++) {
      final mood = sortedMoods[i].key;
      final count = sortedMoods[i].value;
      final percentage = (count / totalEntries * 100);
      
      final bool isTouched = i == touchedIndex;

      sections.add(
        PieChartSectionData(
          color: getMoodColor(mood),
          value: percentage,
          title: '', // Remove title from pie slices for cleaner look
          radius: isTouched ? 100 : 85, // Increased size when touched
          titleStyle: const TextStyle(fontSize: 0), // Hide titles
          borderSide: BorderSide(
            color: const Color(0xFFD2B48C), // Light brown border
            width: isTouched ? 1.5 : 1, // Reduced thickness
          ),
          badgeWidget: isTouched ? _buildTooltip(mood, percentage, i, sortedMoods.length) : null,
          badgePositionPercentageOffset: 1.1, // Closer to avoid going off-screen
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 480, // Increased height to accommodate breakdown box above
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            "Monthly Mood Distribution",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.brown.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Tap a slice to see details",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          
          // Breakdown box positioned above the pie chart
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (context, opacity, child) {
              return Opacity(
                opacity: opacity,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - opacity)), // Slide down effect
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.symmetric(
                      horizontal: math.max(8, 12),
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9F4), // Light background
                      border: Border.all(
                        color: Colors.brown.shade600,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monthly Breakdown',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.brown.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Dynamic grid layout to prevent overflow
                        LayoutBuilder(
                          builder: (context, constraints) {
                            List<MapEntry<String, int>> moodList = sortedMoods.take(5).toList();
                            
                            // Dynamic calculation based on available width and content
                            double availableWidth = constraints.maxWidth;
                            int itemsPerRow;
                            
                            // Determine items per row based on available width
                            if (availableWidth > 280) {
                              itemsPerRow = 3;
                            } else if (availableWidth > 200) {
                              itemsPerRow = 2;
                            } else {
                              itemsPerRow = 1;
                            }
                            
                            // Ensure we don't exceed the number of moods available
                            if (itemsPerRow > moodList.length) {
                              itemsPerRow = moodList.length;
                            }
                            
                            List<Widget> rows = [];
                            
                            for (int i = 0; i < moodList.length; i += itemsPerRow) {
                              List<Widget> rowItems = [];
                              
                              for (int j = i; j < i + itemsPerRow && j < moodList.length; j++) {
                                final entry = moodList[j];
                                final mood = entry.key;
                                final count = entry.value;
                                final percentage = (count / totalEntries * 100);
                                
                                rowItems.add(
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          // Color indicator
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: getMoodColor(mood),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: const Color(0xFFD2B48C),
                                                width: 0.8,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          // Mood info
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  mood.capitalize(),
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.brown.shade800,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                                Text(
                                                  '${percentage.toStringAsFixed(1)}%',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.brown.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                                
                                // Add spacing between items in the same row
                                if (j < i + itemsPerRow - 1 && j < moodList.length - 1) {
                                  rowItems.add(const SizedBox(width: 6));
                                }
                              }
                              
                              rows.add(
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    children: rowItems,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  ),
                                ),
                              );
                            }
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: rows,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Centered pie chart without clipping
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Make chart size responsive to screen width
                double chartSize = math.min(
                  constraints.maxWidth * 0.7,
                  constraints.maxHeight * 0.4,
                ).clamp(220.0, 280.0);
                
                // Dynamic center space radius based on chart size
                double centerRadius = chartSize * 0.15; // 15% of chart size
                
                return Container(
                  width: chartSize,
                  height: chartSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Animated pie chart with proper value animation (no clipping)
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeOutCubic,
                        builder: (context, animationValue, child) {
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFD2B48C),
                                width: chartSize * 0.008, // Dynamic border width
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFD2B48C).withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: PieChart(
                              PieChartData(
                                sections: sections.map((section) {
                                  return PieChartSectionData(
                                    color: section.color,
                                    value: section.value * animationValue, // Animate the values properly
                                    title: section.title,
                                    radius: section.radius,
                                    titleStyle: section.titleStyle,
                                    borderSide: section.borderSide,
                                    badgeWidget: section.badgeWidget,
                                    badgePositionPercentageOffset: section.badgePositionPercentageOffset,
                                  );
                                }).toList(),
                                centerSpaceRadius: centerRadius,
                                sectionsSpace: 1.5, // Reduced from 2 to 1.5
                                pieTouchData: PieTouchData(
                                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                    setState(() {
                                      if (!event.isInterestedForInteractions ||
                                          pieTouchResponse == null ||
                                          pieTouchResponse.touchedSection == null) {
                                        touchedIndex = -1;
                                        return;
                                      }
                                      touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                    });

                                    // Auto-hide tooltip after 3 seconds
                                    if (touchedIndex != -1) {
                                      Future.delayed(const Duration(seconds: 3), () {
                                        if (mounted) {
                                          setState(() {
                                            touchedIndex = -1;
                                          });
                                        }
                                      });
                                    }
                                  },
                                ),
                                startDegreeOffset: -90,
                              ),
                            ),
                          );
                        },
                      ),
                      // Inner circle with border - with scale animation
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        builder: (context, scaleValue, child) {
                          // Dynamic inner circle size based on center radius
                          double innerSize = centerRadius * 1.6; // Slightly smaller than center space
                          
                          return Transform.scale(
                            scale: scaleValue,
                            child: Container(
                              width: innerSize,
                              height: innerSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFFF9F4),
                                border: Border.all(
                                  color: const Color(0xFFD2B48C),
                                  width: chartSize * 0.006, // Dynamic border width
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.analytics_outlined,
                                      color: Colors.brown.shade600,
                                      size: innerSize * 0.3, // Dynamic icon size
                                    ),
                                    SizedBox(height: innerSize * 0.025),
                                    Text(
                                      '$totalEntries',
                                      style: GoogleFonts.poppins(
                                        fontSize: innerSize * 0.15, // Dynamic font size
                                        fontWeight: FontWeight.w700,
                                        color: Colors.brown.shade800,
                                      ),
                                    ),
                                    Text(
                                      'entries',
                                      style: GoogleFonts.poppins(
                                        fontSize: innerSize * 0.1, // Dynamic font size
                                        fontWeight: FontWeight.w600,
                                        color: Colors.brown.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build tooltip for touched slice
  Widget _buildTooltip(String mood, double percentage, int sectionIndex, int totalSections) {
    final moodCapitalized = mood.capitalize();
    
    return Container(
      constraints: const BoxConstraints(maxWidth: 180), // Prevent going off-screen
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.brown.shade800,
            Colors.brown.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD2B48C), // Light brown border
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            moodCapitalized,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(1)}% of month',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

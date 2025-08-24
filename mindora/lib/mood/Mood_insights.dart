import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'Selected_mood_stats.dart';
import 'backend.dart';
import '../services/user_service.dart';

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
        case 0: // 1 Week
          final weeklyResult = await MoodTrackerBackend.getWeeklyMoodData(userId);
          if (weeklyResult['success']) {
            chartData = weeklyResult['data'];
          }
          break;
        case 1: // 1 Month (4 weeks)
          final monthlyResult = await MoodTrackerBackend.getMonthlyMoodData(userId, now);
          if (monthlyResult['success']) {
            chartData = monthlyResult['data'];
          }
          break;
        case 2: // 1 Year (12 months)
          final yearlyResult = await MoodTrackerBackend.getYearlyMoodData(userId, now);
          if (yearlyResult['success']) {
            chartData = yearlyResult['data'];
          }
          break;
        case 3: // All Time
          final allTimeResult = await MoodTrackerBackend.getAllTimeMoodData(userId);
          if (allTimeResult['success']) {
            chartData = allTimeResult['data'];
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
final List<String> filters = ["1 Week", "1 Month", "1 Year", "All Time"];
int selectedFilterIndex = 0; // Default to "1 Week"
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

//const SizedBox(height: 10),
              // Right-aligned: History: [calendar icon] [date]

//const SizedBox(height: 10),

// Title: Mood History + current week range - COMMENTED OUT
/*
Text(
  "Mood History (${getCurrentWeekRange()})",
  style: GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.brown,
  ),
),
*/

//const SizedBox(height: 8),


              //const SizedBox(height: 12),

              //Mood History Icons - COMMENTED OUT
              /*
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: List.generate(7, (index) {
    final now = DateTime.now();
    // Calculate the start of the current week (Monday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    // Calculate each day of the week
    final dayDate = startOfWeek.add(Duration(days: index));
    
    // Get the correct day name for this date
    final dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    final dayName = dayNames[index];
    
    // Debug: Print what date we're looking for
    print('🔍 Looking for mood data for $dayName: ${dayDate.toIso8601String().split('T')[0]}');
    
    // Find mood data for this specific date
    Map<String, dynamic>? dayMoodData;
    if (weeklyMoodData != null) {
      print('🔍 Available mood data dates:');
      for (var data in weeklyMoodData!) {
        print('   ${data['date']} -> ${data['mood_status']}');
      }
      
      dayMoodData = weeklyMoodData!.firstWhere(
        (data) {
          final dayDateStr = dayDate.toIso8601String().split('T')[0];
          
          // Try different date matching approaches
          DateTime dataDate;
          try {
            // Handle both DateTime and String formats
            if (data['date'] is String) {
              dataDate = DateTime.parse(data['date']);
            } else {
              dataDate = data['date'];
            }
          } catch (e) {
            print('❌ Error parsing date: ${data['date']} - $e');
            return false;
          }
          
          final matches = dataDate.year == dayDate.year &&
                         dataDate.month == dayDate.month &&
                         dataDate.day == dayDate.day;
          
          // Debug logging for date matching
          print('🔍 Comparing: $dayDateStr vs ${dataDate.toIso8601String().split('T')[0]} = $matches');
          if (matches) {
            print('✅ Found match for $dayName: ${data['mood_status']}');
          }
          
          return matches;
        },
        orElse: () {
          print('⚠️ No mood data found for $dayName (${dayDate.toIso8601String().split('T')[0]})');
          return <String, dynamic>{};
        },
      );
    }
    
    // Determine mood icon and color
    IconData moodIcon;
    Color moodColor;
    
    if (dayMoodData != null && 
        dayMoodData.isNotEmpty && 
        dayMoodData.containsKey('mood_status') && 
        dayMoodData['mood_status'] != null &&
        dayMoodData['mood_status'].toString().isNotEmpty) {
      
      final moodStatus = dayMoodData['mood_status'].toString();
      print('✅ Using mood status for $dayName: $moodStatus');
      
      moodIcon = _getMoodIcon(moodStatus);
      moodColor = MoodTrackerBackend.getMoodColor(moodStatus);
    } else {
      print('❌ No valid mood data for $dayName - using default');
      moodIcon = Icons.help_outline;
      moodColor = Colors.grey;
    }
    
    // Check if this is today to add special styling
    final isToday = dayDate.year == now.year && 
                   dayDate.month == now.month && 
                   dayDate.day == now.day;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: moodColor.withOpacity(0.2),
        shape: BoxShape.circle,
        border: isToday 
          ? Border.all(color: moodColor, width: 3) 
          : Border.all(color: moodColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: moodColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: moodColor.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              moodIcon,
              color: moodColor,
              size: 26,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            dayName,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
              color: isToday ? moodColor : Colors.brown.shade800,
            ),
          ),
        ],
      ),
    );
  }),
),
*/




              // const SizedBox(height: 40),
              // Center(
              //   child: ElevatedButton(
              //     onPressed: () {},
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: const Color(0xFFB79AE0),
              //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              //       padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              //     ),
              //     child: Text("Check Mood Stats →", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
              //   ),
              // )
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
      case 1: // Monthly (4 weeks)
        return _buildMonthlyChart();
      case 2: // Yearly (12 months)
        return _buildYearlyChart();
      case 3: // All Time
        return _buildAllTimeChart();
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
        : data.reduce(max).clamp(1.0, 5.0);

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

  // Monthly chart (4 weeks)
  Widget _buildMonthlyChart() {
    final List<double> data = List.filled(4, 0.0);
    final List<String> weekLabels = ['W1', 'W2', 'W3', 'W4'];
    
    if (chartData is Map<String, dynamic>) {
      final weeklyData = chartData as Map<String, dynamic>;
      
      weeklyData.forEach((week, weekData) {
        if (weekData is List && weekData.isNotEmpty) {
          int weekIndex = -1;
          if (week.contains('1')) weekIndex = 0;
          else if (week.contains('2')) weekIndex = 1;
          else if (week.contains('3')) weekIndex = 2;
          else if (week.contains('4')) weekIndex = 3;
          
          if (weekIndex >= 0 && weekIndex < 4) {
            double totalMood = 0.0;
            int count = 0;
            
            for (var entry in weekData) {
              if (entry is Map && entry['mood_level'] != null) {
                totalMood += double.tryParse(entry['mood_level'].toString()) ?? 0.0;
                count++;
              }
            }
            
            if (count > 0) {
              data[weekIndex] = totalMood / count;
            }
          }
        }
      });
    }
    
    final double maxVal = data.every((element) => element == 0.0) 
        ? 5.0 
        : data.reduce(max).clamp(1.0, 5.0);

    return Container(
      width: double.infinity,
      height: 310,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
            'Monthly Mood Overview (4 Weeks)',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade800,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(4, (i) {
                final double barHeight = data[i] == 0 
                    ? 20.0 
                    : maxVal > 0 
                        ? ((data[i] / maxVal) * 140) + 20 
                        : 20.0;
                
                Color getBarColor(double moodValue) {
                  if (moodValue == 0) return Colors.grey[300]!;
                  
                  final colors = [
                    const Color(0xFF81C784),
                    const Color(0xFF66BB6A),
                    const Color(0xFF4CAF50),
                    const Color(0xFF43A047),
                    const Color(0xFF388E3C),
                  ];
                  
                  int colorIndex = ((moodValue - 1) * (colors.length - 1) / 4).round().clamp(0, colors.length - 1);
                  return colors[colorIndex];
                }
                
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: barHeight,
                          width: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                getBarColor(data[i]),
                                getBarColor(data[i]).withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: getBarColor(data[i]).withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          weekLabels[i],
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
        ],
      ),
    );
  }

  // Yearly chart (12 months) - scrollable
  Widget _buildYearlyChart() {
    final List<double> data = List.filled(12, 0.0);
    final List<String> monthLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    if (chartData is List) {
      final yearlyList = chartData as List<dynamic>;
      
      for (var monthData in yearlyList) {
        if (monthData is Map<String, dynamic> && monthData['month'] != null) {
          try {
            final int month = int.parse(monthData['month'].toString());
            final double avgMood = double.tryParse(monthData['avg_mood_level']?.toString() ?? '0') ?? 0.0;
            
            if (month >= 1 && month <= 12) {
              data[month - 1] = avgMood;
            }
          } catch (e) {
            print('Error parsing yearly mood data: $e');
          }
        }
      }
    }
    
    final double maxVal = data.every((element) => element == 0.0) 
        ? 5.0 
        : data.reduce(max).clamp(1.0, 5.0);

    return Container(
      width: double.infinity,
      height: 310,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
            'Yearly Mood Overview (12 Months)',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade800,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(12, (i) {
                  final double barHeight = data[i] == 0 
                      ? 20.0 
                      : maxVal > 0 
                          ? ((data[i] / maxVal) * 140) + 20 
                          : 20.0;
                  
                  Color getBarColor(double moodValue) {
                    if (moodValue == 0) return Colors.grey[300]!;
                    
                    final colors = [
                      const Color(0xFF81C784),
                      const Color(0xFF66BB6A),
                      const Color(0xFF4CAF50),
                      const Color(0xFF43A047),
                      const Color(0xFF388E3C),
                    ];
                    
                    int colorIndex = ((moodValue - 1) * (colors.length - 1) / 4).round().clamp(0, colors.length - 1);
                    return colors[colorIndex];
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: barHeight,
                          width: 45,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                getBarColor(data[i]),
                                getBarColor(data[i]).withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: getBarColor(data[i]).withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          monthLabels[i],
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.brown.shade700,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // All-time chart (years) - scrollable
  Widget _buildAllTimeChart() {
    List<double> data = [];
    List<String> yearLabels = [];
    
    if (chartData is List) {
      final allTimeList = chartData as List<dynamic>;
      
      for (var yearData in allTimeList) {
        if (yearData is Map<String, dynamic> && yearData['year'] != null) {
          try {
            final String year = yearData['year'].toString();
            final double avgMood = double.tryParse(yearData['avg_mood_level']?.toString() ?? '0') ?? 0.0;
            
            yearLabels.add(year);
            data.add(avgMood);
          } catch (e) {
            print('Error parsing all-time mood data: $e');
          }
        }
      }
    }
    
    if (data.isEmpty) {
      data = [0.0];
      yearLabels = ['No Data'];
    }
    
    final double maxVal = data.every((element) => element == 0.0) 
        ? 5.0 
        : data.reduce(max).clamp(1.0, 5.0);

    return Container(
      width: double.infinity,
      height: 310,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
            'All-Time Mood Overview',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.brown.shade800,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(data.length, (i) {
                  final double barHeight = data[i] == 0 
                      ? 20.0 
                      : maxVal > 0 
                          ? ((data[i] / maxVal) * 140) + 20 
                          : 20.0;
                  
                  Color getBarColor(double moodValue) {
                    if (moodValue == 0) return Colors.grey[300]!;
                    
                    final colors = [
                      const Color(0xFF81C784),
                      const Color(0xFF66BB6A),
                      const Color(0xFF4CAF50),
                      const Color(0xFF43A047),
                      const Color(0xFF388E3C),
                    ];
                    
                    int colorIndex = ((moodValue - 1) * (colors.length - 1) / 4).round().clamp(0, colors.length - 1);
                    return colors[colorIndex];
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: barHeight,
                          width: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                getBarColor(data[i]),
                                getBarColor(data[i]).withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: getBarColor(data[i]).withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          yearLabels[i],
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.brown.shade700,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

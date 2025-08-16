import 'package:client/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'dart:convert';
import 'backend.dart';

class StressInsightsPage extends StatefulWidget {
  final int stressLevel;
  final List<String> cause; // Changed to match DB column
  final List<String> loggedSymptoms; // Changed to match DB column
  final List<String> Notes; // Changed to match DB column

  const StressInsightsPage({
    Key? key,
    required this.stressLevel,
    required this.cause,
    required this.loggedSymptoms,
    required this.Notes,
  }) : super(key: key);

  @override
  State<StressInsightsPage> createState() => _StressInsightsPageState();
}

class _StressInsightsPageState extends State<StressInsightsPage> {
  Map<String, dynamic>? _stressData;
  dynamic _weeklyData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  String _userId = '';

  // Helper method to parse JSON arrays from database
  List<String> _parseJsonArray(dynamic data) {
    if (data == null) return <String>[];
    
    if (data is List) {
      return List<String>.from(data);
    }
    
    if (data is String) {
      try {
        // Try to parse as JSON first
        final decoded = jsonDecode(data);
        if (decoded is List) {
          return List<String>.from(decoded);
        } else {
          return [data];
        }
      } catch (e) {
        // If JSON parsing fails, treat as single string
        return [data];
      }
    }
    
    return <String>[];
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await UserService.getUserData();
      print('Full user data: $userData');
      setState(() {
        _userId = userData['userId'] ?? '';
      });
      print('Loaded user ID for stress: $_userId');
      // Load stress data after user data is loaded
      await _loadStressData();
    } catch (e) {
      print('Error loading user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading user data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadStressData() async {
    if (_userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User ID is not available. Please log in.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Load today's stress data from backend instead of latest
      final stressResult = await StressTrackerBackend.getTodayStressData(_userId);
      print('Raw stress result: $stressResult');
      print('Stress data: ${stressResult['data']}');
      
      // Try to load weekly data, but don't fail if it doesn't work
      Map<String, dynamic> weeklyResult;
      try {
        weeklyResult = await StressTrackerBackend.getWeeklyStressData(_userId);
        print('Weekly data: ${weeklyResult['data']}');
        print('Weekly data type: ${weeklyResult['data'].runtimeType}');
      } catch (e) {
        print('Weekly data error: $e');
        weeklyResult = {'success': false, 'data': [], 'message': 'No weekly data available'};
      }
      
      // Check if stress data loaded successfully
      if (stressResult['success']) {
        setState(() {
          // Store the data for use in the UI
          _stressData = stressResult['data'];
          // Handle weekly data even if it fails
          if (weeklyResult['success']) {
            _weeklyData = weeklyResult['data'];
          } else {
            _weeklyData = []; // Set empty array if weekly data fails
            print('Weekly data failed: ${weeklyResult['message']}');
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(stressResult['message'] ?? 'Failed to load data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle any errors that occur during the API call
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Step 1: Check if the data is still loading
    if (_stressData == null) {
      // Step 2: Show loading indicator if data is not yet loaded
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFD39AD5),
          title: Text('Loading...'),
        ),
        body: Center(
          child: CircularProgressIndicator(), // Show a loading spinner
        ),
      );
    }
    // Use the fetched data from backend instead of widget properties
    final stressLevel = _stressData?['stress_level'] ?? 1;
    final List<String> causes = _parseJsonArray(_stressData?['cause']);
    final List<String> loggedSymptoms = _parseJsonArray(_stressData?['logged_symptoms']);
    final List<String> notes = _parseJsonArray(_stressData?['notes']);

    // Debug logging to see what we're getting from backend
    print('Backend stress data: $_stressData');
    print('Parsed stress level: $stressLevel');
    print('Parsed causes: $causes');
    print('Parsed symptoms: $loggedSymptoms');
    print('Parsed notes: $notes');

    return Scaffold(
      backgroundColor: const Color(0xFFF6F0FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD39AD5), // Pink app bar
        toolbarHeight: 80,
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context); // Navigate back to StressTrackerPage
          },
        ),
        title: Text(
          'Stress Insights',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Today's Summary with White Lavender Tab
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Today\'s Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Stress Level Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Stress Level
                          Text(
                            '$stressLevel/5',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF8E72C7),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Stress Level Label
                          Text(
                            'Stress Level',
                            style: GoogleFonts.poppins(
                              fontSize: 23,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF8E72C7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Categories with styled buttons
                      Text(
                        'Reported Causes',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color.fromARGB(255, 100, 94, 110),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 45,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: causes.map((cause) {
                              // Map causes to their respective icons
                              IconData icon = _getCauseIcon(cause);
                              return _buildCategoryButton(cause, icon);
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Call the Weekly Overview Graph widget here
                _buildWeeklyOverviewGraph(), // Call it outside of the widget tree

                const SizedBox(height: 16),

                // Reported Symptoms with white tab and icons
                _buildSectionWithTabs(
                  title: 'Logged Symptoms',
                  children: loggedSymptoms.isNotEmpty
                      ? loggedSymptoms.map((symptom) {
                          return _buildSymptomTab(
                            symptom,
                            _getSymptomIcon(symptom),
                          );
                        }).toList()
                      : [
                          _buildSymptomTab(
                            'No symptoms',
                            Icons.check_circle_outline,
                          ),
                        ],
                ),

                const SizedBox(height: 16),

                // Recommended Activities with white tab and small square tabs
                _buildSectionWithTabs(
                  title: 'Recommended Activities',
                  children: _getRecommendedActivitiesForSymptoms(loggedSymptoms).map((activity) {
                    return _buildActivityTab(
                      activity['name'],
                      activity['icon'],
                      activity['duration'],
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Your Notes in a nice tab with custom size and border
                _buildNotesSection(notes), // Add this to your widget tree
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Your Notes section widget (Moved outside of the build method)
  Widget _buildNotesSection(List<String> notes) {
    return Container(
      width: double.infinity, // Ensure it spans the full width
      height:
          100, // Adjust the height to match the size of the symptom/activity containers
      margin: const EdgeInsets.only(bottom: 16), // Add spacing at the bottom
      decoration: BoxDecoration(
        color: const Color.fromARGB(
          255,
          255,
          255,
          255,
        ), // Light lavender background
        borderRadius: BorderRadius.circular(10), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4), // Subtle shadow
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding inside
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Notes',
              style: TextStyle(
                fontSize: 16, // Title font size
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              notes.isNotEmpty ? notes[0] : 'No notes added.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color.fromARGB(255, 117, 100, 117),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Weekly Overview Graph widget with dynamic bar chart
  Widget _buildWeeklyOverviewGraph() {
    // If weekly data is not available, show loading or placeholder
    if (_weeklyData == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD39AD5),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }

    // Process weekly data for the bar chart
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    // Initialize data for 7 days with 0 values
    final List<double> data = List.filled(7, 0.0);
    print('Initial data array: $data');
    print('Days mapping: Mon=0, Tue=1, Wed=2, Thu=3, Fri=4, Sat=5, Sun=6');
    
    // Handle different data structures that might be returned
    List<dynamic>? weeklyList;
    
    if (_weeklyData is List) {
      weeklyList = _weeklyData as List<dynamic>;
    } else if (_weeklyData is Map<String, dynamic> && _weeklyData!['data'] is List) {
      weeklyList = _weeklyData!['data'] as List<dynamic>;
    } else if (_weeklyData is Map<String, dynamic>) {
      // If it's a single map, convert to list
      weeklyList = [_weeklyData];
    }
    
    if (weeklyList != null) {
      print('Processing ${weeklyList.length} day entries');
      for (var dayData in weeklyList) {
        if (dayData is Map<String, dynamic> && dayData['day'] != null) {
          try {
            final DateTime dayDate = DateTime.parse(dayData['day']);
            final double stressLevel = double.tryParse(dayData['avg_stress_level']?.toString() ?? '0') ?? 0.0;
            
            // Correct day mapping: Monday=0, Tuesday=1, ..., Sunday=6
            int dayOfWeek;
            switch (dayDate.weekday) {
              case DateTime.monday:
                dayOfWeek = 0;
                break;
              case DateTime.tuesday:
                dayOfWeek = 1;
                break;
              case DateTime.wednesday:
                dayOfWeek = 2;
                break;
              case DateTime.thursday:
                dayOfWeek = 3;
                break;
              case DateTime.friday:
                dayOfWeek = 4;
                break;
              case DateTime.saturday:
                dayOfWeek = 5;
                break;
              case DateTime.sunday:
                dayOfWeek = 6;
                break;
              default:
                dayOfWeek = -1;
            }
            
            print('Date: ${dayData['day']}, Weekday: ${dayDate.weekday}, MappedIndex: $dayOfWeek, StressLevel: $stressLevel');
            
            if (dayOfWeek >= 0 && dayOfWeek < 7) {
              data[dayOfWeek] = stressLevel;
              print('Assigned stress level $stressLevel to ${days[dayOfWeek]}');
            }
          } catch (e) {
            print('Error parsing day data: $e');
            print('Day data structure: $dayData');
          }
        }
      }
      print('Final data array: $data');
    }

    // Find max value for scaling
    final double maxVal = data.every((element) => element == 0.0) 
        ? 5.0 
        : data.reduce(max).clamp(1.0, 5.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 240,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (i) {
                    // Show minimum height for 0 values, scale others properly
                    final double barHeight = data[i] == 0 
                        ? 20.0 // Small bar for 0 values
                        : maxVal > 0 
                            ? ((data[i] / maxVal) * 120) + 20 // Add 20px base height
                            : 20.0;
                    
                    // Create beautiful gradient colors matching the page theme
                    Color getBarColor(double stressValue) {
                      if (stressValue == 0) return Colors.grey[300]!;
                      
                      // More vibrant green gradient
                      final colors = [
                        const Color(0xFF8BC34A), // Vibrant light green (level 1)
                        const Color(0xFF66BB6A), // Fresh green (level 2)
                        const Color(0xFF4CAF50), // Standard vibrant green (level 3)
                        const Color(0xFF43A047), // Rich green (level 4)
                        const Color(0xFF2E7D32), // Deep vibrant green (level 5)
                      ];
                      
                      int colorIndex = ((stressValue - 1) * (colors.length - 1) / 4).round().clamp(0, colors.length - 1);
                      return colors[colorIndex];
                    }
                    
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOutBack,
                              height: barHeight,
                              width: 40, // Much thicker bars
                              decoration: BoxDecoration(
                                gradient: data[i] > 0 
                                    ? LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          getBarColor(data[i]),
                                          getBarColor(data[i]).withOpacity(0.8),
                                        ],
                                      )
                                    : null,
                                color: data[i] == 0 ? getBarColor(0) : null,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: data[i] > 0 
                                        ? getBarColor(data[i]).withOpacity(0.3)
                                        : Colors.grey.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: data[i] > 0
                                    ? Padding(
                                        padding: const EdgeInsets.only(bottom: 6.0),
                                        child: Text(
                                          data[i].toStringAsFixed(1),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            shadows: [
                                              Shadow(
                                                offset: Offset(0, 1),
                                                blurRadius: 3,
                                                color: Colors.black54,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              days[i],
                              style: TextStyle(
                                fontSize: 13,
                                color: data[i] > 0 ? Colors.black87 : Colors.grey[400],
                                fontWeight: FontWeight.w600,
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
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Custom section with title and tabs
  Widget _buildSectionWithTabs({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120, // Fixed height for the scrollable area
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get icon for each symptom
  IconData _getSymptomIcon(String symptom) {
    switch (symptom.toLowerCase()) {
      case 'headache':
        return Icons.sick;
      case 'tension':
        return Icons.fitness_center;
      case 'fatigue':
        return Icons.battery_alert;
      case 'anxiety':
        return Icons.psychology;
      default:
        return Icons.healing; // Default icon for other symptoms
    }
  }

  // Symptom Tab Widget with Icons
  Widget _buildSymptomTab(String label, IconData icon) {
    return Container(
      width: 100,
      height: 98,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 241, 220, 241),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color.fromARGB(255, 177, 38, 119)),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color.fromARGB(255, 177, 38, 119),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Activity Tab Widget with Icons
  Widget _buildActivityTab(String label, IconData icon, String time) {
    return Container(
      width: 135,
      height: 98,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 236, 207, 225), // Lavender background
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color.fromARGB(255, 88, 35, 104),
          ), // Icon with color
          Text(
            label,
            style: GoogleFonts.poppins(
              color: const Color.fromARGB(
                255,
                83,
                33,
                99,
              ), // Text color same as icon
              fontWeight: FontWeight.bold, // Bold text
            ),
          ),
          Text(
            time,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color.fromARGB(
                255,
                166,
                121,
                180,
              ), // Text color same as icon
              fontWeight: FontWeight.bold, // Bold text
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get recommended activities based on symptoms and stress level
  List<Map<String, dynamic>> _getRecommendedActivitiesForSymptoms(List<String> symptoms) {
    Set<Map<String, dynamic>> activities = {};
    
    // Default activities for general stress
    final defaultActivities = [
      {'name': 'Deep Breathing', 'icon': Icons.accessibility, 'duration': '5 mins'},
      {'name': 'Meditation', 'icon': Icons.spa, 'duration': '10 mins'},
    ];
    
    // If we have specific symptoms, provide targeted activities
    if (symptoms.isNotEmpty) {
      for (String symptom in symptoms) {
        switch (symptom.toLowerCase()) {
          case 'headache':
            activities.addAll([
              {'name': 'Head Massage', 'icon': Icons.healing, 'duration': '10 mins'},
              {'name': 'Cold Compress', 'icon': Icons.ac_unit, 'duration': '15 mins'},
              {'name': 'Dark Room Rest', 'icon': Icons.bedtime, 'duration': '20 mins'},
              {'name': 'Hydrate', 'icon': Icons.local_drink, 'duration': '5 mins'},
            ]);
            break;
          case 'tension':
            activities.addAll([
              {'name': 'Neck Stretches', 'icon': Icons.accessibility_new, 'duration': '8 mins'},
              {'name': 'Shoulder Rolls', 'icon': Icons.rotate_right, 'duration': '5 mins'},
              {'name': 'Progressive Relaxation', 'icon': Icons.self_improvement, 'duration': '15 mins'},
              {'name': 'Warm Bath', 'icon': Icons.hot_tub, 'duration': '25 mins'},
            ]);
            break;
          case 'fatigue':
            activities.addAll([
              {'name': 'Power Nap', 'icon': Icons.bedtime, 'duration': '20 mins'},
              {'name': 'Light Exercise', 'icon': Icons.directions_walk, 'duration': '10 mins'},
              {'name': 'Energy Snack', 'icon': Icons.apple, 'duration': '5 mins'},
              {'name': 'Fresh Air', 'icon': Icons.air, 'duration': '15 mins'},
            ]);
            break;
          case 'anxiety':
            activities.addAll([
              {'name': 'Grounding (5-4-3-2-1)', 'icon': Icons.psychology, 'duration': '10 mins'},
              {'name': 'Calm Music', 'icon': Icons.music_note, 'duration': '15 mins'},
              {'name': 'Breathing Exercise', 'icon': Icons.air, 'duration': '8 mins'},
              {'name': 'Journaling', 'icon': Icons.edit_note, 'duration': '12 mins'},
            ]);
            break;
        }
      }
      // Add some general activities alongside symptom-specific ones
      activities.addAll(defaultActivities);
    } else {
      // No specific symptoms - provide general stress relief based on stress level
      final stressLevel = _stressData?['stress_level'] ?? 1;
      
      activities.addAll(defaultActivities);
      
      if (stressLevel >= 4) {
        // High stress - more intensive activities
        activities.addAll([
          {'name': 'Intense Workout', 'icon': Icons.fitness_center, 'duration': '30 mins'},
          {'name': 'Cold Shower', 'icon': Icons.shower, 'duration': '5 mins'},
          {'name': 'Scream Therapy', 'icon': Icons.campaign, 'duration': '3 mins'},
        ]);
      } else if (stressLevel >= 3) {
        // Moderate stress - balanced activities
        activities.addAll([
          {'name': 'Yoga', 'icon': Icons.self_improvement, 'duration': '15 mins'},
          {'name': 'Nature Walk', 'icon': Icons.directions_walk, 'duration': '20 mins'},
          {'name': 'Tea Break', 'icon': Icons.local_cafe, 'duration': '10 mins'},
        ]);
      } else {
        // Low stress - gentle activities
        activities.addAll([
          {'name': 'Light Stretching', 'icon': Icons.accessibility_new, 'duration': '10 mins'},
          {'name': 'Read a Book', 'icon': Icons.menu_book, 'duration': '25 mins'},
          {'name': 'Listen to Music', 'icon': Icons.music_note, 'duration': '15 mins'},
        ]);
      }
    }
    
    // Convert to list and limit to 6 activities max
    final activityList = activities.toList();
    return activityList.take(6).toList();
  }
  IconData _getCauseIcon(String cause) {
    switch (cause.toLowerCase()) {
      case 'work/study':
        return Icons.work;
      case 'relationships':
        return Icons.favorite;
      case 'health':
        return Icons.health_and_safety;
      case 'family':
        return Icons.family_restroom;
      case 'financial':
        return Icons.account_balance_wallet;
      case 'social media':
        return Icons.phone_android;
      case 'academic':
        return Icons.school;
      case 'environmental':
        return Icons.nature;
      case 'sleep':
        return Icons.bedtime;
      case 'time management':
        return Icons.access_time;
      case 'other':
        return Icons.more_horiz;
      default:
        return Icons.label_important; // Default icon for custom causes
    }
  }

  // Category Button Widget
  Widget _buildCategoryButton(String label, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(icon, color: const Color.fromARGB(255, 138, 5, 78)),
        label: Text(
          label,
          style: GoogleFonts.poppins(
            color: const Color.fromARGB(255, 138, 5, 78),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(
            255,
            243,
            211,
            247,
          ), // Background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        ),
      ),
    );
  }
}

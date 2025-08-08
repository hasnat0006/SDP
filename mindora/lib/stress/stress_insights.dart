import 'package:client/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  Map<String, dynamic>? _weeklyData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadStressData();
  }

  String _userId = '';
  String _userType = '';

  Future<void> _loadUserData() async {
    try {
      final userData = await UserService.getUserData();
      print(userData);
      setState(() {
        _userId = userData['uuid'] ?? '';
        _userType = userData['type'] ?? '';
      });
    } catch (e) {
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
    // Load stress data from backend
    final stressResult = await StressTrackerBackend.getStressData(_userId);
    final weeklyResult = await StressTrackerBackend.getWeeklyStressData(_userId);

    // Check if both API calls were successful
    if (stressResult['success'] && weeklyResult['success']) {
      setState(() {
        // Store the data for use in the UI
        _stressData = stressResult['data'];
        _weeklyData = weeklyResult['data'];
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
  if (_stressData == null || _weeklyData == null) {
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
    final stressLevel = _stressData?['stress_level'] ?? widget.stressLevel;
    // Use the fetched data or fall back to widget properties

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
                            children: widget.cause.map((cause) {
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
                  children: widget.loggedSymptoms.isNotEmpty
                      ? widget.loggedSymptoms.map((symptom) {
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
                  children: [
                    _buildActivityTab(
                      'Deep Breathing',
                      Icons.accessibility,
                      '5 mins',
                    ),
                    _buildActivityTab(
                      'Nature Walk',
                      Icons.directions_walk,
                      '15 mins',
                    ),
                    _buildActivityTab(
                      'Yoga',
                      Icons.self_improvement,
                      '10 mins',
                    ),
                    _buildActivityTab('Meditation', Icons.spa, '20 mins'),
                    _buildActivityTab(
                      'Stretching',
                      Icons.accessibility_new,
                      '7 mins',
                    ),
                    _buildActivityTab(
                      'Jogging',
                      Icons.directions_run,
                      '30 mins',
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Your Notes in a nice tab with custom size and border
                _buildNotesSection(), // Add this to your widget tree
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Your Notes section widget (Moved outside of the build method)
  Widget _buildNotesSection() {
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
              widget.Notes.isNotEmpty ? widget.Notes[0] : 'No notes added.',
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

  // Weekly Overview Graph widget moved outside the tab with rounded edges and shadow
  Widget _buildWeeklyOverviewGraph() {
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
          height: 350, // Adjust size as necessary
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), // Rounded edges
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20), // Apply rounded corners
            child: Image.asset(
              'assets/graph.png', // Replace with your graph image
              fit: BoxFit.cover, // Ensure the image fits nicely
            ),
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

  // Helper method to get icon for each cause
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

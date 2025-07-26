import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StressInsightsPage extends StatelessWidget {
  final int stressLevel;
  final List<String> selectedCauses;
  final String notes;

  const StressInsightsPage({
    Key? key,
    required this.stressLevel,
    required this.selectedCauses,
    required this.notes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
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
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                              fontSize: 16,
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
                             // fontWeight: FontWeight.w600,
                              color: const Color.fromARGB(255, 100, 94, 110),
                            ),
                          ),
                          const SizedBox(height: 10),
                       Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCategoryButton('Relationships', Icons.favorite),
                          _buildCategoryButton('Work', Icons.work),
                          _buildCategoryButton('Health', Icons.health_and_safety),
                        ],
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
                  children: [
                    _buildSymptomTab('Headache', Icons.headset),
                    _buildSymptomTab('Fatigue', Icons.battery_alert),
                    _buildSymptomTab('Muscle Tension', Icons.sports_gymnastics),
                  ],
                ),
                const SizedBox(height: 16),

                // Recommended Activities with white tab and small square tabs
                _buildSectionWithTabs(
                  title: 'Recommended Activities',
                 children: [
  _buildActivityTab('Deep Breathing', Icons.accessibility, '5 mins'), // Heart Icon for Deep Breathing
  _buildActivityTab('Nature Walk', Icons.directions_walk, '15 mins'), // Nature Walk Icon
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
      width: double.infinity,  // Ensure it spans the full width
      height: 100,  // Adjust the height to match the size of the symptom/activity containers
      margin: const EdgeInsets.only(bottom: 16),  // Add spacing at the bottom
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255), // Light lavender background
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
                fontSize: 16,  // Title font size
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              notes,  // Display the notes text
              style: GoogleFonts.poppins(
                fontSize: 14, // Adjust the font size of the notes text
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
  Widget _buildSectionWithTabs({required String title, required List<Widget> children}) {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: children,
          ),
        ],
      ),
    );
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
            style: GoogleFonts.poppins(color: const Color.fromARGB(255, 177, 38, 119), fontSize: 14, fontWeight: FontWeight.w600),
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
          Icon(icon, color: const Color.fromARGB(255, 88, 35, 104)), // Icon with color
          Text(
            label,
            style: GoogleFonts.poppins(
              color: const Color.fromARGB(255, 83, 33, 99), // Text color same as icon
              fontWeight: FontWeight.bold, // Bold text
            ),
          ),
          Text(
            time,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color.fromARGB(255, 166, 121, 180), // Text color same as icon
              fontWeight: FontWeight.bold, // Bold text
            ),
          ),
        ],
      ),
    );
  }

  // Category Button Widget
  Widget _buildCategoryButton(String label, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: const Color.fromARGB(255, 138, 5, 78)),
      label: Text(
        label,
        style: GoogleFonts.poppins(color: const Color.fromARGB(255, 138, 5, 78)),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 243, 211, 247), // Background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      ),
    );
  }
}

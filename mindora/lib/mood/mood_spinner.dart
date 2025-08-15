import 'package:client/mood/Mood_intensity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/arc_gauge.dart';

class MoodSpinner extends StatefulWidget {
  const MoodSpinner({super.key});

  @override
  State<MoodSpinner> createState() => _MoodSpinnerState();
}

class _MoodSpinnerState extends State<MoodSpinner> {
  double currentRotation = 0.0;
  String selectedSegment = 'Happy';
  bool isHovering = false;

  // Get current mood data based on selected segment
  Map<String, String> get currentMood {
    // Define the segments data locally to avoid null issues
    const segments = [
      {'emoji': '😟', 'name': 'Stressed'},
      {'emoji': '😢', 'name': 'Sad'},
      {'emoji': '😊', 'name': 'Happy'},
      {'emoji': '😠', 'name': 'Angry'},
      {'emoji': '😃', 'name': 'Excited'},
      {'emoji': '😟', 'name': 'Stressed'},
      {'emoji': '😢', 'name': 'Sad'},
      {'emoji': '😊', 'name': 'Happy'},
      {'emoji': '😠', 'name': 'Angry'},
      {'emoji': '😃', 'name': 'Excited'},
    ];

    // Find the matching segment
    final segment = segments.firstWhere(
      (seg) => seg['name'] == selectedSegment,
      orElse: () => segments[2], // Default to Happy if not found
    );

    return {'label': segment['name']!, 'emoji': segment['emoji']!};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD39AD5), // pink AppBar
        toolbarHeight: 88,
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
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Mood Tracker',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 3, 3, 3),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: MouseRegion(
              onEnter: (_) => setState(() => isHovering = true),
              onExit: (_) => setState(() => isHovering = false),
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MoodIntensityPage(
                        moodLabel: currentMood["label"]!,
                        moodEmoji: currentMood["emoji"]!,
                      ),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isHovering
                        ? const Color.fromARGB(255, 119, 83, 71)
                        : const Color.fromARGB(255, 165, 123, 109),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      if (isHovering)
                        BoxShadow(
                          color: Colors.brown.withOpacity(0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Text(
                    "Next →",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Top section with selected segment display
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // Adjusted to move text higher
              children: [
                const SizedBox(height: 20), // Spacing after AppBar

                const SizedBox(height: 20),
                Text(
                  'How would you\ndescribe your mood today?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                    shadows: const [
                      Shadow(
                        offset: Offset(0.5, 2),
                        blurRadius: 4,
                        color: Color.fromARGB(120, 0, 0, 0), // Soft shadow
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    'I Feel ${currentMood["label"]}.',
                    key: ValueKey(currentMood["label"]),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color.fromARGB(255, 99, 97, 97),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Text(
                    currentMood["emoji"]!,
                    key: ValueKey(currentMood["emoji"]),
                    style: const TextStyle(fontSize: 60),
                  ),
                ),
                const SizedBox(height: 30),

                Text(
                  'Spin below to select your mood',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),

                  // Custom arrow with animation below
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade300,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.5),
                        blurRadius: 12,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.expand_more,
                    size: 28,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 10),

                // Italic label and arrow under the emoji
                // Text(
                //   'Spin below to select your mood',
                //   style: GoogleFonts.poppins(
                //     fontSize: 14,
                //     fontStyle: FontStyle.italic,
                //     color: Colors.grey,
                //   ),
                // ),
               // const SizedBox(height: 10),
                // Icon(
                //   Icons.arrow_downward,
                //   color: const Color(0xFFD39AD5), // Lavender color for the arrow
                //   size: 30,  // Slightly larger arrow
                // ),
              ],
            ),
          ),
          //const SizedBox(height: 10),

          // Arc gauge at the bottom - always shows 180° window
          ArcGauge(
            outerRadius: 200,
            innerRadius: 100,
            onRotationChanged: (degrees) {
              setState(() {
                currentRotation = degrees;
              });
            },
            onSegmentSelected: (index, name) {
              setState(() {
                selectedSegment = name;
              });
            },
          ),
        ],
      ),
    );
  }
}

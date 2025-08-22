import 'package:client/mood/Mood_intensity.dart';
import 'package:client/mood/predictive_mood_popup.dart';
import 'package:client/mood/backend.dart';
import 'package:client/services/user_service.dart';
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
  bool isPredictiveButtonHovering = false;

  @override
  void initState() {
    super.initState();
    // Check if data exists before showing predictive mood popup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDataAndShowPopup();
    });
  }

  Future<void> _checkDataAndShowPopup() async {
    try {
      // Get user data first
      final userData = await UserService.getUserData();
      final userId = userData['userId'] ?? '';
      
      if (userId.isEmpty) {
        print('❌ No user ID found, skipping popup');
        return;
      }

      final today = DateTime.now();
      
      // Check if both sleep and stress data exist for today
      final results = await Future.wait([
        MoodTrackerBackend.getSleepDataForDate(userId, today),
        MoodTrackerBackend.getStressDataForDate(userId, today),
      ]);

      final sleepResult = results[0];
      final stressResult = results[1];

      print('🔍 Data check - Sleep: ${sleepResult['success']}, Stress: ${stressResult['success']}');

      // Show popup if at least one data exists
      if (sleepResult['success'] == true || stressResult['success'] == true) {
        print('✅ At least one data available, showing popup');
        _showPredictiveMoodPopup();
      } else {
        print('ℹ️ No data available, popup will not be shown automatically');
      }
    } catch (e) {
      print('❌ Error checking data availability: $e');
    }
  }

  void _showPredictiveMoodPopup() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must choose an option
      builder: (BuildContext context) {
        return PredictiveMoodPopup(
          onManualSelection: () {
            // User chose manual selection, continue with normal flow
            // The popup is already dismissed by the PredictiveMoodPopup widget
          },
        );
      },
    );
  }
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 20), 

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

                const SizedBox(height: 15),
                
                // Predictive Mood Button
                MouseRegion(
                  onEnter: (_) => setState(() => isPredictiveButtonHovering = true),
                  onExit: (_) => setState(() => isPredictiveButtonHovering = false),
                  child: GestureDetector(
                    onTap: _handlePredictiveButtonTap,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isPredictiveButtonHovering
                              ? [
                                  const Color(0xFFE1A6F0),
                                  const Color(0xFFD39AD5),
                                ]
                              : [
                                  const Color(0xFFEBB3F5).withOpacity(0.8),
                                  const Color(0xFFDDA6E8).withOpacity(0.8),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          if (isPredictiveButtonHovering)
                            BoxShadow(
                              color: const Color(0xFFD39AD5).withOpacity(0.6),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                              spreadRadius: 2,
                            )
                          else
                            BoxShadow(
                              color: const Color(0xFFD39AD5).withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                              spreadRadius: 1,
                            ),
                          // Additional base shadow for more depth
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Text(
                          //   '🤖',
                          //   style: TextStyle(fontSize: 18),
                          // ),
                          // const SizedBox(width: 8),
                          Text(
                            'Predictive Mood',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isPredictiveButtonHovering 
                                  ? Colors.white 
                                  : const Color(0xFF6D3670),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.auto_awesome,
                            size: 16,
                            color: isPredictiveButtonHovering 
                                ? Colors.white 
                                : const Color(0xFF6D3670),
                          ),
                        ],
                      ),
                    ),
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

  Future<void> _handlePredictiveButtonTap() async {
    try {
      // Get user data first
      final userData = await UserService.getUserData();
      final userId = userData['userId'] ?? '';
      
      if (userId.isEmpty) {
        _showNoDataDialog();
        return;
      }

      final today = DateTime.now();
      
      // Check if both sleep and stress data exist for today
      final results = await Future.wait([
        MoodTrackerBackend.getSleepDataForDate(userId, today),
        MoodTrackerBackend.getStressDataForDate(userId, today),
      ]);

      final sleepResult = results[0];
      final stressResult = results[1];

      // Show popup if at least one data exists, otherwise show no data dialog
      if (sleepResult['success'] == true || stressResult['success'] == true) {
        _showPredictiveMoodPopup();
      } else {
        _showNoDataDialog();
      }
    } catch (e) {
      print('❌ Error checking data for predictive button: $e');
      _showNoDataDialog();
    }
  }

  void _showNoDataDialog() {
    // Create an overlay entry for the slide-down popup
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => SlideDownPopup(
        message: "Sorry, you haven't logged any data yet!",
        onDismiss: () => overlayEntry.remove(),
      ),
    );
    
    Overlay.of(context).insert(overlayEntry);
    
    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

class SlideDownPopup extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;
  
  const SlideDownPopup({
    Key? key,
    required this.message,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<SlideDownPopup> createState() => _SlideDownPopupState();
}

class _SlideDownPopupState extends State<SlideDownPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    // Start the slide-down animation
    _animationController.forward();
    
    // Start slide-up animation after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _animationController.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9F4),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: const Color(0xFFD39AD5).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD39AD5).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: const Color(0xFF6D3670),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.message,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6D3670),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _animationController.reverse().then((_) {
                      widget.onDismiss();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      color: Colors.grey[500],
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

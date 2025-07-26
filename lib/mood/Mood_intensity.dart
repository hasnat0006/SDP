import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Mood_insights.dart'; 

class MoodIntensityPage extends StatefulWidget {
  final String moodLabel;
  final String moodEmoji;

  const MoodIntensityPage({
    super.key,
    required this.moodLabel,
    required this.moodEmoji,
  });

  @override
  State<MoodIntensityPage> createState() => _MoodIntensityPageState();
}

class _MoodIntensityPageState extends State<MoodIntensityPage> with SingleTickerProviderStateMixin {
  int selectedIntensity = 3;
  bool isHovering = false;

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  String getMoodIntensityLabel(int value) {
    final mood = widget.moodLabel.toLowerCase();
    switch (value) {
      case 1:
        return "I feel just a little $mood today.";
      case 2:
        return "I feel mildly $mood today.";
      case 3:
        return "I feel moderately $mood today.";
      case 4:
        return "I feel pretty $mood today.";
      case 5:
        return "I feel extremely $mood today.";
      default:
        return "";
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD39AD5),
        toolbarHeight: 80,
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color.fromARGB(255, 12, 12, 12)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Mood Tracker',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 2, 2, 2),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 130), 
            SlideTransition(
              position: _slideAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFD1F5),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD39AD5).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 12),
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, -4),
                      spreadRadius: -4,
                    ),
                    BoxShadow(
                      color: const Color.fromARGB(255, 214, 168, 216).withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 30),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'How ${widget.moodLabel.toLowerCase()} are \n you feeling today?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 109, 54, 112),
                        shadows: const [
                          Shadow(
                            blurRadius: 4,
                            color: Color.fromARGB(255, 125, 100, 177),
                            offset: Offset(0.5, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      '$selectedIntensity',
                      style: GoogleFonts.poppins(
                        fontSize: 90,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF8E72C7),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(48),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFCEB5F4).withOpacity(0.12),
                            blurRadius: 18,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(5, (index) {
                          final number = index + 1;
                          final isSelected = selectedIntensity == number;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIntensity = number;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 42,
                              height: 42,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFD39AD5) : Colors.transparent,
                                shape: BoxShape.circle,
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFFD39AD5).withOpacity(0.4),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Text(
                                "$number",
                                style: GoogleFonts.poppins(
                                  color: isSelected ? Colors.white : const Color(0xFF836BB1),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      getMoodIntensityLabel(selectedIntensity),
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF7A57A6),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        shadows: const [
                          Shadow(
                            blurRadius: 2,
                            color: Color.fromARGB(50, 0, 0, 0),
                            offset: Offset(0.5, 0.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 35),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: MouseRegion(
                onEnter: (_) => setState(() => isHovering = true),
                onExit: (_) => setState(() => isHovering = false),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MoodInsightsPage(),
                      ),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    transform: Matrix4.identity()..scale(isHovering ? 1.03 : 1.0),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    width: double.infinity,
                    decoration: BoxDecoration(
gradient: LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: isHovering
      ? [Color.fromARGB(255, 233, 188, 240), Color.fromARGB(255, 207, 126, 228)] // Light hover blend
      : [Color(0xFFD6A6E1), Color(0xFFB78ED3)], // Base gradient
),

  borderRadius: BorderRadius.circular(20),
  boxShadow: [
    BoxShadow(
      color: const Color(0xFFB89EDF).withOpacity(isHovering ? 0.5 : 0.3),
      blurRadius: isHovering ? 16 : 10,
      offset: const Offset(0, 6),
    ),
  ],
),

                    child: Center(
                      child: Text(
                        "Continue →",
                        style: GoogleFonts.poppins(
                          color: const Color.fromARGB(255, 250, 247, 247),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}

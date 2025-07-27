import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Mood_insights.dart'; // Add the Mood Insights page import

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
  List<String> selectedCauses = [];
  List<String> stressCauses = [
    'Work',
    'Family',
    'Health',
    'Financial',
    'Other',
  ];
  List<IconData> causeIcons = [
    Icons.work,
    Icons.family_restroom,
    Icons.health_and_safety,
    Icons.attach_money,
    Icons.add_circle_outline,
  ];

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

  TextEditingController _otherController = TextEditingController();

  void _showOtherPopup(BuildContext context) {
    if (!selectedCauses.contains('Other')) {
      setState(() {
        selectedCauses.add('Other');
      });
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Please enter your custom cause',
            style: GoogleFonts.poppins(),
          ),
          content: TextField(
            controller: _otherController,
            decoration: InputDecoration(
              labelText: 'Enter custom cause',
              labelStyle: GoogleFonts.poppins(),
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_otherController.text.isNotEmpty) {
                  setState(() {
                    selectedCauses.remove('Other');
                    selectedCauses.add(_otherController.text);
                    _otherController.clear();
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: GoogleFonts.poppins(),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedCauses.remove('Other');
                });
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _otherController.dispose();
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 50),
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
                    // Existing section for selecting intensity
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
            const SizedBox(height: 43),

            // **New Section: Stress Cause Options**
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What\'s causing your mood to be so today?',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6D3670),
                  ),
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3, // Adjust this value to make buttons more rectangular
                  ),
                  itemCount: stressCauses.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onDoubleTap: () {
                        setState(() {
                          if (selectedCauses.contains(stressCauses[index])) {
                            selectedCauses.remove(stressCauses[index]);
                          }
                        });
                      },
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedCauses.contains(stressCauses[index])
                              ? Color.fromARGB(255, 204, 163, 199) // Light beige when selected
                              : Color.fromARGB(255, 238, 204, 224), // Very light lavender when not selected
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Smaller border radius
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Smaller padding
                          elevation: selectedCauses.contains(stressCauses[index]) ? 2 : 1,
                        ),
                        onPressed: () {
                          if (stressCauses[index] == 'Other') {
                            _showOtherPopup(context);
                          } else {
                            setState(() {
                              if (!selectedCauses.contains(stressCauses[index])) {
                                selectedCauses.add(stressCauses[index]);
                              }
                            });
                          }
                        },
                        onHover: (isHovered) {
                          setState(() {
                            // You can add hover state handling here if needed
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              causeIcons[index],
                              size: 24, // Smaller icon size
                              color: const Color.fromARGB(255, 173, 47, 108), // Dark pinkish color
                            ),
                            const SizedBox(height: 4), // Reduced spacing
                            Text(
                              stressCauses[index],
                              style: GoogleFonts.poppins(
                                color: const Color.fromARGB(255, 173, 47, 108), // Dark pinkish color
                                fontSize: 13, // Smaller text size
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),

            // **New Section: Selected Causes**
            if (selectedCauses.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Causes:',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6D3670),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: selectedCauses.map((cause) {
                      return Chip(
                        label: Text(
                          cause,
                          style: GoogleFonts.poppins(
                            color: Color(0xFF6D3670),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: const Color(0xFFE8D5F0), // Lighter lavender
                        side: const BorderSide(color: Color(0xFFD5B4E3), width: 1), // Subtle border
                        deleteIcon: Icon(Icons.close, size: 16, color: Color(0xFF6D3670)),
                        onDeleted: () {
                          setState(() {
                            selectedCauses.remove(cause);
                          });
                        },
                        elevation: 1,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      );
                    }).toList(),
                  ),
                ],
              ),
            const SizedBox(height: 30),

            // **Continue Button**
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
                        builder: (context) => MoodInsightsPage(
                          moodLabel: widget.moodLabel,
                          moodEmoji: widget.moodEmoji,
                          moodIntensity: selectedIntensity,
                          selectedCauses: selectedCauses,
                        ),
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
                            ? [Color(0xFFD6C7A6), Color(0xFFE5DAC3)] // Lighter warm beige on hover
                            : [Color(0xFFCBB994), Color(0xFFCBB994)], // Same as login page button
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFCBB994).withOpacity(isHovering ? 0.5 : 0.3),
                          blurRadius: isHovering ? 16 : 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "Continue →",
                        style: GoogleFonts.poppins(
                          color: Colors.black, // Same as login page button text
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
      ),
    );
  }
}

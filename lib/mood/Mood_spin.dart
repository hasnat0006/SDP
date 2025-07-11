import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'p_dashboard.dart';
import 'Mood_intensity.dart';


class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  final List<Map<String, dynamic>> moods = [
    {"label": "Angry", "emoji": "😠", "color": const Color.fromARGB(255, 221, 87, 82)},
    {"label": "Sad", "emoji": "🙁", "color": const Color.fromARGB(255, 238, 145, 64)},
    {"label": "Stressed", "emoji": "😣", "color": const Color(0xFFF6D55C)},
    {"label": "Happy", "emoji": "😊", "color": const Color.fromARGB(255, 168, 197, 168)},
    {"label": "Excited", "emoji": "🥳", "color": const Color.fromARGB(255, 191, 174, 225)},
  ];

  int selectedIndex = 2;
  double angle = 0.0;
  double segmentAngle = 2 * pi / 5;
  Offset? startSwipe;
  bool isHovering = false;

  void _snapToClosestMood() {
    final adjustedAngle = (angle + 2 * pi) % (2 * pi);
    final topAngle = (3 * pi / 2);
    final index = ((adjustedAngle + segmentAngle / 2 - topAngle) ~/ segmentAngle) % moods.length;
    setState(() {
      selectedIndex = index;
      angle = (index * segmentAngle + 2 * pi - topAngle) % (2 * pi);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentMood = moods[selectedIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F4),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.brown),
                      onPressed: () {
                        // Navigator.pushReplacement(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => const P_Dashboard()),
                        // );
                      },
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Mood Tracker',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown.shade700,
                      ),
                    ),
                    const Spacer(),
                    MouseRegion(
                      onEnter: (_) => setState(() => isHovering = true),
                      onExit: (_) => setState(() => isHovering = false),
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MoodIntensityPage(
        moodLabel: moods[selectedIndex]['label'],
        moodEmoji: moods[selectedIndex]['emoji'],
      ),
    ),
  );
},

                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isHovering ? const Color.fromARGB(255, 119, 83, 71) : const Color.fromARGB(255, 165, 123, 109),
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
                  ],
                ),
              ),
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
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                child: Text(
                  currentMood["emoji"],
                  key: ValueKey(currentMood["emoji"]),
                  style: const TextStyle(fontSize: 60),
                ),
              ),
              const Spacer(),
              Listener(
                onPointerDown: (event) => startSwipe = event.position,
                onPointerMove: (event) {
                  if (startSwipe == null) return;
                  final dx = event.position.dx - startSwipe!.dx;
                  setState(() {
                    angle = (angle - dx * 0.005) % (2 * pi);
                  });
                  startSwipe = event.position;
                },
                onPointerUp: (_) => _snapToClosestMood(),
                child: SizedBox(
                  height: 420,
                  width: double.infinity,
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      heightFactor: 0.55,
                      child: CustomPaint(
                        size: const Size(double.infinity, 400),
                        painter: LabeledArcPainter(
                          moods: moods,
                          angle: angle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
          Positioned(
            top: 360,
            left: MediaQuery.of(context).size.width / 2 - 22,
            child: Container(
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
              child: const Icon(Icons.expand_more, size: 28, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}

class LabeledArcPainter extends CustomPainter {
  final List<Map<String, dynamic>> moods;
  final double angle;

  LabeledArcPainter({required this.moods, required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width * 0.52;
    final arcThickness = 120.0;
    final sweepPerMood = 2 * pi / moods.length;
    final arcRect = Rect.fromCircle(center: center, radius: radius);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final hoverGlow = Paint()
      ..shader = RadialGradient(
        center: Alignment.topCenter,
        radius: 1.0,
        colors: [
          const Color(0xFFDCD4F5).withOpacity(0.2),
          const Color(0xFFDCD4F5).withOpacity(0.05),
          Colors.transparent,
        ],
        stops: const [0.2, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius + arcThickness * 0.8));

    canvas.drawCircle(center, radius + arcThickness * 0.8, hoverGlow);

    for (int i = 0; i < moods.length; i++) {
      final mood = moods[i];
      final baseColor = mood["color"] as Color;
      final rotatedStart = (i * sweepPerMood) - angle;
      final labelAngle = rotatedStart + sweepPerMood / 2;

      final arcPaint = Paint()
  ..shader = SweepGradient(
    startAngle: rotatedStart,
    endAngle: rotatedStart + sweepPerMood,
    tileMode: TileMode.clamp,
    colors: [
      baseColor.withOpacity(0.45),  // Shadow edge
      baseColor.withOpacity(0.95),  // Mid-tone
      baseColor,                    // Full color
      baseColor.withOpacity(0.9),  // Highlight sweep
      baseColor.withOpacity(0.45), // Shadow again
    ],
    stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
    transform: GradientRotation(rotatedStart),
  ).createShader(arcRect)
  ..style = PaintingStyle.stroke
  ..strokeWidth = arcThickness
  ..strokeCap = StrokeCap.round; // Use round caps for a softer 3D feel

      canvas.drawArc(arcRect, rotatedStart, sweepPerMood, false, arcPaint);

      final emojiOffset = Offset(
        center.dx + (radius - arcThickness / 2 + 12) * cos(labelAngle),
        center.dy + (radius - arcThickness / 2 + 12) * sin(labelAngle),
      );

      textPainter.text = TextSpan(
        text: mood['emoji'],
        style: const TextStyle(fontSize: 28),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        emojiOffset - Offset(textPainter.width / 2, textPainter.height / 2),
      );

      final labelOffset = Offset(
        center.dx + (radius - arcThickness / 2 + 38) * cos(labelAngle),
        center.dy + (radius - arcThickness / 2 + 38) * sin(labelAngle),
      );

      canvas.save();
      canvas.translate(labelOffset.dx, labelOffset.dy);
      canvas.rotate(labelAngle + pi / 2);
      textPainter.text = TextSpan(
        text: mood['label'],
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.brown.shade800,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

import 'dart:math';
import 'package:flutter/material.dart';

class MoodSpinner extends StatefulWidget {
  final double size;
  final Function(String)? onMoodChanged;

  const MoodSpinner({
    Key? key,
    this.size = 280,
    this.onMoodChanged,
  }) : super(key: key);

  @override
  State<MoodSpinner> createState() => _MoodSpinnerState();
}

class _MoodSpinnerState extends State<MoodSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _currentAngle = 90.0; // Start at middle (neutral)
  String _currentMood = "I Feel Neutral.";

  final List<MoodSection> _moodSections = [
    MoodSection(
      color: Color(0xFF8B5E3C), // Brown
      startAngle: 0,
      sweepAngle: 36,
      emoji: "😤",
      mood: "I Feel Angry.",
    ),
    MoodSection(
      color: Color(0xFFF97316), // Orange
      startAngle: 36,
      sweepAngle: 36,
      emoji: "😔",
      mood: "I Feel Frustrated.",
    ),
    MoodSection(
      color: Color(0xFFFACC15), // Yellow
      startAngle: 72,
      sweepAngle: 36,
      emoji: "☹️",
      mood: "I Feel Sad.",
    ),
    MoodSection(
      color: Color(0xFFA3E635), // Light Green
      startAngle: 108,
      sweepAngle: 36,
      emoji: "😊",
      mood: "I Feel Good.",
    ),
    MoodSection(
      color: Color(0xFFC4B5FD), // Purple
      startAngle: 144,
      sweepAngle: 36,
      emoji: "😄",
      mood: "I Feel Happy.",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: _currentAngle,
      end: _currentAngle,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateMood(double angle) {
    for (var section in _moodSections) {
      if (angle >= section.startAngle && angle <= section.startAngle + section.sweepAngle) {
        if (_currentMood != section.mood) {
          setState(() {
            _currentMood = section.mood;
          });
          widget.onMoodChanged?.call(section.mood);
        }
        break;
      }
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    
    final centerX = widget.size / 2;
    final centerY = widget.size / 2 + 20;
    
    final dx = localPosition.dx - centerX;
    final dy = localPosition.dy - centerY;
    
    if (dy > 0) return; // Only allow interaction in the upper half
    
    final radians = atan2(-dy, dx);
    double degrees = radians * (180 / pi);
    
    // Normalize angle to 0-180 range
    if (degrees < 0) degrees += 180;
    degrees = degrees.clamp(0.0, 180.0);
    
    setState(() {
      _currentAngle = degrees;
    });
    
    _updateMood(degrees);
  }

  void _handlePanEnd(DragEndDetails details) {
    // Snap to nearest section center
    final sectionWidth = 180.0 / _moodSections.length;
    final nearestSectionIndex = (_currentAngle / sectionWidth).round();
    final snappedAngle = nearestSectionIndex * sectionWidth + sectionWidth / 2;
    
    _animation = Tween<double>(
      begin: _currentAngle,
      end: snappedAngle.clamp(0.0, 180.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.reset();
    _animationController.forward().then((_) {
      setState(() {
        _currentAngle = snappedAngle.clamp(0.0, 180.0);
      });
      _updateMood(_currentAngle);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "How would you\ndescribe your mood\ntoday?",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 40),
        Text(
          _currentMood,
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[600],
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 20),
        // Current mood emoji display
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: _getCurrentMoodColor(),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              _getCurrentMoodEmoji(),
              style: TextStyle(fontSize: 40),
            ),
          ),
        ),
        SizedBox(height: 30),
        // Mood Spinner
        GestureDetector(
          onPanUpdate: _handlePanUpdate,
          onPanEnd: _handlePanEnd,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final angle = _animation.isAnimating ? _animation.value : _currentAngle;
              return CustomPaint(
                size: Size(widget.size, widget.size / 2 + 40),
                painter: MoodSpinnerPainter(
                  angle: angle,
                  moodSections: _moodSections,
                ),
              );
            },
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Color _getCurrentMoodColor() {
    for (var section in _moodSections) {
      if (_currentAngle >= section.startAngle && 
          _currentAngle <= section.startAngle + section.sweepAngle) {
        return section.color;
      }
    }
    return Color(0xFFFACC15); // Default yellow
  }

  String _getCurrentMoodEmoji() {
    for (var section in _moodSections) {
      if (_currentAngle >= section.startAngle && 
          _currentAngle <= section.startAngle + section.sweepAngle) {
        return section.emoji;
      }
    }
    return "😐"; // Default neutral
  }
}

class MoodSection {
  final Color color;
  final double startAngle;
  final double sweepAngle;
  final String emoji;
  final String mood;

  MoodSection({
    required this.color,
    required this.startAngle,
    required this.sweepAngle,
    required this.emoji,
    required this.mood,
  });
}

class MoodSpinnerPainter extends CustomPainter {
  final double angle;
  final List<MoodSection> moodSections;

  MoodSpinnerPainter({
    required this.angle,
    required this.moodSections,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 20);
    final radius = size.width / 2 - 20;
    
    // Draw mood sections
    final sectionPaint = Paint()..style = PaintingStyle.fill;
    
    for (var section in moodSections) {
      sectionPaint.color = section.color;
      
      final startAngleRad = (section.startAngle + 180) * pi / 180;
      final sweepAngleRad = section.sweepAngle * pi / 180;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngleRad,
        sweepAngleRad,
        true,
        sectionPaint,
      );
      
      // Draw emoji on each section
      final textPainter = TextPainter(
        text: TextSpan(
          text: section.emoji,
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      
      final emojiAngleRad = startAngleRad + sweepAngleRad / 2;
      final emojiRadius = radius * 0.7;
      final emojiOffset = Offset(
        center.dx + cos(emojiAngleRad) * emojiRadius - textPainter.width / 2,
        center.dy + sin(emojiAngleRad) * emojiRadius - textPainter.height / 2,
      );
      
      textPainter.paint(canvas, emojiOffset);
    }
    
    // Draw needle
    final needlePaint = Paint()
      ..color = Color(0xFF8B5E3C)
      ..style = PaintingStyle.fill;
    
    final needleAngleRad = (angle + 180) * pi / 180;
    final needleLength = radius - 10;
    
    final needleEnd = Offset(
      center.dx + cos(needleAngleRad) * needleLength,
      center.dy + sin(needleAngleRad) * needleLength,
    );
    
    canvas.drawLine(center, needleEnd, needlePaint..strokeWidth = 4);
    
    // Draw needle knob
    canvas.drawCircle(
      center,
      12,
      Paint()..color = Color(0xFF8B5E3C),
    );
    
    canvas.drawCircle(
      center,
      8,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

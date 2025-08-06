import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vector_math/vector_math.dart' as vmath;

class MoodSelector extends HookWidget {
  final double size;

  const MoodSelector({super.key, this.size = 300});

  @override
  Widget build(BuildContext context) {
    final angle = useState(180.0); // Start at middle (sad)

    return GestureDetector(
      onPanUpdate: (details) {
        final dx = details.localPosition.dx - size / 2;
        final dy = details.localPosition.dy - size;
        final radians = atan2(dy, dx);
        double degrees = radians * (180 / pi) + 90;

        degrees = degrees.clamp(0, 180);
        angle.value = degrees;
      },
      onPanEnd: (_) {
        final snapped = (angle.value / 36).round() * 36; // Snap to 5 sections
        angle.value = snapped.toDouble();
      },
      child: SizedBox(
        width: size,
        height: size / 2 + 50,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CustomPaint(
              size: Size(size, size / 2),
              painter: MoodArcPainter(angle: angle.value),
            ),
            // Needle
            Transform.rotate(
              angle: vmath.radians(angle.value - 90),
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 6,
                height: size / 2,
                decoration: BoxDecoration(
                  color: Colors.brown.shade800,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            // Needle Knob
            Positioned(
              bottom: 0,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.brown,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}


class MoodArcPainter extends CustomPainter {
  final double angle;
  MoodArcPainter({required this.angle});

  final moods = [
    {'color': Color(0xFF8B5E3C), 'emoji': '😐'},
    {'color': Color(0xFFF97316), 'emoji': '🙁'},
    {'color': Color(0xFFFACC15), 'emoji': '☹️'},
    {'color': Color(0xFFA3E635), 'emoji': '😊'},
    {'color': Color(0xFFC4B5FD), 'emoji': '😄'},
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    final sweepAngle = pi / moods.length;

    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < moods.length; i++) {
      paint.color = moods[i]['color'] as Color;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        pi + i * sweepAngle,
        sweepAngle,
        true,
        paint,
      );

      // Emoji
      final textPainter = TextPainter(
        text: TextSpan(
          text: moods[i]['emoji'] as String,
          style: TextStyle(fontSize: 28),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final theta = pi + (i + 0.5) * sweepAngle;
      final emojiOffset = Offset(
        center.dx + cos(theta) * radius * 0.6 - textPainter.width / 2,
        center.dy + sin(theta) * radius * 0.6 - textPainter.height / 2,
      );

      textPainter.paint(canvas, emojiOffset);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

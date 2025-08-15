import 'package:flutter/material.dart';
import 'dart:math' as math;

class ArcGauge extends StatefulWidget {
  final double outerRadius;
  final double innerRadius;
  final List<Color>? segmentColors;
  final Function(double)? onRotationChanged;
  final Function(int, String)? onSegmentSelected;

  const ArcGauge({
    super.key,
    this.outerRadius = 200,
    this.innerRadius = 140,
    this.segmentColors,
    this.onRotationChanged,
    this.onSegmentSelected,
  });

  // Combined segment data with emoji, label, and color
  static const List<Map<String, dynamic>> segments = [
    {
      'emoji': '😟',
      'label': 'Stressed',
      'color': Color.fromARGB(246, 213, 92, 1),
    },
    {'emoji': '😢', 'label': 'Sad', 'color': Color.fromARGB(172, 192, 174, 81)},
    {
      'emoji': '😊',
      'label': 'Happy',
      'color': Color.fromARGB(255, 162, 206, 162),
    },
    {'emoji': '😠', 'label': 'Angry', 'color': Color.fromARGB(255, 221, 87, 82)},
    {
      'emoji': '😃',
      'label': 'Excited',
      'color': Color.fromARGB(255, 191, 174, 225),
    },
    {
      'emoji': '😟',
      'label': 'Stressed',
      'color': Color.fromARGB(246, 213, 92, 1),
    },
    {'emoji': '😢', 'label': 'Sad', 'color': Color.fromARGB(172, 192, 174, 81)},
    {
      'emoji': '😊',
      'label': 'Happy',
      'color': Color.fromARGB(255, 162, 206, 162),
    },
    {'emoji': '😠', 'label': 'Angry', 'color': Color.fromARGB(255, 221, 87, 821)},
    {
      'emoji': '😃',
      'label': 'Excited',
      'color': Color.fromARGB(255, 191, 174, 225),
    },
  ];

  @override
  State<ArcGauge> createState() => _ArcGaugeState();
}

class _ArcGaugeState extends State<ArcGauge> {
  double _rotationAngle = 0.0;
  double _startAngle = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        final center = Offset(widget.outerRadius, widget.outerRadius);
        final touchPosition = details.localPosition;
        _startAngle = _calculateAngle(center, touchPosition) - _rotationAngle;
      },
      onPanUpdate: (details) {
        final center = Offset(widget.outerRadius, widget.outerRadius);
        final touchPosition = details.localPosition;
        final currentAngle = _calculateAngle(center, touchPosition);

        setState(() {
          _rotationAngle = currentAngle - _startAngle;
          // Normalize angle to 0-360 degrees
          _rotationAngle = _rotationAngle % (2 * math.pi);
          if (_rotationAngle < 0) _rotationAngle += 2 * math.pi;
        });

        // Convert to degrees and call callback
        final degrees = _rotationAngle * 180 / math.pi;

        // Calculate which segment the fixed line (at 90°) is pointing to
        final selectedSegment = _calculateSelectedSegment();
        final segmentlabel = ArcGauge.segments[selectedSegment]['label']!;

        widget.onRotationChanged?.call(degrees);
        widget.onSegmentSelected?.call(selectedSegment, segmentlabel);
      },
      child: CustomPaint(
        size: Size(widget.outerRadius * 2, widget.outerRadius),
        painter: ArcGaugePainter(
          outerRadius: widget.outerRadius,
          innerRadius: widget.innerRadius,
          rotationAngle: _rotationAngle,
        ),
      ),
    );
  }

  double _calculateAngle(Offset center, Offset point) {
    final dx = point.dx - center.dx;
    final dy = point.dy - center.dy;
    return math.atan2(dy, dx);
  }

  int _calculateSelectedSegment() {
    // Fixed line is at 90° (π/2 radians), pointing upward
    // We need to find which segment this line intersects after rotation
    const fixedLineAngle = -math.pi / 2; // -90° (upward in canvas coordinates)

    // Calculate the relative angle of the fixed line with respect to the rotated gauge
    double relativeAngle = fixedLineAngle - _rotationAngle;

    // Normalize to 0-2π range
    relativeAngle = relativeAngle % (2 * math.pi);
    if (relativeAngle < 0) relativeAngle += 2 * math.pi;

    // Calculate which segment this angle falls into
    const segmentAngle = 2 * math.pi / 10; // 360° / 10 segments
    final segmentIndex = (relativeAngle / segmentAngle).floor();

    return segmentIndex.clamp(0, ArcGauge.segments.length - 1);
  }
}

class ArcGaugePainter extends CustomPainter {
  final double outerRadius;
  final double innerRadius;
  final double rotationAngle;

  ArcGaugePainter({
    required this.outerRadius,
    required this.innerRadius,
    this.rotationAngle = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);

     // Lavender shadow glow effect behind the arc
   final hoverGlow = Paint()
  ..shader = RadialGradient(
    center: Alignment(0.0, 0.3), // Move center downward slightly (0.3)
    radius: 0.8,  // Adjust radius for a smaller glow
       colors: [
      const Color.fromARGB(255, 174, 153, 211).withOpacity(0.3),  // Increased opacity for more visibility
      const Color.fromARGB(255, 171, 153, 206).withOpacity(0.2),  // Fades out softly
      const Color.fromARGB(0, 228, 216, 235),  // Transparent center
    ],
    stops: const [0.2, 0.6, 1.0],
  ).createShader(
    Rect.fromCircle(
      center: center,
      radius: outerRadius + outerRadius * 0.6,  // Adjust radius for a smaller glow
    ),
  );

// Apply the lavender glow background
canvas.drawCircle(center, outerRadius + outerRadius * 0.8, hoverGlow);  // Use outerRadius here


    // Paint for the arc segments
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = outerRadius - innerRadius
      ..strokeCap = StrokeCap.butt;

    // Draw segments but only show the upper 180° (from π to 2π, which appears as 0° to 180° visually)
    const totalAngle = 2 * math.pi; // 360 degrees in radians
    final segmentAngle = totalAngle / ArcGauge.segments.length;

    for (int i = 0; i < ArcGauge.segments.length; i++) {
      paint.color = ArcGauge.segments[i]['color']!.withOpacity(0.5); // Set desired opacity


      // Calculate start angle for each segment with rotation
      final startAngle = (i * segmentAngle) + rotationAngle;

      // Draw all segments, but they will be clipped by the canvas size to show only upper 180°
      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: (outerRadius + innerRadius) / 2, // Middle radius for stroke
        ),
        startAngle,
        segmentAngle,
        false,
        paint,
      );

      // Draw emoji at the center of each segment
      final middleAngle = startAngle + (segmentAngle / 2);
      final emojiRadius = (outerRadius + innerRadius) / 2; // Same as arc radius
      final emojiX = center.dx + emojiRadius * math.cos(middleAngle);
      final emojiY = center.dy + emojiRadius * math.sin(middleAngle);

      // Only draw emoji if it's in the visible area (roughly upper 180°)
      if (emojiY <= center.dy) {
        // Draw the emoji
        final emojiPainter = TextPainter(
          text: TextSpan(
            text: ArcGauge.segments[i]['emoji']!,
            style: const TextStyle(fontSize: 24, color: Colors.white),
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );

        emojiPainter.layout();

        // Center the emoji at the calculated position
        final emojiOffset = Offset(
          emojiX - emojiPainter.width / 2,
          emojiY - emojiPainter.height / 2,
        );

        emojiPainter.paint(canvas, emojiOffset);

        // Draw the emoji label below the emoji
        final labelPainter = TextPainter(
          text: TextSpan(
            text: ArcGauge.segments[i]['label']!,
            style: const TextStyle(
              fontSize: 12,
              color: Color.fromARGB(255, 14, 13, 13),
              fontWeight: FontWeight.bold,
            ),
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );

        labelPainter.layout();

        // Position the label slightly below the emoji
        final labelOffset = Offset(
          emojiX - labelPainter.width / 2,
          emojiY + 15, // 15 pixels below emoji center
        );

        labelPainter.paint(canvas, labelOffset);
      }
    }

    // Draw a FIXED line indicator at 90 degrees (pointing upward)
    final linePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // Fixed line at 90 degrees (π/2 radians) - pointing upward
    const fixedAngle = -math.pi / 2; // -90° (upward in canvas coordinates)
    final lineLength = outerRadius - 10; // Slightly shorter than outer radius
    final lineEndX = center.dx + lineLength * math.cos(fixedAngle);
    final lineEndY = center.dy + lineLength * math.sin(fixedAngle);
    final lineEnd = Offset(lineEndX, lineEndY);

    // Draw fixed line from center pointing upward
    canvas.drawLine(center, lineEnd, linePaint);

    // Draw the circular pointer at the center of the circle
    final pointerPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    const pointerRadius = 8.0;
    canvas.drawCircle(center, pointerRadius, pointerPaint);
  }

  @override
  bool shouldRepaint(ArcGaugePainter oldDelegate) {
    return oldDelegate.outerRadius != outerRadius ||
        oldDelegate.innerRadius != innerRadius ||
        oldDelegate.rotationAngle != rotationAngle;
  }
}

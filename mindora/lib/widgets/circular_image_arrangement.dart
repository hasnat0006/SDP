import 'package:flutter/material.dart';
import 'dart:math' as math;

class CircularImageArrangement extends StatefulWidget {
  final String imagePath;
  final double radius;
  final int imageCount;
  final double imageSize;
  final Duration animationDuration;

  const CircularImageArrangement({
    super.key,
    required this.imagePath,
    this.radius = 200,
    this.imageCount = 5,
    this.imageSize = 50,
    this.animationDuration = const Duration(seconds: 10),
  });

  @override
  State<CircularImageArrangement> createState() =>
      _CircularImageArrangementState();
}

class _CircularImageArrangementState extends State<CircularImageArrangement>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat(); // Continuous rotation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (widget.radius * 2) + widget.imageSize,
      height: widget.radius + widget.imageSize,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: List.generate(widget.imageCount, (index) {
              // Calculate angle for each image (180 degrees / 5 images)
              double baseAngle = (math.pi / (widget.imageCount - 1)) * index;
              // Add rotation animation
              double rotationAngle = _controller.value * 2 * math.pi;
              double totalAngle = baseAngle + rotationAngle;

              // Calculate position
              double x = widget.radius * math.cos(totalAngle);
              double y = widget.radius * math.sin(totalAngle);

              return Transform.translate(
                offset: Offset(x, y),
                child: Container(
                  width: widget.imageSize,
                  height: widget.imageSize,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    widget.imagePath,
                    fit: BoxFit.cover,
                    width: widget.imageSize,
                    height: widget.imageSize,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

import 'dart:math';
import 'package:client/navbar/navbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/dashboard/p_dashboard.dart';

class Sleepinput extends StatefulWidget {
  const Sleepinput({super.key});

  @override
  State<Sleepinput> createState() => _SleepinputState();
}

class _SleepinputState extends State<Sleepinput> with TickerProviderStateMixin {
  int _sleepHours = 0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 211, 154, 213),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Sleep Tracker",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          // ☁️ Cloud background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/cloud_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ✨ Scattered stars
          ...List.generate(100, (index) {
            final random = Random(index);
            final top = random.nextDouble() * screenSize.height;
            final left = random.nextDouble() * screenSize.width;
            final delay = Duration(milliseconds: 300 * index);
            final size = 12.0 + random.nextInt(10); // 12 to 21 px

            return Positioned(
              top: top,
              left: left,
              child: _TwinklingStar(
                assetPath: 'assets/star.png',
                delay: delay,
                size: size,
              ),
            );
          }),

          // 🌙 Main content
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 211, 154, 213),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        spreadRadius: 1,
                        color: const Color.fromARGB(120, 211, 154, 213),
                      ),
                    ],
                  ),
                  child: Text(
                    "$_sleepHours hrs",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Most adults need 7–9 hours for optimal rest.",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Center(
                    child: RotatedBox(
                      quarterTurns: -1,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 12,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 24,
                          ),
                          trackHeight: 6,
                          activeTrackColor: const Color.fromARGB(
                            255,
                            211,
                            154,
                            213,
                          ),
                          inactiveTrackColor: const Color.fromARGB(
                            80,
                            211,
                            154,
                            213,
                          ),
                          thumbColor: const Color.fromARGB(255, 211, 154, 213),
                          overlayColor: const Color.fromARGB(
                            120,
                            211,
                            154,
                            213,
                          ),
                          trackShape: const RoundedRectSliderTrackShape(),
                        ),
                        child: Slider(
                          value: _sleepHours.toDouble(),
                          min: 0,
                          max: 18,
                          divisions: 18,
                          label: '$_sleepHours hrs',
                          onChanged: (value) {
                            setState(() {
                              _sleepHours = value.toInt();
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "You have slept for $_sleepHours hours 😴",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: const Color.fromARGB(255, 70, 70, 70),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MainNavBar()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 211, 154, 213),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "Confirm",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ⭐️ Twinkling star widget
class _TwinklingStar extends StatefulWidget {
  final String assetPath;
  final Duration delay;
  final double size;

  const _TwinklingStar({
    super.key,
    required this.assetPath,
    this.delay = Duration.zero,
    this.size = 18.0,
  });

  @override
  State<_TwinklingStar> createState() => _TwinklingStarState();
}

class _TwinklingStarState extends State<_TwinklingStar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.repeat(reverse: true);
    });

    _scale = Tween<double>(
      begin: 0.9,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _opacity = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.scale(
            scale: _scale.value,
            child: Image.asset(
              widget.assetPath,
              width: widget.size,
              height: widget.size,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

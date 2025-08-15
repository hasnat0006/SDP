import 'dart:math';
import 'package:client/navbar/navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'sleepinput.dart';

class Sleeptracker extends StatefulWidget {
  const Sleeptracker({super.key});

  @override
  State<Sleeptracker> createState() => _SleeptrackerState();
}

class _SleeptrackerState extends State<Sleeptracker> {
  static const MethodChannel unlockChannel = MethodChannel(
    'com.yourapp/unlock',
  );

  DateTime? sleepStartTime;
  DateTime? wakeTime;
  Duration? sleepDuration;

  @override
  void initState() {
    super.initState();
    _inferSleepStart();
    _initUnlockListener();
  }

  void _inferSleepStart() {
    final now = DateTime.now();
    if (now.hour >= 23 || now.hour <= 5) {
      sleepStartTime = DateTime(now.year, now.month, now.day, 23, 0);
    }
  }

  void _initUnlockListener() {
    unlockChannel.setMethodCallHandler((call) async {
      if (call.method == 'onUnlock') {
        wakeTime = DateTime.now();
        if (sleepStartTime != null) {
          sleepDuration = wakeTime!.difference(sleepStartTime!);
          _showSleepSummary();
          sleepStartTime = null;
        }
      }
    });
  }

  void _showSleepSummary() {
    final hours = sleepDuration!.inHours;
    final minutes = sleepDuration!.inMinutes % 60;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Good Morning 🌼',
          style: GoogleFonts.montserrat(fontSize: 20),
        ),
        content: Text(
          'You slept for $hours hrs and $minutes mins\n'
          'From ${DateFormat.jm().format(sleepStartTime!)} to ${DateFormat.jm().format(wakeTime!)}',
          style: GoogleFonts.roboto(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 211, 154, 213),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Container(color: const Color.fromARGB(255, 247, 244, 242)),

          // ⭐ Twinkling Stars
          ...List.generate(50, (index) {
            final random = Random(index);
            final top =
                random.nextDouble() * MediaQuery.of(context).size.height;
            final left =
                random.nextDouble() * MediaQuery.of(context).size.width;
            final delay = Duration(milliseconds: 300 * index);
            final size = 12.0 + random.nextInt(10);

            return Positioned(
              top: top,
              left: left,
              child: TwinklingStar(
                assetPath: 'assets/star.png',
                delay: delay,
                size: size,
              ),
            );
          }),

          // 🐱 Cat at bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 0.2),
              child: Image.asset(
                'assets/cat2.png',
                width: 320,
                height: 320,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // 🌙 Sleep Confirmation Prompt
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Your screen was off from 11:00 pm to 6:00 am. Were you sleeping?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainNavBar(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          211,
                          154,
                          213,
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      child: const Text(
                        "Yes",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Sleepinput()),
                        );
                      }, // Optional “No” action
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          211,
                          154,
                          213,
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      child: const Text(
                        "No",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 🌠 Star Widget with gentle pulsing
class TwinklingStar extends StatefulWidget {
  final String assetPath;
  final Duration delay;
  final double size;

  const TwinklingStar({
    Key? key,
    required this.assetPath,
    this.delay = Duration.zero,
    this.size = 18.0,
  }) : super(key: key);

  @override
  State<TwinklingStar> createState() => _TwinklingStarState();
}

class _TwinklingStarState extends State<TwinklingStar>
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
      builder: (_, __) => Opacity(
        opacity: _opacity.value,
        child: Transform.scale(
          scale: _scale.value,
          child: Image.asset(
            widget.assetPath,
            width: widget.size,
            height: widget.size,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

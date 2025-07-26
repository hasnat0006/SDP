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
      // You can refine this later with actual inactivity detection
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
          sleepStartTime = null; // Reset cycle
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
            Navigator.pop(context); // Pops current screen off the stack
          },
        ),
      ),
      body: Stack(
        children: [
          Container(color: const Color.fromARGB(255, 247, 244, 242)),

          //   Clouds scattered across the background
          // Positioned(
          //   top: 50,
          //   left: 30,
          //   child: Image.asset('assets/cloud3.png', width: 100),
          // ),
          // Positioned(
          //   top: 150,
          //   right: 20,
          //   child: Image.asset('assets/cloud3.png', width: 100),
          // ),
          // Positioned(
          //   bottom: 120,
          //   left: 60,
          //   child: Image.asset('assets/cloud3.png', width: 100),
          // ),
          // Positioned(
          //   bottom: 30,
          //   right: 10,
          //   child: Image.asset('assets/cloud3.png', width: 90),
          // ),

          // // Cat image at bottom center
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
          SizedBox(height: 12),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Your screen was off from ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Sleepinput()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 211, 154, 213),
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      child: Text(
                        "Yes",
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 211, 154, 213),
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      child: Text(
                        "No",
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }
}

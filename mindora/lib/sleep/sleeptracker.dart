import 'dart:async';
import 'dart:math';
import 'package:client/navbar/navbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:screen_state/screen_state.dart';
import 'sleepinput.dart';
import 'backend.dart';

class Sleeptracker extends StatefulWidget {
  final String userId;
  const Sleeptracker({super.key, required this.userId});

  @override
  State<Sleeptracker> createState() => _SleeptrackerState();
}

class _SleeptrackerState extends State<Sleeptracker> {
  late Screen _screen;
  StreamSubscription<ScreenStateEvent>? _sub;

  DateTime? _lastScreenOff;
  DateTime? _sleepStartTime;
  DateTime? _wakeTime;
  Duration _totalScreenOff = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    _screen = Screen();

    try {
      _sub = _screen.screenStateStream.listen((event) {
        final now = DateTime.now();

        if (event == ScreenStateEvent.SCREEN_OFF) {
          // First-off marks sleep start
          if (_sleepStartTime == null) {
            _sleepStartTime = now;
          }
          _lastScreenOff = now;
        }

        if (event == ScreenStateEvent.SCREEN_ON && _lastScreenOff != null) {
          _wakeTime = now;

          final offDuration = now.difference(_lastScreenOff!);
          setState(() {
            _totalScreenOff += offDuration;
            _lastScreenOff = null;
          });

          debugPrint('$offDuration');
        }

        final hours = _totalScreenOff.inHours;
      });
    } catch (e) {
      debugPrint('Failed to listen to screen events: $e');
    }
  }

  Future<void> sleepConfirm({required int hours}) async {
    try {
      // 1. Capture now
      final now = DateTime.now();

      // 2a. If you just want ISO 8601:

      // 2b. Or use intl for a 'yyyy-MM-dd' string:
      final formattedDate = DateFormat('yyyy-MM-dd').format(now);

      // 3. Build your payload

      // 4. Send to backend
      await sleepInput(hours: hours, date: now, userId: widget.userId);
      await _showSuccessPopup();
    } catch (error) {
      // surfacing errors to console or UI
      print('Error recording sleep: $error');
      rethrow;
    }
  }

  Future<void> _showSuccessPopup() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Success!',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Your sleep hours have been recorded successfully.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Close the popup
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainNavBar(),
                  ), // Navigate to the main page
                );
              },
              child: Text(
                'Close',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.purple[700],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  String _formatTime(DateTime? dt) {
    return dt != null ? DateFormat.jm().format(dt) : '--:--';
  }

  @override
  Widget build(BuildContext context) {
    final hours = _totalScreenOff.inHours;
    final minutes = _totalScreenOff.inMinutes % 60;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 211, 154, 213),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Sleep Tracker', style: GoogleFonts.montserrat()),
      ),
      body: Stack(
        children: [
          Container(color: Color.fromARGB(255, 247, 244, 242)),

          // Twinkling stars, cat, etc. (unchanged)…

          // Centered sleep summary
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'You were sleeping from\n'
                  '${_formatTime(_sleepStartTime)} to ${_formatTime(_wakeTime)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Total hours slept: $hours h $minutes m',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        sleepConfirm(hours: hours); // Show success pop-up
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 211, 154, 213),
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      child: Text("Yes"),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Sleepinput(userId: widget.userId),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 211, 154, 213),
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      child: Text("No"),
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

// TwinklingStar widget stays as you had it…

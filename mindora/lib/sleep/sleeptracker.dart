import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:screen_state/screen_state.dart';
import 'package:client/navbar/navbar.dart';
import 'sleepinput.dart';
import './backend.dart';

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

  DateTime? _configuredSleepTime;

  bool _hasLogged = false;

  Future<void> _loadSleepTime() async {
    // Example: fetch from API or DB
    final sleepTimeString = await fetchSleepTime(
      userId: widget.userId,
    ); // e.g., "23:00"

    final sleeptime = sleepTimeString[0];
    final parts = sleeptime.split(':');
    final now = DateTime.now();
    _configuredSleepTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    print("Sleep time");
    print(_configuredSleepTime);
  }

  @override
  void initState() {
    super.initState();
    _loadSleepTime();
    _startListening();
    _checkIfAlreadyLogged(); // Check if sleep has already been logged
  }

  // Check if the sleep data has already been logged today
  Future<void> _checkIfAlreadyLogged() async {
    final hasLogged = await hasSleepRecord(
      userId: widget.userId,
      date: DateTime.now(),
    );
    setState(() {
      _hasLogged = !hasLogged; // Set true if already logged
    });

    // If sleep is already logged, show the popup immediately after loading the page
    if (_hasLogged) {
      await _showAlreadyLoggedPopup();
    }
  }

  void _startListening() {
    _screen = Screen();

    try {
      _sub = _screen.screenStateStream.listen((event) {
        final now = DateTime.now();

        if (event == ScreenStateEvent.SCREEN_OFF) {
          // First-off marks sleep start
          if (_sleepStartTime == null && now.isAfter(_configuredSleepTime!)) {
            _sleepStartTime = now;
          }
          _lastScreenOff = now;
        }

        if (event == ScreenStateEvent.SCREEN_ON && _lastScreenOff != null) {
          if (_lastScreenOff!.isAfter(_configuredSleepTime!)) {
            _wakeTime = now;
            final offDuration = now.difference(_lastScreenOff!);
            setState(() {
              _totalScreenOff += offDuration;
              _lastScreenOff = null;
            });
          }
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
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MainNavBar()),
                  (route) =>
                      false, // Navigate to the main page and remove all previous routes
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

  Future<void> _showAlreadyLoggedPopup() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Sleep Data Already Logged',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'You have already logged your sleep data for today.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Close the popup
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MainNavBar()),
                  (route) =>
                      false, // Navigate to the main page and remove all previous routes
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
                      onPressed: () async {
                        // Proceed to log sleep data if not logged yet
                        await sleepConfirm(hours: hours);
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

import 'package:client/dashboard/p_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Sleepinput extends StatefulWidget {
  const Sleepinput({Key? key}) : super(key: key);

  @override
  State<Sleepinput> createState() => _SleepinputState();
}

class _SleepinputState extends State<Sleepinput> {
  static const MethodChannel unlockChannel = MethodChannel(
    'com.yourapp/unlock',
  );

  int _sleepHours = 0;

  @override
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

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "You have slept for $_sleepHours hours",
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      iconSize: 28,
                      color: const Color.fromARGB(255, 211, 154, 213),
                      onPressed: () {
                        setState(() {
                          if (_sleepHours > 0) _sleepHours--;
                        });
                      },
                    ),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) {
                          final parsed = int.tryParse(value);
                          if (parsed != null && parsed >= 0) {
                            setState(() {
                              _sleepHours = parsed;
                            });
                          }
                        },
                        controller: TextEditingController(text: '$_sleepHours'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      iconSize: 28,
                      color: const Color.fromARGB(255, 211, 154, 213),
                      onPressed: () {
                        setState(() {
                          _sleepHours++;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DashboardPage()),
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
                    "Confirm",
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
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

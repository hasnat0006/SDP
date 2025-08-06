import 'package:client/services/notification_service.dart';
import 'package:client/widgets/arc_gauge.dart';

import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await NotificationService.initializeNotification();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double currentRotation = 0.0;
  String selectedSegment = 'Segment 1';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mental Health Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A148C)),
        fontFamily: 'Poppins',
      ),
      home: Scaffold(
        body: Column(
          children: [
            // Top content area
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      selectedSegment,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Arc gauge at the bottom - always shows 180° window
            ArcGauge(
              outerRadius: 200,
              innerRadius: 100,
              onRotationChanged: (degrees) {
                setState(() {
                  currentRotation = degrees;
                });
              },
              onSegmentSelected: (index, name) {
                setState(() {
                  selectedSegment = name;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

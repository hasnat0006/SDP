import 'package:client/dashboard/p_dashboard.dart';
import 'package:flutter/material.dart';
// import 'mood/Mood_spin.dart';
// import 'mood/Mood_intensity.dart';
import './todo_list/todo_list_main.dart';
import './dashboard/t_dashboard.dart';
import './therapist/manage_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mental Health Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'Poppins',
      ),
      home: const ManageAppointments(),
    );
  }
} 
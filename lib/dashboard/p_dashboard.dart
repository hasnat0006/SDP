import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../journal/journal.dart'; // Ensure this import is correct
import '../todo_list/todo_list_main.dart';
import '../mood/Mood_spin.dart';
// import 'package:google_fonts/google_fonts.dart';

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
        // fontFamily: GoogleFonts.poppins().fontFamily,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildMetrics(),
              const SizedBox(height: 16),
              _buildTrackers(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD1A1E3),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('assets/zaima.jpg'), // Replace with real image
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Tue, 25 Jan 2025",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                "Hi, Zaima!",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetrics() {
    return Row(
      children: [
        _buildFreudScore(),
        const SizedBox(width: 16),
        _buildMoodBarChart(),
      ],
    );
  }

  Widget _buildFreudScore() {
    return Expanded(
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFD5E8D4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Average Sleep', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Text('5.5\nHours', textAlign: TextAlign.center, style: TextStyle(color: Colors.green)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMoodBarChart() {
    return Expanded(
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Text('Mood', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('Sad'),
            const SizedBox(height: 8),
            Expanded(
              child: BarChart(
                BarChartData(
                  barGroups: List.generate(
                    7,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: (index + 1) * 2.0, // Example data, replace with actual mood scores
                          color: Colors.deepPurple,
                          width: 20,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ],
                    ),
                  ),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

   Widget _buildTrackers(BuildContext context) {
    return Column(
      children: [
        _trackerTile(Icons.mood, 'Mood Tracker', 'Sad → Happy → Neutral', context,
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const MoodPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.ease;
                  final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  return SlideTransition(position: animation.drive(tween), child: child);
                },
              ),
            );
          },
        ),
        _trackerTile(Icons.bedtime, 'Sleep Quality', 'Healthy (~5.5h Avg)', context),
        _trackerTile(Icons.edit_note, 'Thought Journal', '64 Day Streak', context,
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const JournalPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.ease;
                  final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  return SlideTransition(position: animation.drive(tween), child: child);
                },
              ),
            );
          },
        ),
        _trackerTile(Icons.emoji_emotions_outlined, 'Stress Level', 'Level 3 | Normal', context),
        _trackerTile(Icons.calendar_month, 'Book an Appointment', 'Get professional help', context),
        _trackerTile(Icons.check_circle_outline, 'To Do List', '3/5 Completed', context,
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const ToDoApp(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.ease;
                  final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  return SlideTransition(position: animation.drive(tween), child: child);
                },
              ),
            );
          },
        ),
        _trackerTile(Icons.self_improvement, 'Virtual Therapist', 'Ease your mind', context),
        _trackerTile(Icons.forum, 'Forum', 'Share your thought', context),
      ],
    );
  }

  Widget _trackerTile(
    IconData icon,
    String title,
    String subtitle,
    BuildContext context, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title tapped!')),
            );
          },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.deepPurple),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

}



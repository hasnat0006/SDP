import 'package:flutter/material.dart';
import '../dashboard/p_dashboard.dart';
import '../mood/Mood_spin.dart';
import '../todo_list/todo_list_main.dart';
import '../forum/forum.dart';

class CustomBottomNavBarWithForum extends StatefulWidget {
  const CustomBottomNavBarWithForum({super.key});

  @override
  State<CustomBottomNavBarWithForum> createState() => _CustomBottomNavBarWithForumState();
}

class _CustomBottomNavBarWithForumState extends State<CustomBottomNavBarWithForum> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const MoodPage(),
    const ForumPage(), // Added Forum page
    const ToDoApp(),
    const Center(child: Text('Profile Page (Coming Soon!)')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: const Color(0xFFFAF6F0),
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.deepPurple.withOpacity(0.5),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), 
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mood), 
            label: 'Mood',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum_outlined), 
            label: 'Forum',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list), 
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), 
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

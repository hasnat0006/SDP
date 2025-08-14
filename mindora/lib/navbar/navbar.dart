import 'package:client/dashboard/t_dashboard.dart';
import 'package:client/forum/forum.dart';
import 'package:client/services/user_service.dart';
import 'package:client/therapist/manage_app.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../dashboard/p_dashboard.dart';
import '../mood/Mood_spin.dart';
import '../todo_list/todo_list_main.dart';
import '../profile/user_profile.dart';
import '../profile/therapist_profile.dart';
import '../settings/settings_page.dart';

class MainNavBar extends StatefulWidget {
  const MainNavBar({super.key});

  @override
  State<MainNavBar> createState() => _MainNavBarState();
}

class _MainNavBarState extends State<MainNavBar> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;

  // Define the light purple theme colors
  static const Color primaryPurple = Color(0xFF4A148C);
  static const Color accentPurple = Color(0xFFBA68C8);
  static const Color inactiveGrey = Color(0xFF757575);
  static const Color backgroundColor = Color(0xFFF5F5F5);

  String _userId = '';
  String _userType = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _pageController = PageController(initialPage: _currentIndex);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await UserService.getUserData();
      setState(() {
        _userId = userData['userId'] ?? '';
        _userType = userData['userType'] ?? '';
      });
      print('Loaded user data - ID: $_userId, Type: $_userType');
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Navigation items configuration
  List<NavItem> get _navItems => [
    NavItem(
      icon: Icons.dashboard,
      label: '',
      page: DashboardPageWrapper(userType: _userType),
    ),
    NavItem(icon: Icons.forum, label: '', page: const ForumPage()),
    if (_userType == 'patient')
      NavItem(icon: Icons.checklist, label: '', page: const TodoPageWrapper()),
    if (_userType == 'doctor')
      NavItem(icon: Icons.event, label: '', page: const ManageAppointments()),
    NavItem(
      icon: Icons.person,
      label: '',
      page: ProfilePageWrapper(userType: _userType),
    ),
    NavItem(icon: Icons.settings, label: '', page: const SettingsPage()),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundColor,
              primaryPurple.withOpacity(0.03),
              accentPurple.withOpacity(0.02),
            ],
          ),
        ),
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemCount: _navItems.length,
          itemBuilder: (context, index) {
            return _navItems[index].page;
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(5, 0, 5, 3),
        child: Container(
          height: 78,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: primaryPurple.withOpacity(0.15),
                blurRadius: 15,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                spreadRadius: -1,
                offset: const Offset(0, -1),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.6),
                blurRadius: 6,
                spreadRadius: -2,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                // padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.18),
                      Colors.white.withOpacity(0.06),
                      primaryPurple.withOpacity(0.03),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color.fromARGB(
                      255,
                      255,
                      255,
                      255,
                    ).withOpacity(0.2),
                    width: 1.0,
                  ),
                ),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: _onTabTapped,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  selectedItemColor: primaryPurple,
                  unselectedItemColor: inactiveGrey.withOpacity(0.7),
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  elevation: 0,
                  items: _navItems.asMap().entries.map((entry) {
                    int index = entry.key;
                    NavItem item = entry.value;
                    bool isSelected = _currentIndex == index;

                    return BottomNavigationBarItem(
                      icon: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.35),
                                      primaryPurple.withOpacity(0.18),
                                      accentPurple.withOpacity(0.12),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(10),
                            border: isSelected
                                ? Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 1.2,
                                  )
                                : null,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: primaryPurple.withOpacity(0.18),
                                      blurRadius: 8,
                                      spreadRadius: 0,
                                      offset: const Offset(0, 2),
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.4),
                                      blurRadius: 4,
                                      spreadRadius: -1,
                                      offset: const Offset(0, -1),
                                    ),
                                  ]
                                : null,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: isSelected
                                ? BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 4,
                                      sigmaY: 4,
                                    ),
                                    child: AnimatedScale(
                                      scale: isSelected ? 1.1 : 1.0,
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          item.icon,
                                          size: isSelected ? 22 : 20,
                                        ),
                                      ),
                                    ),
                                  )
                                : AnimatedScale(
                                    scale: isSelected ? 1.1 : 1.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        item.icon,
                                        size: isSelected ? 22 : 20,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      label: '',
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Navigation item model
class NavItem {
  final IconData icon;
  final String label;
  final Widget page;

  NavItem({required this.icon, required this.label, required this.page});
}

// Placeholder page widgets
class DashboardPageWrapper extends StatelessWidget {
  final String userType;
  const DashboardPageWrapper({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    if (userType == 'patient') {
      return const DashboardPage(); // Using existing dashboard from p_dashboard.dart
    } else {
      return const DoctorDashboard();
    }
  }
}

class MoodPageWrapper extends StatelessWidget {
  const MoodPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const MoodPage(); // Using existing mood page from Mood_spin.dart
  }
}

class TodoPageWrapper extends StatelessWidget {
  const TodoPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const ToDoPage(); // Using existing todo page from todo_list_main.dart
  }
}

class ProfilePageWrapper extends StatelessWidget {
  final String userType;
  const ProfilePageWrapper({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    if (userType == 'patient') {
      return const UserProfilePage();
    } else {
      return const TherapistProfilePage();
    }
  }
}

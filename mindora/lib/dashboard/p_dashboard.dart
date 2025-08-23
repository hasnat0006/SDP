import 'package:client/appointment/bookappt.dart';
import 'package:client/appointment/booked_appt.dart';
import 'package:client/forum/forum.dart';
import 'package:client/journal/journal.dart';
import 'package:client/mood/mood_spinner.dart';
import 'package:client/mood/Mood_insights.dart';
import 'package:client/mood/backend.dart';
import 'package:client/services/user_service.dart';
import 'package:client/profile/backend.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../todo_list/todo_list_main.dart';
import '../stress/stress_tracker.dart';
import '../stress/stress_insights.dart';
import '../stress/backend.dart';
import '../chatbot/chatbot.dart';
import '../sleep/sleeptracker.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _userId = '';
  String _userType = '';
  Map<String, dynamic>? _todayStressData;
  String _stressButtonText = 'Log your details for today';
  Map<String, dynamic>? _todayMoodData;
  String _moodButtonText = 'Log your details for today';
  Map<String, dynamic>? _userProfileData; // Add this line

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await UserService.getUserData();
      setState(() {
        _userId = userData['userId'] ?? '';
        _userType = userData['userType'] ?? '';
      });
      print('Loaded user data - ID: $_userId, Type: $_userType');
      
      // Load user profile data including profile image
      if (_userId.isNotEmpty) {
        await _loadUserProfile();
        await _loadTodayStressData();
        await _loadTodayMoodData();
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // Add this method to load user profile
  Future<void> _loadUserProfile() async {
    try {
      final ProfileBackend profileBackend = ProfileBackend();
      final response = await profileBackend.getUserProfile(_userId, _userType);
      
      if (response['success'] == true || response.containsKey('name')) {
        setState(() {
          _userProfileData = response;
        });
        print('User profile loaded successfully');
      } else {
        print('Failed to load user profile: ${response['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  // Add this method to get profile image
  ImageProvider _getProfileImage() {
    final profileImageUrl = _userProfileData?['profileImage'];
    if (profileImageUrl != null && 
        profileImageUrl.toString().isNotEmpty &&
        profileImageUrl.toString().startsWith('http')) {
      return NetworkImage(profileImageUrl);
    }
    
    // Fallback to default asset image
    return const AssetImage('assets/zaima.jpg');
  }

  Future<void> _loadTodayStressData() async {
    try {
      final result = await StressTrackerBackend.getTodayStressData(_userId);
      if (result['success']) {
        setState(() {
          _todayStressData = result['data'];
          _stressButtonText = _getStressButtonText();
        });
      } else {
        setState(() {
          _todayStressData = null;
          _stressButtonText = 'Log your details for today';
        });
      }
    } catch (e) {
      print('Error loading today\'s stress data: $e');
      setState(() {
        _todayStressData = null;
        _stressButtonText = 'Log your details for today';
      });
    }
  }

  String _getStressButtonText() {
    if (_todayStressData == null) {
      return 'Log your details for today';
    }
    
    final stressLevel = _todayStressData!['stress_level'] ?? 1;
    String levelText;
    
    switch (stressLevel) {
      case 1:
        levelText = 'Very Low';
        break;
      case 2:
        levelText = 'Low';
        break;
      case 3:
        levelText = 'Moderate';
        break;
      case 4:
        levelText = 'High';
        break;
      case 5:
        levelText = 'Extreme';
        break;
      default:
        levelText = 'Unknown';
    }
    
    return 'Level $stressLevel | $levelText';
  }

  Future<void> _loadTodayMoodData() async {
    try {
      final result = await MoodTrackerBackend.getMoodDataForDate(_userId, DateTime.now());
      if (result['success']) {
        setState(() {
          _todayMoodData = result['data'];
          _moodButtonText = _getMoodButtonText();
        });
      } else {
        setState(() {
          _todayMoodData = null;
          _moodButtonText = 'Log your details for today';
        });
      }
    } catch (e) {
      print('Error loading today\'s mood data: $e');
      setState(() {
        _todayMoodData = null;
        _moodButtonText = 'Log your details for today';
      });
    }
  }

  String _getMoodButtonText() {
    if (_todayMoodData == null) {
      return 'Log your details for today';
    }
    
    final moodStatus = _todayMoodData!['mood_status'] ?? 'Unknown';
    final moodLevel = _todayMoodData!['mood_level'] ?? 1;
    
    return '$moodStatus | Level $moodLevel';
  }

  void _handleMoodTrackerTap() {
    if (_todayMoodData != null) {
      // Data exists for today, navigate to mood insights
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MoodInsightsPage(
            moodLabel: _todayMoodData!['mood_status'] ?? 'Unknown',
            moodEmoji: _getMoodEmoji(_todayMoodData!['mood_status'] ?? 'Unknown'),
            moodIntensity: _todayMoodData!['mood_level'] ?? 1,
            selectedCauses: (_todayMoodData!['reason'] as List<dynamic>?)
                ?.map((e) => e.toString()).toList() ?? [],
          ),
        ),
      );
    } else {
      // No data for today, navigate to mood spinner for input
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MoodSpinner(),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;
                final tween = Tween(
                  begin: begin,
                  end: end,
                ).chain(CurveTween(curve: curve));
                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
        ),
      ).then((_) {
        // Refresh data when returning from mood tracker
        _loadTodayMoodData();
      });
    }
  }

  String _getMoodEmoji(String moodStatus) {
    switch (moodStatus.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'sad':
        return '😢';
      case 'angry':
        return '😠';
      case 'excited':
        return '😃';
      case 'stressed':
        return '😟';
      default:
        return '😊';
    }
  }

  void _handleStressTrackerTap() {
    if (_todayStressData != null) {
      // Data exists for today, navigate to insights
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StressInsightsPage(
            stressLevel: _todayStressData!['stress_level'] ?? 1,
            cause: [], // Will be loaded from backend
            loggedSymptoms: [], // Will be loaded from backend
            Notes: [], // Will be loaded from backend
          ),
        ),
      );
    } else {
      // No data for today, navigate to tracker for input
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const StressTrackerPage(),
        ),
      ).then((_) {
        // Refresh data when returning from stress tracker
        _loadTodayStressData();
      });
    }
  }

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
          CircleAvatar(
            radius: 30,
            backgroundImage: _getProfileImage(), // Use dynamic profile image
            onBackgroundImageError: (exception, stackTrace) {
              print('Error loading profile image: $exception');
            },
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tue, 25 Jan 2025",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                _userProfileData?['name'] != null 
                    ? "Welcome back, ${_userProfileData!['name']}!"
                    : _userType.isNotEmpty
                        ? "Welcome back, ${_userType[0].toUpperCase()}${_userType.substring(1)}!"
                        : "Welcome back, User!",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
            Text(
              'Average Sleep',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Text(
                '5.5\nHours',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.green),
              ),
            ),
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
                          toY:
                              (index + 1) *
                              2.0, // Example data, replace with actual mood scores
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackers(BuildContext context) {
    return Column(
      children: [
        _trackerTile(
          Icons.mood,
          'Mood Tracker',
          _moodButtonText,
          context,
          onTap: _handleMoodTrackerTap,
        ),
        _trackerTile(
          Icons.bedtime,
          'Sleep Quality',
          'Insomniac (~2h Avg)',
          context,
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    Sleeptracker(userId: _userId),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.ease;
                      final tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
              ),
            );
          },
        ),
        _trackerTile(
          Icons.edit_note,
          'Thought Diary',
          'Note down your thoughts',
          context,
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    JournalPage(userId: _userId), // Pass the userId parameter here
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.ease;
                      final tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
              ),
            );
          },
        ),
        _trackerTile(
          Icons.emoji_emotions_outlined,
          'Stress Level',
          _stressButtonText,
          context,
          onTap: _handleStressTrackerTap,
        ),

        _trackerTile(
          Icons.event_available,
          'Your Appointments',
          '1 booked appointment',
          context,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookedAppointments(
                  appointments: [
                    Appointment(
                      name: 'Dr. Afsana Rahman',
                      institution: 'MindCare Clinic',
                      imagepath: 'mindora/assets/ifrit.jpeg',
                      location: 'Uttara, Dhaka, Bangladesh',
                      dateTime: DateTime.now().add(const Duration(days: 2)),
                      specialty: 'Psychiatrist',
                      status: AppointmentStatus.booked,
                    ),
                    Appointment(
                      name: 'Dr. Farhan Kabir',
                      institution: 'Serenity Health',
                      imagepath: 'assets/doctor_2.jpg',
                      location: 'Banani, Dhaka, Bangladesh',
                      dateTime: DateTime.now().subtract(
                        const Duration(days: 3),
                      ),
                      specialty: 'Psychiatrist',
                      status: AppointmentStatus.completed,
                    ),
                    Appointment(
                      name: 'Dr. Mariam Hossain',
                      institution: 'Tranquil Minds',
                      imagepath: 'assets/doctor_3.jpg',
                      location: 'Dhanmondi, Dhaka, Bangladesh',
                      dateTime: DateTime.now().subtract(
                        const Duration(days: 1),
                      ),
                      specialty: 'Psychiatrist',
                      status: AppointmentStatus.completed,
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        _trackerTile(
          Icons.calendar_month,
          'Book an Appointment',
          'Get professional help',
          context,
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    BookAppt(userId: _userId),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.ease;
                      final tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
              ),
            );
          },
        ),
        _trackerTile(
          Icons.edit_note,
          'Todo List',
          '3/5 Completed',
          context,
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const ToDoApp(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.ease;
                      final tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
              ),
            );
          },
        ),

        _trackerTile(
          Icons.forum,
          'Forum',
          'Share your thought anonymously',
          context,
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const ForumPage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.ease;
                      final tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
              ),
            );
          },
        ),
        _trackerTile(
          Icons.self_improvement,
          'Virtual Therapist',
          'Ease your mind',
          context,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const Chatbot(), // Use MaterialPageRoute for simplicity
              ),
            );
          },
        ),
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
      onTap:
          onTap ??
          () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('$title tapped!')));
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
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
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

import 'package:client/login/signup/login.dart';
import 'package:client/navbar/navbar.dart';
import 'package:client/services/notification_service.dart';
import 'package:client/services/gemini_service.dart';
import 'package:client/services/navigation_service.dart';
import 'package:client/services/supabase_service.dart';
import 'package:client/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './sleep/service/notification.dart';
import './appointment/service/notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await NotificationService.initializeNotification();
  await SleepNotificationService.initializeSleepNotifications();
  await AppointmentNotificationService.scheduleAppointmentReminder();
  // Initialize Supabase (non-blocking)
  await SupabaseService.initialize();

  GeminiService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mental Health Dashboard',
      debugShowCheckedModeBanner: false,
      navigatorKey:
          NavigationService.navigatorKey, // Use navigation service key
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A148C)),
        fontFamily: 'Poppins',
      ),
      home: const AuthChecker(),
    );
  }
}

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  bool _shouldNavigateToMain = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _checkLoginStatus();
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    // Start checking authentication while progress bar is animating
    final isLoggedIn = await UserService.isLoggedIn();

    setState(() {
      _shouldNavigateToMain = isLoggedIn;
    });

    // Wait for progress bar to complete if it hasn't already
    if (!_progressController.isCompleted) {
      await _progressController.forward();
    }

    // Add a small delay to see the completed progress bar
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      if (_shouldNavigateToMain) {
        // User is already logged in, navigate to main app
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavBar()),
        );
      } else {
        // User is not logged in, navigate to login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading screen while checking authentication
    return Scaffold(
      backgroundColor: const Color(0xFFF9F4F2),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Mindora',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4A148C),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 140, // Approximate width of "Mindora" text at 32px
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _progressAnimation.value,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF4A148C),
                    ),
                    backgroundColor: const Color(0xFF4A148C).withOpacity(0.2),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:client/login/signup/login.dart';
import 'package:flutter/material.dart';

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
        
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A148C)),
        fontFamily: 'Poppins',
      ),
      home: const LoginPage(), // Using the new navbar
    );
  }
}




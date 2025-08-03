import 'package:client/login/signup/login.dart';
import 'testpage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Consider moving this to a configuration file
const String apiUrl = 'http://127.0.0.1:5000'; // for Android emulator
// const String apiUrl = 'http://localhost:3000'; // for iOS simulator

Future<List<dynamic>> fetchUsers() async {
  try {
    final response = await http.get(Uri.parse('$apiUrl/users'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load users: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Network error: $e');
  }
}

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
      home: const DatabaseTestPage(), // Using the new navbar
    );
  }
}

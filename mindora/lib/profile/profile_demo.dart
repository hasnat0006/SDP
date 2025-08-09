import 'package:flutter/material.dart';
import 'user_profile.dart';

/// Demo page to showcase the UserProfilePage
/// You can integrate this into your existing navigation structure
class ProfileDemo extends StatelessWidget {
  const ProfileDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Demo')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserProfilePage()),
            );
          },
          child: const Text('View Profile'),
        ),
      ),
    );
  }
}

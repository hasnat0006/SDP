import 'package:flutter/material.dart';
import '../../navbar/navbar.dart'; // <-- Fixed import path
import 'login.dart'; // <-- Import for LoginPage navigation

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F1EB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top curve with logo
            Container(
              width: double.infinity,
              height: 180,
              decoration: const BoxDecoration(
                color: Color(0xFFD6A9E5),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(100),
                  bottomRight: Radius.circular(100),
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: const AssetImage('assets/mindora.png'),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Sign Up For Free',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A2C13),
              ),
            ),
            const SizedBox(height: 30),

            // Email Field
            _buildTextField(
              label: "Email Address",
              hintText: "Enter your email...",
              icon: Icons.email_outlined,
              isPassword: false,
            ),

            const SizedBox(height: 20),

            // Password Field
            _buildTextField(
              label: "Password",
              hintText: "Enter your password...",
              icon: Icons.lock_outline,
              isPassword: true,
              obscureText: _obscurePassword,
              toggle: () => setState(() => _obscurePassword = !_obscurePassword),
            ),

            const SizedBox(height: 20),

            // Confirm Password Field
            _buildTextField(
              label: "Password Confirmation",
              hintText: "Confirm your password...",
              icon: Icons.lock_outline,
              isPassword: true,
              obscureText: _obscureConfirm,
              toggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),

            const SizedBox(height: 30),

            // Sign Up Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD0B375),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainNavBar()),
                );
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Sign Up", style: TextStyle(fontSize: 16, color: Colors.white)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Bottom Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?", style: TextStyle(color: Colors.black54)),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  child: const Text(
                    "Sign In.",
                    style: TextStyle(
                      color: Color(0xFFE66A1F),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    required IconData icon,
    required bool isPassword,
    bool obscureText = false,
    VoidCallback? toggle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: isPassword ? null : Border.all(color: Color(0xFFE89B5F)),
              color: isPassword ? const Color(0xFFF4F2F2) : null,
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: Icon(icon, color: Colors.black54),
                suffixIcon: isPassword
                    ? IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: toggle,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

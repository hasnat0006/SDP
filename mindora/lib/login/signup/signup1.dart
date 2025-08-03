import 'package:flutter/material.dart';
import '../../navbar/navbar.dart'; // <-- Fixed import path
import 'login.dart'; // <-- Import for LoginPage navigation
import './backend.dart'; // <-- Import backend service

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  // Add TextEditingControllers to store field data
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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
              controller: _emailController,
            ),

            const SizedBox(height: 20),

            // Password Field
            _buildTextField(
              label: "Password",
              hintText: "Enter your password...",
              icon: Icons.lock_outline,
              isPassword: true,
              obscureText: _obscurePassword,
              toggle: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              controller: _passwordController,
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
              controller: _confirmPasswordController,
            ),

            const SizedBox(height: 30),

            // Sign Up Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD0B375),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 100,
                  vertical: 16,
                ),
              ),
              onPressed: () async {
                // Access the field data
                String email = _emailController.text.trim();
                String password = _passwordController.text;
                String confirmPassword = _confirmPasswordController.text;

                // Validate form using backend service
                final validation = BackendService.validateSignupForm(
                  email: email,
                  password: password,
                  confirmPassword: confirmPassword,
                );

                if (!validation['isValid']) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(validation['message']),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Print or process the data (you can replace this with your signup logic)
                print('Email: $email');
                print('Password: $password');

                // Apply backend signup logic here
                final result = await BackendService.signUpUser(
                  email: email,
                  password: password,
                );

                if (result['success']) {
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message']),
                      backgroundColor: Colors.green,
                    ),
                  );

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainNavBar()),
                  );
                } else {
                  // Handle backend errors
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message']),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
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
                const Text(
                  "Already have an account?",
                  style: TextStyle(color: Colors.black54),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
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
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: isPassword ? null : Border.all(color: Color(0xFFE89B5F)),
              color: isPassword ? const Color(0xFFF4F2F2) : null,
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              controller: controller,
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

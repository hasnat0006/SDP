import 'package:flutter/material.dart';
import 'login.dart'; // <-- Import for LoginPage navigation
import './backend.dart'; // <-- Import backend service
import './emergency_contact_popup.dart'; // <-- Import emergency contact popup

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _isPatient = true;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _bdnController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bdnController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    // Set loading state
    setState(() {
      _isLoading = true;
    });

    try {
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
        _showErrorMessage(validation['message']);
        return;
      }

      // Apply backend signup logic here
      final result = await BackendService.signUpUser(
        email: email,
        password: password,
        name: _fullNameController.text,
        bdn: !_isPatient ? _bdnController.text : null,
        isPatient: _isPatient,
      );

      if (result['success']) {
        print('✅ User created successfully');

        // If it's a patient, show emergency contact popup
        if (_isPatient) {
          final userId = result['userId']?.toString();
          if (userId != null) {
            _showEmergencyContactPopup(userId);
          } else {
            print('❌ User ID not found in response');
            _navigateToLogin();
          }
        } else {
          // For doctors, navigate directly to login
          _navigateToLogin();
        }
      } else {
        _showErrorMessage(result['message']);
      }
    } catch (e) {
      print('❌ Signup error: $e');
      _showErrorMessage('An error occurred during signup');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showEmergencyContactPopup(String userId) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (context) => EmergencyContactPopup(
        userId: userId,
        onSaved: () {
          print('✅ Emergency contacts saved, navigating to login');
          _navigateToLogin();
        },
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account created successfully! Please login.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
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
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
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
            // Toggle buttons for user type
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _isPatient = true);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: _isPatient
                              ? const Color(0xFFD6A9E5)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _isPatient
                                ? const Color(0xFFD6A9E5)
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                          boxShadow: _isPatient
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFD6A9E5,
                                    ).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 32,
                              color: _isPatient
                                  ? Colors.white
                                  : Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Patient",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _isPatient
                                    ? Colors.white
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _isPatient = false);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: !_isPatient
                              ? const Color(0xFFD6A9E5)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: !_isPatient
                                ? const Color(0xFFD6A9E5)
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                          boxShadow: !_isPatient
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFD6A9E5,
                                    ).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.medical_services_outlined,
                              size: 32,
                              color: !_isPatient
                                  ? Colors.white
                                  : Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Psychiatrist",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: !_isPatient
                                    ? Colors.white
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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

            // Full Name Field
            _buildTextField(
              label: "Full Name",
              hintText: "Enter your full name...",
              icon: Icons.person_outline,
              isPassword: false,
              controller: _fullNameController,
            ),

            const SizedBox(height: 20),

            // Email Field
            _buildTextField(
              label: "Email Address",
              hintText: "Enter your email...",
              icon: Icons.email_outlined,
              isPassword: false,
              controller: _emailController,
            ),

            const SizedBox(height: 20),

            // BDN Number Field (only for psychiatrist)
            if (!_isPatient)
              _buildTextField(
                label: "BDN Number",
                hintText: "Enter your BDN number...",
                icon: Icons.numbers,
                isPassword: false,
                controller: _bdnController,
              ),

            if (!_isPatient) const SizedBox(height: 20),

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
                backgroundColor: _isLoading
                    ? const Color(0xFFD0B375).withOpacity(0.7)
                    : const Color(0xFFD0B375),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 100,
                  vertical: 16,
                ),
              ),
              onPressed: _isLoading ? null : _handleSignup,
              child: _isLoading
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          "Signing Up...",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    )
                  : const Row(
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
              borderRadius: BorderRadius.circular(10),
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

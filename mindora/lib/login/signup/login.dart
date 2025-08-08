import 'package:client/login/signup/backend.dart';
import 'package:client/navbar/navbar.dart';
import 'package:client/services/user_service.dart';
import 'package:flutter/material.dart';
import '../../dashboard/p_dashboard.dart';
import 'signup1.dart';
import 'forgetpass.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F4F2),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopHeader(),
            const SizedBox(height: 16),
            const Text(
              'Login to MINDORA',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF432818),
              ),
            ),
            const SizedBox(height: 32),
            _buildTextField(
              controller: _emailController,
              hintText: 'Enter you email...',
              label: 'Email Address',
              icon: Icons.email_outlined,
              borderColor: const Color(0xFFA6D38D),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _passwordController,
              hintText: 'Enter your password...',
              label: 'Password',
              icon: Icons.lock_outline,
              isPassword: true,
              borderColor: const Color(0xFFF5F5F5),
            ),
            const SizedBox(height: 30),
            _buildSignInButton(),
            const SizedBox(height: 25),
            _buildSocialIcons(),
            const SizedBox(height: 20),
            _buildFooterText(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: const BoxDecoration(
        color: Color(0xFFD1A1E3),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/mindora.png'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String label,
    required IconData icon,
    required Color borderColor,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: isPassword ? _obscureText : false,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: Icon(icon),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: borderColor.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: borderColor, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: borderColor, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: ElevatedButton(
        onPressed: () async {
          final email = _emailController.text.trim();
          final password = _passwordController.text.trim();
          if (email.isEmpty || password.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please fill in all fields')),
            );
            return;
          }

          if (!BackendService.isValidEmail(email)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please enter a valid email address'),
              ),
            );
            return;
          }

          final result = await BackendService.loginUser(
            email: email,
            password: password,
          );
          print('Login result:');
          print(result);
          if (result['success']) {
            // Extract user data from response
            final userData = result['data'];
            final userId = userData['id'].toString();
            final userType = userData['type'];

            // Store user data locally
            await UserService.storeUserData(userId: userId, userType: userType);

            print('User data stored - ID: $userId, Type: $userType');

            // Navigate to dashboard
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainNavBar()),
            );
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(result['message'])));
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFCBB994),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sign In',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward, color: Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _SocialIconButton(icon: Icons.facebook),
        SizedBox(width: 16),
        _SocialIconButton(icon: Icons.g_mobiledata),
        SizedBox(width: 16),
        _SocialIconButton(icon: Icons.camera_alt_outlined),
      ],
    );
  }

  Widget _buildFooterText() {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ForgetPassPage()),
            );
          },
          child: const Text(
            "Forgot Password",
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Don't have an account? "),
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                minimumSize: Size(0, 28),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpPage()),
                );
              },
              child: const Text(
                "Sign Up",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD25B68),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  final IconData icon;

  const _SocialIconButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.white,
      radius: 22,
      child: Icon(icon, color: Colors.black),
    );
  }
}

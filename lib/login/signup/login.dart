import 'package:flutter/material.dart';

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
        color: Color(0xFFD8A3D3),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(90),
          bottomRight: Radius.circular(90),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/mindora_logo.png'), // Replace with your logo
            ),
            const SizedBox(height: 8),
            const Text(
              'MINDORA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 16,
                letterSpacing: 1.2,
              ),
            ),
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
        onPressed: () {
          // handle login
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
        const Text(
          "Forgot Password",
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text("Don't have an account? "),
            Text(
              "Sign Up.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFD25B68),
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

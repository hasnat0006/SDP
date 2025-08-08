import 'package:client/login/signup/backend.dart';
import 'package:flutter/material.dart';
import 'resetpass.dart';
import 'otp_verification_page.dart';

class ForgetPassPage extends StatefulWidget {
  const ForgetPassPage({super.key});

  @override
  State<ForgetPassPage> createState() => _ForgetPassPageState();
}

class _ForgetPassPageState extends State<ForgetPassPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

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
              'Please enter your email to get OTP',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF432818),
              ),
            ),
            const SizedBox(height: 32),
            _buildTextField(
              controller: _emailController,
              hintText: 'Enter your email...',
              label: 'Email Address',
              icon: Icons.email_outlined,
              borderColor: const Color(0xFFA6D38D),
            ),
            const SizedBox(height: 20),
            _buildSendOtpButton(),
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
          children: const [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/mindora.png'),
            ),
            SizedBox(height: 8),
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
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: Icon(icon),
              filled: true,
              fillColor: borderColor.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: borderColor, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: borderColor, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendOtpButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            // Logic to send OTP
            String email = _emailController.text.trim();
            if (email.isNotEmpty) {
              const snackBar = SnackBar(
                content: Text('Sending OTP...'),
                duration: Duration(seconds: 2),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);

              final response = await BackendService.sendOtp(email);

              print(response);

              if (response['success']) {
                // OTP sent successfully
                print('OTP sent to: $email');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OtpVerificationPage(
                      email: email,
                      otp: response['data']['otp'].toString(),
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please add your email address'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFCBB994),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          ),
          child: const Text(
            'Send OTP',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildOtpField() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 32),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text('OTP', style: TextStyle(fontWeight: FontWeight.w600)),
  //         const SizedBox(height: 8),
  //         TextField(
  //           controller: _otpController,
  //           keyboardType: TextInputType.number,
  //           decoration: InputDecoration(
  //             hintText: 'Enter OTP...',
  //             prefixIcon: const Icon(Icons.lock_outline),
  //             filled: true,
  //             fillColor: const Color(0xFFF5F5F5),
  //             border: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(30),
  //               borderSide: const BorderSide(color: Color(0xFFCBB994)),
  //             ),
  //             enabledBorder: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(30),
  //               borderSide: const BorderSide(color: Color(0xFFCBB994)),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildSubmitButton() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 32),
  //     child: ElevatedButton(
  //       onPressed: () {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => const ResetPassPage()),
  //         );
  //       },
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor: const Color(0xFFCBB994),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
  //       ),
  //       child: const Text(
  //         'Submit',
  //         style: TextStyle(
  //           color: Colors.black,
  //           fontWeight: FontWeight.bold,
  //           fontSize: 16,
  //         ),
  //       ),
  //     ),
  //   );
  // }
}

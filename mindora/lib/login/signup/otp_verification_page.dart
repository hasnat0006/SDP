import 'package:flutter/material.dart';
import 'resetpass.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  final String otp;

  const OtpVerificationPage({Key? key, required this.email, required this.otp})
    : super(key: key);

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    5,
    (_) => TextEditingController(),
  );
  int _seconds = 60;
  late final List<FocusNode> _fieldNodes;

  @override
  void initState() {
    super.initState();
    _fieldNodes = List.generate(5, (_) => FocusNode());
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _seconds > 0) {
        setState(() {
          _seconds--;
        });
        _startTimer();
      }
    });
  }

  @override
  void dispose() {
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var n in _fieldNodes) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F4F2),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter OTP',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Code sent to ${widget.email.isNotEmpty ? widget.email : "+880-123456789"}',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return Container(
                    width: 48,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: TextField(
                      controller: _otpControllers[i],
                      focusNode: _fieldNodes[i],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFCBB994),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFCBB994),
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty && i < 4) {
                          FocusScope.of(
                            context,
                          ).requestFocus(_fieldNodes[i + 1]);
                        } else if (val.isEmpty && i > 0) {
                          FocusScope.of(
                            context,
                          ).requestFocus(_fieldNodes[i - 1]);
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              const Text(
                "Didn't receive code?",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: _seconds == 0
                        ? () {
                            setState(() {
                              _seconds = 60;
                            });
                            _startTimer();
                          }
                        : null,
                    child: Text(
                      'Request Again [00:00:${_seconds.toString().padLeft(2, '0')}]',
                      style: TextStyle(
                        color: _seconds == 0 ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    List<String> enteredOTP = [];

                    for (var i = 0; i < 5; i++) {
                      enteredOTP.add(_otpControllers[i].text);
                    }

                    String enteredOtpString = enteredOTP.join('');

                    print("Entered OTP: $enteredOtpString");
                    print("Received OTP: ${widget.otp}");

                    // Verify the entered OTP with the received OTP
                    if (enteredOtpString == widget.otp) {
                      // OTP is correct, navigate to reset password page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResetPassPage(email: widget.email),
                        ),
                      );
                    } else {
                      // OTP is incorrect, show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Invalid OTP. Please try again.'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );

                      // Clear all OTP fields
                      for (var controller in _otpControllers) {
                        controller.clear();
                      }

                      // Focus back to first field
                      FocusScope.of(context).requestFocus(_fieldNodes[0]);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Verify',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

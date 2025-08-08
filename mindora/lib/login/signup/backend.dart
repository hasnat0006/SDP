import '../../backend/main_query.dart';

class BackendService {
  // User signup function
  static Future<Map<String, dynamic>> signUpUser({
    required String email,
    required String password,
    required String name,
    String? bdn,
    bool isPatient = false,
  }) async {
    try {
      final response = await postToBackend('signup', {
        'email': email,
        'password': password,
        'name': name,
        'bdn': bdn,
        'isPatient': isPatient,
      });

      return {
        'success': true,
        'message': 'Account created successfully!',
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Signup failed: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  // User login function (for future use)
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await getFromBackend(
        'login?email=$email&password=$password',
      );
      print("-------------response: $response");
      return {
        'success': true,
        'message': 'Login successful!',
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Please check your email and password',
        'error': e.toString(),
      };
    }
  }

  // Email validation helper
  static bool isValidEmail(String email) {
    return email.contains('@') && email.contains('.');
  }

  // Password validation helper
  static Map<String, dynamic> validatePassword(String password) {
    if (password.length < 3) {
      return {
        'isValid': false,
        'message': 'Password must be at least 3 characters long',
      };
    }

    return {'isValid': true, 'message': 'Password is valid'};
  }

  // Form validation helper
  static Map<String, dynamic> validateSignupForm({
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    // Check if fields are empty
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      return {'isValid': false, 'message': 'Please fill all fields'};
    }

    // Check if passwords match
    if (password != confirmPassword) {
      return {'isValid': false, 'message': 'Passwords do not match'};
    }

    // Validate email
    if (!isValidEmail(email)) {
      return {
        'isValid': false,
        'message': 'Please enter a valid email address',
      };
    }

    // Validate password
    final passwordValidation = validatePassword(password);
    if (!passwordValidation['isValid']) {
      return passwordValidation;
    }

    return {'isValid': true, 'message': 'Form is valid'};
  }

  static Future<Map<String, dynamic>> sendOtp(String email) async {
    try {
      final response = await getFromBackend('reset-pass/send-otp?email=$email');
      return {
        'success': true,
        'message': 'OTP sent successfully!',
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to send OTP: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String password,
  }) async {
    if (!BackendService.validatePassword(password)['isValid']) {
      return {
        'success': false,
        'message': BackendService.validatePassword(password)['message'],
      };
    }

    try {
      final response = await postToBackend('reset-pass/change-pass', {
        'email': email,
        'password': password,
      });

      return {
        'success': true,
        'message': 'Password reset successfully!',
        'data': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to reset password: ${e.toString()}',
        'error': e.toString(),
      };
    }
  }
}

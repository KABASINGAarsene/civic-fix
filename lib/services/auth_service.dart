import 'dart:math';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

/// Authentication Service
/// Handles user authentication, OTP generation, and login logic
///
/// TODO: Integrate with actual backend API
/// TODO: Implement SMS gateway for OTP delivery (Pindo, Africa's Talking, Twilio)

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // TODO: Replace with actual API endpoint
  static const String _baseUrl = 'https://api.districtdirect.rw';

  /// Generate a random 6-digit OTP
  /// This should be called on the backend, not in production client code
  String generateOTP() {
    final random = Random();
    final otp = (100000 + random.nextInt(900000)).toString();
    return otp;
  }

  /// Send OTP to phone number via SMS
  ///
  /// TODO: Integrate with SMS gateway
  /// Options for Rwanda:
  /// - Pindo (https://www.pindo.io/)
  /// - Africa's Talking (https://africastalking.com/)
  /// - Twilio (https://www.twilio.com/)
  /// - MTN Rwanda API
  /// - Airtel Rwanda API
  Future<Map<String, dynamic>> sendOTP(String phoneNumber) async {
    try {
      // Generate OTP
      final otp = generateOTP();

      // TODO: Store OTP in database with expiry time (e.g., 5 minutes)
      // Example:
      // await _storeOTPInDatabase(phoneNumber, otp, expiryMinutes: 5);

      // TODO: Send SMS via gateway
      // Example with generic SMS gateway:
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/sms/send'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({
      //     'phone': phoneNumber,
      //     'message': 'Your DistrictDirect verification code is: $otp. Valid for 5 minutes.',
      //   }),
      // );
      //
      // if (response.statusCode == 200) {
      //   return {'success': true, 'message': 'OTP sent successfully'};
      // }

      // Simulate success for now
      print('OTP generated: $otp for phone: $phoneNumber');
      print('SMS would be sent via gateway in production');

      return {
        'success': true,
        'message': 'OTP sent successfully',
        'otp': otp, // Don't return this in production!
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to send OTP: ${e.toString()}',
      };
    }
  }

  /// Verify OTP entered by user
  Future<Map<String, dynamic>> verifyOTP(String phoneNumber, String otp) async {
    try {
      // TODO: Verify OTP against database
      // Check if OTP matches and hasn't expired
      // Example:
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/auth/verify-otp'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({
      //     'phone': phoneNumber,
      //     'otp': otp,
      //   }),
      // );
      //
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   return {'success': true, 'token': data['token']};
      // }

      // Simulate success for now
      print('Verifying OTP: $otp for phone: $phoneNumber');

      return {'success': true, 'message': 'OTP verified successfully'};
    } catch (e) {
      return {
        'success': false,
        'message': 'OTP verification failed: ${e.toString()}',
      };
    }
  }

  /// Login with phone number and password
  Future<Map<String, dynamic>> login({
    required String phoneNumber,
    required String password,
    String? nationalId,
    bool isAdmin = false,
  }) async {
    try {
      // TODO: Make actual API call to backend
      // Example:
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/auth/login'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({
      //     'phone': phoneNumber,
      //     'password': password,
      //     'nationalId': nationalId,
      //     'isAdmin': isAdmin,
      //   }),
      // );
      //
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   // Store token in secure storage
      //   await _storeAuthToken(data['token']);
      //   return {
      //     'success': true,
      //     'user': data['user'],
      //     'token': data['token'],
      //   };
      // }

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // Simulate successful login
      print('Login attempt: phone=$phoneNumber, isAdmin=$isAdmin');

      return {
        'success': true,
        'message': 'Login successful',
        'user': {
          'id': '12345',
          'phone': phoneNumber,
          'nationalId': nationalId,
          'role': isAdmin ? 'admin' : 'citizen',
        },
      };
    } catch (e) {
      return {'success': false, 'message': 'Login failed: ${e.toString()}'};
    }
  }

  /// Register new user
  Future<Map<String, dynamic>> register({
    required String phoneNumber,
    required String password,
    required String otp,
    String? nationalId,
  }) async {
    try {
      // TODO: Implement registration logic
      // 1. Verify OTP first
      // 2. Create user account
      // 3. Return auth token

      return {'success': true, 'message': 'Registration successful'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration failed: ${e.toString()}',
      };
    }
  }

  /// Logout user
  Future<void> logout() async {
    // TODO: Clear auth token from secure storage
    // TODO: Invalidate token on backend
    print('User logged out');
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    // TODO: Check if valid auth token exists in secure storage
    return false;
  }

  /// Get current user
  Future<Map<String, dynamic>?> getCurrentUser() async {
    // TODO: Fetch user data from backend or local storage
    return null;
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zteel_user/config/api_config.dart';

class AuthService {
  AuthService._();

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _phoneKey = 'phone_number';
  static const _loggedInKey = 'is_logged_in';

  static String formatPhoneNumber(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) return '+91$digits';
    if (digits.startsWith('91') && digits.length == 12) return '+$digits';
    return phone.startsWith('+') ? phone : '+$digits';
  }

  static bool isValidMobileNumber(String phone) =>
      RegExp(r'^(?:\+91|91)?[6-9]\d{9}$')
          .hasMatch(phone.replaceAll(RegExp(r'[\s-]'), ''));

  static Future<Map<String, dynamic>> sendOtp(String rawPhone) async {
    final phone = formatPhoneNumber(rawPhone);
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.sendOtpUrl),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': phone}),
      );
      final data = _decodeBody(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'phone_number': data['phone_number']?.toString() ?? phone,
          'otp': data['dev_otp']?.toString(),
        };
      }
      return {'success': false, 'error': _message(data, 'Failed to send OTP.')};
    } catch (_) {
      return {
        'success': false,
        'error': 'Unable to reach the server. Please try again.',
      };
    }
  }

  /// Completes the customer login using the OTP returned by the backend.
  static Future<Map<String, dynamic>> verifyCustomerOtp({
    required String rawPhone,
    required String otp,
  }) async {
    final phone = formatPhoneNumber(rawPhone);
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.customerVerifyOtpUrl),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': phone, 'otp': otp}),
      );
      final data = _decodeBody(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final access = data['access']?.toString() ?? '';
        if (access.isEmpty) {
          return {'success': false, 'error': 'The server did not return a login token.'};
        }
        await _saveSession(
          access: access,
          refresh: data['refresh']?.toString() ?? '',
          phone: data['phone_number']?.toString() ?? phone,
        );
        return {'success': true};
      }
      return {'success': false, 'error': _message(data, 'Unable to complete login.')};
    } catch (_) {
      return {
        'success': false,
        'error': 'Unable to reach the server. Please try again.',
      };
    }
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_accessKey);
    return (token != null && token.isNotEmpty) ? token : null;
  }

  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getAccessToken();
    if (token != null && token.isNotEmpty) {
      return {'Authorization': 'Bearer $token'};
    }
    return const {};
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getBool(_loggedInKey) ?? false) &&
        (prefs.getString(_accessKey)?.isNotEmpty ?? false);
  }

  static Future<void> _saveSession({
    required String access,
    required String refresh,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKey, access);
    await prefs.setString(_refreshKey, refresh);
    await prefs.setString(_phoneKey, phone);
    await prefs.setBool(_loggedInKey, true);
  }

  static Map<String, dynamic> _decodeBody(String body) {
    try {
      final data = jsonDecode(body);
      return data is Map<String, dynamic> ? data : <String, dynamic>{};
    } on FormatException {
      return <String, dynamic>{};
    }
  }

  static String _message(Map<String, dynamic> data, String fallback) {
    final errors = data['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) return first.first.toString();
      return first.toString();
    }
    return data['message']?.toString() ?? data['detail']?.toString() ?? fallback;
  }
}

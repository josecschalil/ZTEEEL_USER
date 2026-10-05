import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zteel_user/services/auth_service.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('OTP verification returns the customer onboarding status', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/api/v1/auth/customer/verify-otp/');
      expect(jsonDecode(request.body), {
        'phone_number': '+919876543210',
        'otp': '123456',
      });
      return http.Response(
        jsonEncode({
          'access': 'access-token',
          'refresh': 'refresh-token',
          'phone_number': '+919876543210',
          'is_onboarded': false,
        }),
        200,
      );
    });

    final result = await AuthService.verifyCustomerOtp(
      rawPhone: '9876543210',
      otp: '123456',
      client: client,
    );

    expect(result, {'success': true, 'is_onboarded': false});
    expect(await AuthService.getAccessToken(), 'access-token');
  });

  test('profile update trims names and sends the authenticated PATCH request',
      () async {
    SharedPreferences.setMockInitialValues({'access_token': 'access-token'});
    final client = MockClient((request) async {
      expect(request.method, 'PATCH');
      expect(request.url.path, '/api/v1/profile/');
      expect(request.headers['authorization'], 'Bearer access-token');
      expect(jsonDecode(request.body), {
        'first_name': 'Ada',
        'last_name': 'Lovelace',
      });
      return http.Response('{"is_onboarded":true}', 200);
    });

    final result = await AuthService.updateCustomerProfile(
      firstName: ' Ada ',
      lastName: ' Lovelace ',
      client: client,
    );

    expect(result['success'], isTrue);
  });

  test('profile update surfaces backend errors', () async {
    SharedPreferences.setMockInitialValues({'access_token': 'access-token'});
    final client = MockClient(
      (_) async => http.Response('{"detail":"Name is invalid."}', 400),
    );

    final result = await AuthService.updateCustomerProfile(
      firstName: 'Ada',
      lastName: 'Lovelace',
      client: client,
    );

    expect(result, {'success': false, 'error': 'Name is invalid.'});
  });
}

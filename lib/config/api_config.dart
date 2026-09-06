/// Central backend configuration for the ZTEEL user app.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'http://20.235.180.249:8000';

  static String get sendOtpUrl => '$baseUrl/api/v1/auth/send-otp/';
  static String get customerVerifyOtpUrl =>
      '$baseUrl/api/v1/auth/customer/verify-otp/';
  static String get tokenRefreshUrl => '$baseUrl/api/v1/auth/refresh/';
  static String get meUrl => '$baseUrl/api/v1/auth/me/';
  static String get logoutUrl => '$baseUrl/api/v1/auth/logout/';
  static String get offerFeedUrl => '$baseUrl/api/v1/offers/feed/';
  static String vendorDetailUrl(String vendorId) => '$baseUrl/api/v1/vendor/$vendorId/';
  static String vendorMenuUrl(String vendorId) =>
      '$baseUrl/api/v1/vendor/$vendorId/menu/';
}

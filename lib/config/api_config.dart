/// Central backend configuration for the ZTEEL user app.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'http://68.233.116.23:8000';

  static String get sendOtpUrl => '$baseUrl/api/v1/auth/send-otp/';
  static String get customerVerifyOtpUrl =>
      '$baseUrl/api/v1/auth/customer/verify-otp/';
  static String get tokenRefreshUrl => '$baseUrl/api/v1/auth/refresh/';
  static String get meUrl => '$baseUrl/api/v1/auth/me/';
  static String get offerFeedUrl => '$baseUrl/api/v1/offers/feed/';
  static String get vendorsListUrl => '$baseUrl/api/v1/vendors/';
  static String get vendorAltListUrl => '$baseUrl/api/v1/vendor/list/';
  static String get searchVendorsUrl => '$baseUrl/api/v1/search/?q=a&filter=vendors';
  static String vendorDetailUrl(String vendorId) =>
      '$baseUrl/api/v1/vendor/$vendorId/';
  static String vendorMenuUrl(String vendorId) =>
      '$baseUrl/api/v1/vendor/$vendorId/menu/';
  static String vendorOffersUrl(String vendorId) =>
      '$baseUrl/api/v1/vendor/$vendorId/offers/';
  static String vendorReviewsUrl(String vendorId) =>
      '$baseUrl/api/v1/vendor/$vendorId/reviews/';

  static String get cartUrl => '$baseUrl/api/v1/cart/';
  static String get cartItemsUrl => '$baseUrl/api/v1/cart/items/';
  static String cartItemUrl(String itemId) => '$baseUrl/api/v1/cart/items/$itemId/';
  static String get cartRewardSelectionUrl => '$baseUrl/api/v1/cart/reward-selection/';

  static String get redemptionPreviewUrl => '$baseUrl/api/v1/redemptions/preview/';
  static String get redemptionGenerateUrl => '$baseUrl/api/v1/redemptions/generate/';
  static String get customerRedemptionsUrl => '$baseUrl/api/v1/redemptions/';
  static String redemptionDetailUrl(String qrCode) => '$baseUrl/api/v1/redemptions/$qrCode/';
  static String cancelRedemptionUrl(String qrCode) => '$baseUrl/api/v1/redemptions/$qrCode/cancel/';
}

import '../services/discovery_preferences_service.dart';

/// Central backend configuration for the ZTEEL user app.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'http://68.233.116.23:8000';

  /// Default search radius in kilometers for restaurants and deal feeds.
  static double get defaultSearchRadiusKm =>
      DiscoveryPreferencesService.maxRadiusKm;

  static String get sendOtpUrl => '$baseUrl/api/v1/auth/send-otp/';
  static String get customerVerifyOtpUrl =>
      '$baseUrl/api/v1/auth/customer/verify-otp/';
  static String get logoutUrl => '$baseUrl/api/v1/auth/logout/';
  static String get tokenRefreshUrl => '$baseUrl/api/v1/auth/refresh/';
  static String get meUrl => '$baseUrl/api/v1/auth/me/';
  static String get customerProfileUrl => '$baseUrl/api/v1/profile/';
  static String offerFeedUrl({double? latitude, double? longitude, double? radiusKm}) {
    final params = <String>[];
    if (latitude != null && longitude != null) {
      params.add('latitude=$latitude&longitude=$longitude');
      final radius = radiusKm ?? defaultSearchRadiusKm;
      params.add('radius_km=$radius');
    }
    final query = params.isNotEmpty ? '?${params.join('&')}' : '';
    return '$baseUrl/api/v1/offers/feed/$query';
  }
  static String get foodTagsUrl => '$baseUrl/api/v1/food-tags/';
  static String foodTagVendorsUrl(String tagId, {double? latitude, double? longitude, double? radiusKm, bool? openNow, bool? offersOnly}) {
    final params = <String>[];
    if (latitude != null && longitude != null) {
      params.add('latitude=$latitude&longitude=$longitude');
      final radius = radiusKm ?? defaultSearchRadiusKm;
      params.add('radius_km=$radius');
    }
    if (openNow == true) params.add('open_now=true');
    if (offersOnly == true) params.add('offers_only=true');
    final query = params.isNotEmpty ? '?${params.join('&')}' : '';
    return '$baseUrl/api/v1/food-tags/$tagId/vendors/$query';
  }
  static String foodTagOffersUrl(String tagId, {double? latitude, double? longitude, double? radiusKm, bool? openNow}) {
    final params = <String>[];
    if (latitude != null && longitude != null) {
      params.add('latitude=$latitude&longitude=$longitude');
      final radius = radiusKm ?? defaultSearchRadiusKm;
      params.add('radius_km=$radius');
    }
    if (openNow == true) params.add('open_now=true');
    final query = params.isNotEmpty ? '?${params.join('&')}' : '';
    return '$baseUrl/api/v1/food-tags/$tagId/offers/$query';
  }
  static String vendorFoodTagItemsUrl(String vendorId, String tagId) =>
      '$baseUrl/api/v1/vendors/$vendorId/food-tags/$tagId/';
  static String vendorsListUrl({bool? openNow, double? latitude, double? longitude, double? radiusKm}) {
    final params = <String>[];
    if (openNow == true) params.add('open_now=true');
    if (latitude != null && longitude != null) {
      params.add('latitude=$latitude&longitude=$longitude');
      final radius = radiusKm ?? defaultSearchRadiusKm;
      params.add('radius_km=$radius');
    }
    final query = params.isNotEmpty ? '?${params.join('&')}' : '';
    return '$baseUrl/api/v1/vendors/$query';
  }
  static String get vendorAltListUrl => '$baseUrl/api/v1/vendor/list/';
  static String searchVendorsUrl({
    String query = 'a',
    String filter = 'vendors',
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) {
    final params = <String>['q=$query', 'filter=$filter'];
    if (latitude != null && longitude != null) {
      params.add('latitude=$latitude&longitude=$longitude');
      final radius = radiusKm ?? defaultSearchRadiusKm;
      params.add('radius_km=$radius');
    }
    return '$baseUrl/api/v1/search/?${params.join('&')}';
  }
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

  static String get customerSavedUrl => '$baseUrl/api/v1/profile/saved/';
  static String customerSavedItemUrl(String kind, String targetId) =>
      '$baseUrl/api/v1/profile/saved/$kind/$targetId/';
  static String get customerSavedCollectionsUrl =>
      '$baseUrl/api/v1/profile/saved/collections/';
  static String customerSavedCollectionDetailUrl(String id) =>
      '$baseUrl/api/v1/profile/saved/collections/$id/';
  static String customerSavedCollectionVendorUrl(
          String collectionId, String vendorId) =>
      '$baseUrl/api/v1/profile/saved/collections/$collectionId/vendors/$vendorId/';
}

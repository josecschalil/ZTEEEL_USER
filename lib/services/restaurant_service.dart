import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:zteel_user/config/api_config.dart';
import 'package:zteel_user/services/auth_service.dart';

class RestaurantService {
  RestaurantService._();

  static List<Map<String, dynamic>> _cachedRestaurants = [];
  static final Map<String, Map<String, dynamic>> _vendorCache = {};
  static final Map<String, List<Map<String, dynamic>>> _menuCache = {};
  static final Map<String, List<Map<String, dynamic>>> _offersCache = {};

  static List<Map<String, dynamic>> get cachedRestaurants =>
      List.unmodifiable(_cachedRestaurants);

  static List<Map<String, dynamic>>? getCachedMenu(String vendorId) =>
      _menuCache[vendorId];

  static List<Map<String, dynamic>>? getCachedOffers(String vendorId) =>
      _offersCache[vendorId];

  static Map<String, dynamic>? getCachedVendor(String vendorId) =>
      _vendorCache[vendorId];

  static Future<List<Map<String, dynamic>>> fetchRestaurants({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedRestaurants.isNotEmpty) {
      return _cachedRestaurants;
    }

    final headers = await AuthService.getAuthHeaders();

    // 1. Try public vendor list endpoint (/api/v1/vendors/)
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.vendorsListUrl),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final results = decoded is Map<String, dynamic>
            ? (decoded['results'] ?? decoded['data'])
            : decoded;
        if (results is List && results.isNotEmpty) {
          final list = results
              .whereType<Map>()
              .map((v) => Map<String, dynamic>.from(v))
              .toList();
          _cacheAll(list);
          return list;
        }
      }
    } catch (_) {}

    // 2. Try alternate vendor list endpoint (/api/v1/vendor/list/)
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.vendorAltListUrl),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final results = decoded is Map<String, dynamic>
            ? (decoded['results'] ?? decoded['data'])
            : decoded;
        if (results is List && results.isNotEmpty) {
          final list = results
              .whereType<Map>()
              .map((v) => Map<String, dynamic>.from(v))
              .toList();
          _cacheAll(list);
          return list;
        }
      }
    } catch (_) {}

    // 3. Try offer feed to discover vendors
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.offerFeedUrl),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final results = decoded is Map<String, dynamic>
            ? (decoded['results'] ?? decoded['data'])
            : decoded;
        if (results is List && results.isNotEmpty) {
          final vendorIds = <String>{};
          final offersByVendor = <String, Map<String, dynamic>>{};

          for (final offer in results.whereType<Map>()) {
            final vendorObj = offer['vendor'];
            String? vendorId;
            if (vendorObj is Map && vendorObj['id'] != null) {
              vendorId = vendorObj['id'].toString();
            } else if (vendorObj is String && vendorObj.isNotEmpty) {
              vendorId = vendorObj;
            }
            if (vendorId != null && vendorId.isNotEmpty) {
              vendorIds.add(vendorId);
              offersByVendor.putIfAbsent(
                vendorId,
                () => Map<String, dynamic>.from(offer),
              );
            }
          }

          if (vendorIds.isNotEmpty) {
            final vendors = <Map<String, dynamic>>[];
            for (final id in vendorIds) {
              final v = await fetchVendor(id);
              if (v != null) {
                if (v['best_offer'] == null && offersByVendor.containsKey(id)) {
                  v['best_offer'] = offersByVendor[id];
                }
                vendors.add(v);
              }
            }
            if (vendors.isNotEmpty) {
              _cacheAll(vendors);
              return vendors;
            }
          }
        }
      }
    } catch (_) {}

    // 4. Try search endpoint
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.searchVendorsUrl),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final results = decoded is Map<String, dynamic>
            ? (decoded['results'] ?? decoded['data'])
            : decoded;
        if (results is List && results.isNotEmpty) {
          final list = results
              .whereType<Map>()
              .map((v) => Map<String, dynamic>.from(v))
              .toList();
          _cacheAll(list);
          return list;
        }
      }
    } catch (_) {}

    return _cachedRestaurants;
  }

  static Future<Map<String, dynamic>?> fetchVendor(
    String vendorId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _vendorCache.containsKey(vendorId)) {
      return _vendorCache[vendorId];
    }
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.vendorDetailUrl(vendorId)),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          _vendorCache[vendorId] = decoded;
          return decoded;
        }
      }
    } catch (_) {}
    return _vendorCache[vendorId];
  }

  static Future<List<Map<String, dynamic>>> fetchVendorMenu(
    String vendorId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _menuCache.containsKey(vendorId)) {
      return _menuCache[vendorId]!;
    }
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.vendorMenuUrl(vendorId)),
        headers: headers,
      );
      if (response.statusCode != 200) return _menuCache[vendorId] ?? const [];
      final decoded = jsonDecode(response.body);
      final results = decoded is Map<String, dynamic>
          ? (decoded['results'] ?? decoded['data'])
          : decoded;
      if (results is! List) return _menuCache[vendorId] ?? const [];
      final list = results
          .whereType<Map>()
          .map((category) => Map<String, dynamic>.from(category))
          .toList();
      _menuCache[vendorId] = list;
      return list;
    } catch (_) {
      return _menuCache[vendorId] ?? const [];
    }
  }

  static Future<List<Map<String, dynamic>>> fetchVendorOffers(
    String vendorId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _offersCache.containsKey(vendorId)) {
      return _offersCache[vendorId]!;
    }
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.vendorOffersUrl(vendorId)),
        headers: headers,
      );
      if (response.statusCode != 200) return _offersCache[vendorId] ?? const [];
      final decoded = jsonDecode(response.body);
      final results = decoded is Map<String, dynamic>
          ? (decoded['results'] ?? decoded['data'])
          : decoded;
      if (results is! List) return _offersCache[vendorId] ?? const [];
      final list = results
          .whereType<Map>()
          .map((offer) => Map<String, dynamic>.from(offer))
          .toList();
      _offersCache[vendorId] = list;
      return list;
    } catch (_) {
      return _offersCache[vendorId] ?? const [];
    }
  }

  static void _cacheAll(List<Map<String, dynamic>> list) {
    _cachedRestaurants = list;
    for (final v in list) {
      final id = v['id']?.toString();
      if (id != null && id.isNotEmpty) {
        _vendorCache[id] = v;
      }
    }
  }
}

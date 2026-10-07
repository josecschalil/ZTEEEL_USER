import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zteel_user/config/api_config.dart';
import 'package:zteel_user/services/auth_service.dart';
import 'package:zteel_user/services/location_service.dart';

class RestaurantService {
  RestaurantService._();

  static const String _kRestaurantsCacheKey = 'cached_restaurants_v1';
  static const Duration _kTimeout = Duration(seconds: 4);

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

  /// Loads cached restaurants from local storage for instant cold-boot startup.
  static Future<List<Map<String, dynamic>>> loadCachedRestaurants() async {
    if (_cachedRestaurants.isNotEmpty) {
      return _cachedRestaurants;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kRestaurantsCacheKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          final list = decoded
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
          if (list.isNotEmpty) {
            _cacheAll(list, persist: false);
          }
        }
      }
    } catch (_) {}
    return _cachedRestaurants;
  }

  static Future<List<Map<String, dynamic>>> fetchRestaurants({
    bool forceRefresh = false,
    bool? openNow,
  }) async {
    if (!forceRefresh && _cachedRestaurants.isNotEmpty) {
      if (openNow == true) {
        return _cachedRestaurants
            .where((v) =>
                v['is_open_now'] == true ||
                v['is_open'] == true ||
                v['isOpen'] == true ||
                v['open_now'] == true)
            .toList();
      }
      return _cachedRestaurants;
    }

    final headers = await AuthService.getAuthHeaders();
    final location = await LocationService.load();

    // 1. Try public vendor list endpoint (/api/v1/vendors/)
    try {
      final response = await http
          .get(
            Uri.parse(
              ApiConfig.vendorsListUrl(
                openNow: openNow,
                latitude: location?.latitude,
                longitude: location?.longitude,
              ),
            ),
            headers: headers,
          )
          .timeout(_kTimeout);
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
          if (openNow != true) {
            _cacheAll(list, persist: true);
          }
          return list;
        }
      }
    } catch (_) {}

    // 2. Try alternate vendor list endpoint (/api/v1/vendor/list/)
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.vendorAltListUrl),
            headers: headers,
          )
          .timeout(_kTimeout);
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
          _cacheAll(list, persist: true);
          return list;
        }
      }
    } catch (_) {}

    // 3. Try offer feed to discover vendors in parallel
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.offerFeedUrl()),
            headers: headers,
          )
          .timeout(_kTimeout);
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
            final vendorResults = await Future.wait(
              vendorIds.map((id) => fetchVendor(id)),
            );
            final vendors = <Map<String, dynamic>>[];
            for (final v in vendorResults) {
              if (v != null) {
                final id = v['id']?.toString() ?? '';
                if (v['best_offer'] == null && offersByVendor.containsKey(id)) {
                  v['best_offer'] = offersByVendor[id];
                }
                vendors.add(v);
              }
            }
            if (vendors.isNotEmpty) {
              _cacheAll(vendors, persist: true);
              return vendors;
            }
          }
        }
      }
    } catch (_) {}

    // 4. Try search endpoint
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.searchVendorsUrl),
            headers: headers,
          )
          .timeout(_kTimeout);
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
          _cacheAll(list, persist: true);
          return list;
        }
      }
    } catch (_) {}

    if (_cachedRestaurants.isEmpty) {
      await loadCachedRestaurants();
    }
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
      final response = await http
          .get(
            Uri.parse(ApiConfig.vendorDetailUrl(vendorId)),
            headers: headers,
          )
          .timeout(_kTimeout);
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
      final response = await http
          .get(
            Uri.parse(ApiConfig.vendorMenuUrl(vendorId)),
            headers: headers,
          )
          .timeout(_kTimeout);
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

  /// Fetches a menu that is safe to use for a time-sensitive availability
  /// decision. Unlike [fetchVendorMenu], this never falls back to cached data.
  static Future<List<Map<String, dynamic>>?> fetchLiveVendorMenu(
    String vendorId,
  ) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.vendorMenuUrl(vendorId)),
        headers: headers,
      );
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body);
      final results = decoded is Map<String, dynamic>
          ? (decoded['results'] ?? decoded['data'])
          : decoded;
      if (results is! List) return null;
      final menu = results
          .whereType<Map>()
          .map((category) => Map<String, dynamic>.from(category))
          .toList();
      _menuCache[vendorId] = menu;
      return menu;
    } catch (_) {
      return null;
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
      final response = await http
          .get(
            Uri.parse(ApiConfig.vendorOffersUrl(vendorId)),
            headers: headers,
          )
          .timeout(_kTimeout);
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

  static void _cacheAll(List<Map<String, dynamic>> list, {bool persist = false}) {
    _cachedRestaurants = list;
    for (final v in list) {
      final id = v['id']?.toString();
      if (id != null && id.isNotEmpty) {
        _vendorCache[id] = v;
      }
    }
    if (persist && list.isNotEmpty) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString(_kRestaurantsCacheKey, jsonEncode(list));
      }).catchError((_) {});
    }
  }

  static Future<Map<String, dynamic>?> fetchVendorReviews(
    String vendorId,
  ) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http
          .get(
            Uri.parse(ApiConfig.vendorReviewsUrl(vendorId)),
            headers: headers,
          )
          .timeout(_kTimeout);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>> submitVendorReview({
    required String vendorId,
    required int rating,
    required String comment,
    String? userName,
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final fullHeaders = {
        ...headers,
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({
        'rating': rating,
        'comment': comment,
        if (userName != null && userName.isNotEmpty) 'user_name': userName,
      });

      final response = await http
          .post(
            Uri.parse(ApiConfig.vendorReviewsUrl(vendorId)),
            headers: fullHeaders,
            body: body,
          )
          .timeout(_kTimeout);
      final decoded = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': decoded};
      }
      return {
        'success': false,
        'error': decoded is Map
            ? (decoded['detail'] ?? decoded['message'] ?? 'Failed to submit review')
            : 'Failed to submit review',
      };
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
}


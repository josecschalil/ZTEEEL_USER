import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zteel_user/config/api_config.dart';
import 'package:zteel_user/services/location_service.dart';

class OfferService {
  OfferService._();

  static const String _kOffersCacheKey = 'cached_offers_feed_v1';
  static const Duration _kTimeout = Duration(seconds: 4);

  static List<Map<String, dynamic>> _cachedOffers = [];

  static List<Map<String, dynamic>> get cachedOffers =>
      List.unmodifiable(_cachedOffers);

  /// Loads cached offers from local storage for instant cold-boot startup.
  static Future<List<Map<String, dynamic>>> loadCachedOffers() async {
    if (_cachedOffers.isNotEmpty) {
      return _cachedOffers;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kOffersCacheKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          final list = decoded
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
          if (list.isNotEmpty) {
            _cachedOffers = list;
          }
        }
      }
    } catch (_) {}
    return _cachedOffers;
  }

  static Future<List<Map<String, dynamic>>> fetchOffers({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedOffers.isNotEmpty) {
      return _cachedOffers;
    }

    try {
      final location = await LocationService.load();
      final response = await http
          .get(
            Uri.parse(
              ApiConfig.offerFeedUrl(
                latitude: location?.latitude,
                longitude: location?.longitude,
              ),
            ),
          )
          .timeout(_kTimeout);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final results = decoded is Map<String, dynamic>
            ? decoded['results']
            : decoded;
        if (results is List) {
          final list = results
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
          _cachedOffers = list;
          SharedPreferences.getInstance().then((prefs) {
            prefs.setString(_kOffersCacheKey, jsonEncode(list));
          }).catchError((_) {});
          return list;
        }
      }
    } catch (_) {}

    if (_cachedOffers.isEmpty) {
      await loadCachedOffers();
    }
    return _cachedOffers;
  }

  static Future<Map<String, dynamic>?> fetchVendor(String vendorId) async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.vendorDetailUrl(vendorId)))
          .timeout(_kTimeout);
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchVendorMenu(
    String vendorId,
  ) async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.vendorMenuUrl(vendorId)))
          .timeout(_kTimeout);
      if (response.statusCode != 200) return const [];
      final decoded = jsonDecode(response.body);
      final results = decoded is Map<String, dynamic>
          ? decoded['results']
          : decoded;
      return results is List
          ? results
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList()
          : const [];
    } catch (_) {
      return const [];
    }
  }
}

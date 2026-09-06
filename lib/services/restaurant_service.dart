import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:zteel_user/config/api_config.dart';

class RestaurantService {
  RestaurantService._();

  /// Builds a public restaurant feed from the existing offer feed and public
  /// vendor-detail endpoint. An empty list lets the UI retain its local
  /// fallback content when the backend has no currently promoted restaurants.
  static Future<List<Map<String, dynamic>>> fetchRestaurants() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.offerFeedUrl));
      if (response.statusCode != 200) return const [];

      final decoded = jsonDecode(response.body);
      final results = decoded is Map<String, dynamic>
          ? decoded['results']
          : decoded;
      if (results is! List) return const [];

      final vendorIds = results
          .whereType<Map>()
          .map((offer) => offer['vendor']?.toString())
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toSet();

      final vendors = await Future.wait(
        vendorIds.map((id) => _fetchVendor(id)),
      );
      return vendors.whereType<Map<String, dynamic>>().toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<Map<String, dynamic>?> _fetchVendor(String vendorId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.vendorDetailUrl(vendorId)),
      );
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
      final response = await http.get(
        Uri.parse(ApiConfig.vendorMenuUrl(vendorId)),
      );
      if (response.statusCode != 200) return const [];
      final decoded = jsonDecode(response.body);
      final results = decoded is Map<String, dynamic>
          ? decoded['results']
          : decoded;
      if (results is! List) return const [];
      return results
          .whereType<Map>()
          .map((category) => Map<String, dynamic>.from(category))
          .toList();
    } catch (_) {
      return const [];
    }
  }
}

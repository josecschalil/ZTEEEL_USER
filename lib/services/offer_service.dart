import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:zteel_user/config/api_config.dart';

class OfferService {
  OfferService._();

  static Future<List<Map<String, dynamic>>> fetchOffers() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.offerFeedUrl));
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

  static Future<Map<String, dynamic>?> fetchVendor(String vendorId) async {
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

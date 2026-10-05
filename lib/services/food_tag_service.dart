import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class FoodTag {
  final String id;
  final String name;
  final String slug;
  final String? imageUrl;
  final int matchingVendorCount;

  const FoodTag({
    required this.id,
    required this.name,
    required this.slug,
    this.imageUrl,
    this.matchingVendorCount = 0,
  });

  factory FoodTag.fromJson(Map<String, dynamic> json) {
    final rawImage = json['image']?.toString().trim() ?? '';
    return FoodTag(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString().trim() ?? '',
      slug: json['slug']?.toString().trim() ?? '',
      imageUrl: rawImage.isEmpty ? null : resolveImage(rawImage),
      matchingVendorCount:
          int.tryParse(json['matching_vendor_count']?.toString() ?? '') ?? 0,
    );
  }

  static String resolveImage(String image) {
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return image;
    }
    return '${ApiConfig.baseUrl}${image.startsWith('/') ? '' : '/'}$image';
  }
}

class FoodTagService {
  FoodTagService._();

  static Future<List<FoodTag>> fetchFoodTags() async {
    final values = await _fetchRows(ApiConfig.foodTagsUrl);
    return values
        .map(FoodTag.fromJson)
        .where((tag) => tag.id.isNotEmpty && tag.name.isNotEmpty)
        .toList();
  }

  static Future<List<Map<String, dynamic>>> fetchTagVendors(
    String tagId,
  ) async {
    return _fetchRows(ApiConfig.foodTagVendorsUrl(tagId));
  }

  static Future<List<Map<String, dynamic>>> fetchTagOffers(String tagId) async {
    return _fetchRows(ApiConfig.foodTagOffersUrl(tagId));
  }

  static Future<List<Map<String, dynamic>>> fetchVendorTagItems(
    String vendorId,
    String tagId,
  ) async {
    return _fetchRows(ApiConfig.vendorFoodTagItemsUrl(vendorId, tagId));
  }

  static Future<List<Map<String, dynamic>>> _fetchRows(String url) async {
    try {
      final rows = <Map<String, dynamic>>[];
      final visited = <String>{};
      String? nextUrl = url;
      while (nextUrl != null && visited.add(nextUrl)) {
        final response = await http.get(Uri.parse(nextUrl));
        if (response.statusCode != 200) break;
        final decoded = jsonDecode(response.body);
        final values = decoded is Map<String, dynamic>
            ? decoded['results']
            : decoded;
        if (values is! List) break;
        rows.addAll(
          values.whereType<Map>().map(
            (value) => Map<String, dynamic>.from(value),
          ),
        );
        final rawNext = decoded is Map<String, dynamic>
            ? decoded['next']?.toString().trim()
            : null;
        nextUrl = rawNext == null || rawNext.isEmpty
            ? null
            : rawNext.startsWith('http')
            ? rawNext
            : '${ApiConfig.baseUrl}${rawNext.startsWith('/') ? '' : '/'}$rawNext';
      }
      return rows;
    } catch (_) {
      return const [];
    }
  }
}

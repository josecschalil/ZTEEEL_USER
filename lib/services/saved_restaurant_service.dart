import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'auth_service.dart';

class SavedCollection {
  final String id;
  final String name;
  final String icon;
  final String description;
  final int vendorCount;

  const SavedCollection({
    required this.id,
    required this.name,
    this.icon = '',
    this.description = '',
    this.vendorCount = 0,
  });

  factory SavedCollection.fromJson(Map<String, dynamic> json) {
    return SavedCollection(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString().trim() ?? '',
      icon: json['icon']?.toString().trim() ?? '',
      description: json['description']?.toString().trim() ?? '',
      vendorCount: int.tryParse(json['vendor_count']?.toString() ?? '') ?? 0,
    );
  }
}

class SavedRestaurant {
  final String id;
  final String name;
  final String cuisine;
  final double rating;
  final int reviewCount;
  final int priceLevel;
  final double distanceKm;
  final String imageUrl;
  final bool isOpen;
  final List<String> collections;
  final List<String> collectionIds;

  const SavedRestaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.reviewCount,
    required this.priceLevel,
    required this.distanceKm,
    required this.imageUrl,
    required this.isOpen,
    required this.collections,
    this.collectionIds = const [],
  });

  String get priceTag => '\$' * priceLevel;

  factory SavedRestaurant.fromBackendVendor(Map<String, dynamic> vendor) {
    final id = vendor['id']?.toString() ?? '';
    final name = vendor['business_name']?.toString().trim() ?? 'Restaurant';

    String cuisine = 'Multi-Cuisine';
    if (vendor['cuisines'] is List && (vendor['cuisines'] as List).isNotEmpty) {
      cuisine = (vendor['cuisines'] as List).join(' · ');
    } else if (vendor['shop_description']?.toString().trim().isNotEmpty == true) {
      cuisine = vendor['shop_description']!.toString().trim();
    } else if (vendor['category']?.toString().trim().isNotEmpty == true) {
      cuisine = vendor['category']!.toString().trim();
    }

    final rating = double.tryParse(
      vendor['rating']?.toString() ?? vendor['average_rating']?.toString() ?? '',
    ) ?? 4.8;
    final reviewCount = int.tryParse(
      vendor['review_count']?.toString() ?? vendor['rating_count']?.toString() ?? '',
    ) ?? 120;
    final distanceKm = double.tryParse(vendor['distance_km']?.toString() ?? '') ?? 1.2;

    final image = vendor['cover_image'] ?? vendor['icon_image'];
    final imageUrl = image is String && image.isNotEmpty
        ? (image.startsWith('http://') || image.startsWith('https://')
            ? image
            : '${ApiConfig.baseUrl}${image.startsWith('/') ? '' : '/'}$image')
        : 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=600';

    final isOpen = vendor['is_open_now'] is bool
        ? vendor['is_open_now'] as bool
        : (vendor['is_open'] is bool
            ? vendor['is_open'] as bool
            : true);

    final collections = <String>[];
    if (vendor['saved_collection_names'] is List) {
      for (final c in vendor['saved_collection_names'] as List) {
        if (c != null && c.toString().isNotEmpty) {
          collections.add(c.toString());
        }
      }
    }

    final collectionIds = <String>[];
    if (vendor['saved_collection_ids'] is List) {
      for (final cid in vendor['saved_collection_ids'] as List) {
        if (cid != null && cid.toString().isNotEmpty) {
          collectionIds.add(cid.toString());
        }
      }
    }

    return SavedRestaurant(
      id: id,
      name: name,
      cuisine: cuisine,
      rating: rating,
      reviewCount: reviewCount,
      priceLevel: 2,
      distanceKm: distanceKm,
      imageUrl: imageUrl,
      isOpen: isOpen,
      collections: collections,
      collectionIds: collectionIds,
    );
  }
}

class SavedRestaurantService {
  SavedRestaurantService._();

  static final ValueNotifier<Set<String>> savedVendorIdsNotifier =
      ValueNotifier<Set<String>>({});

  static final ValueNotifier<List<SavedCollection>> savedCollectionsNotifier =
      ValueNotifier<List<SavedCollection>>([]);

  static List<SavedRestaurant> cachedSavedRestaurants = [];

  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Fetches saved restaurants & collections from `/api/v1/profile/saved/`
  static Future<List<SavedRestaurant>> fetchSavedRestaurants({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && cachedSavedRestaurants.isNotEmpty) {
      return cachedSavedRestaurants;
    }

    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.customerSavedUrl),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          if (decoded['collections'] is List) {
            final colList = (decoded['collections'] as List)
                .whereType<Map<String, dynamic>>()
                .map(SavedCollection.fromJson)
                .toList();
            savedCollectionsNotifier.value = colList;
          }

          if (decoded['vendors'] is List) {
            final vendorList = (decoded['vendors'] as List)
                .whereType<Map<String, dynamic>>()
                .map(SavedRestaurant.fromBackendVendor)
                .toList();

            cachedSavedRestaurants = vendorList;
            savedVendorIdsNotifier.value = vendorList.map((r) => r.id).toSet();
            return vendorList;
          }
        }
      }
    } catch (e) {
      debugPrint('SavedRestaurantService fetchSavedRestaurants error: $e');
    }

    return cachedSavedRestaurants;
  }

  /// Fetches all user-created collections
  static Future<List<SavedCollection>> fetchCollections() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse(ApiConfig.customerSavedCollectionsUrl),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is List) {
          final colList = decoded
              .whereType<Map<String, dynamic>>()
              .map(SavedCollection.fromJson)
              .toList();
          savedCollectionsNotifier.value = colList;
          return colList;
        }
      }
    } catch (e) {
      debugPrint('SavedRestaurantService fetchCollections error: $e');
    }
    return savedCollectionsNotifier.value;
  }

  /// Creates a new custom collection/list
  static Future<SavedCollection?> createCollection(
    String name, {
    String icon = '',
    String description = '',
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.customerSavedCollectionsUrl),
        headers: headers,
        body: jsonEncode({
          'name': name.trim(),
          'icon': icon.trim(),
          'description': description.trim(),
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final created = SavedCollection.fromJson(decoded);
          final updated = List<SavedCollection>.from(savedCollectionsNotifier.value)
            ..removeWhere((c) => c.id == created.id)
            ..insert(0, created);
          savedCollectionsNotifier.value = updated;
          return created;
        }
      }
    } catch (e) {
      debugPrint('SavedRestaurantService createCollection error: $e');
    }
    return null;
  }

  /// Deletes a custom collection
  static Future<bool> deleteCollection(String collectionId) async {
    try {
      final headers = await _authHeaders();
      final response = await http.delete(
        Uri.parse(ApiConfig.customerSavedCollectionDetailUrl(collectionId)),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final updated = List<SavedCollection>.from(savedCollectionsNotifier.value)
          ..removeWhere((c) => c.id == collectionId);
        savedCollectionsNotifier.value = updated;
        return true;
      }
    } catch (e) {
      debugPrint('SavedRestaurantService deleteCollection error: $e');
    }
    return false;
  }

  /// Adds a vendor to a collection
  static Future<bool> addVendorToCollection(
    String collectionId,
    String vendorId,
  ) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse(
          ApiConfig.customerSavedCollectionVendorUrl(collectionId, vendorId),
        ),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final current = Set<String>.from(savedVendorIdsNotifier.value)..add(vendorId);
        savedVendorIdsNotifier.value = current;
        return true;
      }
    } catch (e) {
      debugPrint('SavedRestaurantService addVendorToCollection error: $e');
    }
    return false;
  }

  /// Removes a vendor from a collection
  static Future<bool> removeVendorFromCollection(
    String collectionId,
    String vendorId,
  ) async {
    try {
      final headers = await _authHeaders();
      final response = await http.delete(
        Uri.parse(
          ApiConfig.customerSavedCollectionVendorUrl(collectionId, vendorId),
        ),
        headers: headers,
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('SavedRestaurantService removeVendorFromCollection error: $e');
    }
    return false;
  }

  /// Saves a restaurant to bookmarks with optional collection links
  static Future<bool> saveRestaurant(
    String vendorId, {
    List<String>? collectionIds,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse(ApiConfig.customerSavedItemUrl('vendors', vendorId)),
        headers: headers,
        body: jsonEncode({
          if (collectionIds != null && collectionIds.isNotEmpty)
            'collection_ids': collectionIds,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final current = Set<String>.from(savedVendorIdsNotifier.value)..add(vendorId);
        savedVendorIdsNotifier.value = current;
        return true;
      }
    } catch (e) {
      debugPrint('SavedRestaurantService saveRestaurant error: $e');
    }
    return false;
  }

  /// Removes a restaurant from bookmarks
  static Future<bool> removeSavedRestaurant(String vendorId) async {
    try {
      final headers = await _authHeaders();
      final response = await http.delete(
        Uri.parse(ApiConfig.customerSavedItemUrl('vendors', vendorId)),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final current = Set<String>.from(savedVendorIdsNotifier.value)..remove(vendorId);
        savedVendorIdsNotifier.value = current;
        cachedSavedRestaurants.removeWhere((r) => r.id == vendorId);
        return true;
      }
    } catch (e) {
      debugPrint('SavedRestaurantService removeSavedRestaurant error: $e');
    }
    return false;
  }

  /// Toggles saved status
  static Future<bool> toggleSaveRestaurant(
    String vendorId, {
    required bool currentlySaved,
    List<String>? collectionIds,
  }) async {
    if (currentlySaved) {
      return await removeSavedRestaurant(vendorId);
    } else {
      return await saveRestaurant(vendorId, collectionIds: collectionIds);
    }
  }
}

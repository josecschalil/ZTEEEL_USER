import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import 'auth_service.dart';

/// Data model representing a saved/wishlisted dish or food item.
class WishlistItem {
  final String id;
  final String vendorId;
  final String restaurant;
  final String name;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final String category;
  final String tag;
  final double rating;
  final double distance;
  final String? description;
  final DateTime? createdAt;

  const WishlistItem({
    required this.id,
    this.vendorId = '',
    this.restaurant = 'Restaurant',
    required this.name,
    required this.price,
    this.originalPrice,
    this.imageUrl = '',
    this.category = 'all',
    this.tag = 'Bestseller',
    this.rating = 4.8,
    this.distance = 1.0,
    this.description,
    this.createdAt,
  });

  bool get hasDiscount =>
      originalPrice != null && originalPrice! > price && (originalPrice! - price) > 0.01;

  double get savings => hasDiscount ? (originalPrice! - price) : 0.0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'vendor_id': vendorId,
    'restaurant': restaurant,
    'name': name,
    'price': price,
    'original_price': originalPrice,
    'image_url': imageUrl,
    'category': category,
    'tag': tag,
    'rating': rating,
    'distance': distance,
    'description': description,
    'created_at': createdAt?.toIso8601String(),
  };

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    final rawImage =
        json['image_url']?.toString() ??
        json['image']?.toString() ??
        json['cover_image']?.toString() ??
        '';
    String resolvedImage = rawImage;
    if (rawImage.isNotEmpty &&
        !rawImage.startsWith('http://') &&
        !rawImage.startsWith('https://')) {
      resolvedImage =
          '${ApiConfig.baseUrl}${rawImage.startsWith('/') ? '' : '/'}$rawImage';
    }

    final vendorObj = json['vendor'] is Map<String, dynamic>
        ? json['vendor'] as Map<String, dynamic>
        : null;

    final vId =
        json['vendor_id']?.toString() ??
        vendorObj?['id']?.toString() ??
        '';
    final restName =
        json['restaurant']?.toString() ??
        vendorObj?['business_name']?.toString() ??
        json['vendor_name']?.toString() ??
        'Restaurant';

    final parsedPrice =
        double.tryParse(json['price']?.toString() ?? '') ??
        double.tryParse(json['discounted_price']?.toString() ?? '') ??
        double.tryParse(json['unit_price']?.toString() ?? '') ??
        0.0;

    final parsedOriginalPrice =
        double.tryParse(json['original_price']?.toString() ?? '') ??
        (json['has_discount'] == true && json['raw_price'] != null
            ? double.tryParse(json['raw_price'].toString())
            : null);

    return WishlistItem(
      id: json['id']?.toString() ?? json['menu_item_id']?.toString() ?? '',
      vendorId: vId,
      restaurant: restName,
      name:
          json['name']?.toString() ??
          json['item_name']?.toString() ??
          json['dish_name']?.toString() ??
          'Dish',
      price: parsedPrice,
      originalPrice: parsedOriginalPrice,
      imageUrl: resolvedImage,
      category: json['category']?.toString().toLowerCase().trim() ?? 'all',
      tag: json['tag']?.toString() ?? json['badge']?.toString() ?? 'Bestseller',
      rating:
          double.tryParse(json['rating']?.toString() ?? '') ??
          double.tryParse(json['average_rating']?.toString() ?? '') ??
          4.8,
      distance:
          double.tryParse(json['distance']?.toString() ?? '') ??
          double.tryParse(json['distance_km']?.toString() ?? '') ??
          1.0,
      description: json['description']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  WishlistItem copyWith({
    String? id,
    String? vendorId,
    String? restaurant,
    String? name,
    double? price,
    double? originalPrice,
    String? imageUrl,
    String? category,
    String? tag,
    double? rating,
    double? distance,
    String? description,
    DateTime? createdAt,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      restaurant: restaurant ?? this.restaurant,
      name: name ?? this.name,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      tag: tag ?? this.tag,
      rating: rating ?? this.rating,
      distance: distance ?? this.distance,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Service managing persistent wishlisted food items with offline caching & backend sync.
class WishlistService {
  WishlistService._();

  static const String _prefsKey = 'cached_wishlist_items_v1';

  /// Live notifier holding list of currently wishlisted items.
  static final ValueNotifier<List<WishlistItem>> wishlistNotifier =
      ValueNotifier<List<WishlistItem>>([]);

  /// Fast lookup set for item IDs currently in wishlist.
  static final ValueNotifier<Set<String>> wishlistedItemIdsNotifier =
      ValueNotifier<Set<String>>({});

  static bool _isLoaded = false;

  /// Returns active wishlisted items snapshot.
  static List<WishlistItem> get items => wishlistNotifier.value;

  /// Checks if a food item is currently in the wishlist.
  static bool isInWishlist(String itemId) {
    if (itemId.isEmpty) return false;
    return wishlistedItemIdsNotifier.value.contains(itemId);
  }

  /// Internal helper to sync in-memory state and dispatch notifications.
  static void _updateState(List<WishlistItem> newItems) {
    wishlistNotifier.value = List.unmodifiable(newItems);
    wishlistedItemIdsNotifier.value = Set.unmodifiable(
      newItems.map((item) => item.id).where((id) => id.isNotEmpty),
    );
  }

  /// Persists current list to local storage.
  static Future<void> _persistToLocal(List<WishlistItem> newItems) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = newItems.map((i) => i.toJson()).toList();
      await prefs.setString(_prefsKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('WishlistService persist error: $e');
    }
  }

  /// Loads wishlist from local cache first, then syncs with remote backend if authenticated.
  static Future<List<WishlistItem>> loadWishlist({
    bool forceRefresh = false,
    http.Client? client,
  }) async {
    if (_isLoaded && !forceRefresh && wishlistNotifier.value.isNotEmpty) {
      return wishlistNotifier.value;
    }

    // 1. Read local cached items
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          final loaded = decoded
              .whereType<Map<String, dynamic>>()
              .map(WishlistItem.fromJson)
              .toList();
          _updateState(loaded);
          _isLoaded = true;
        }
      }
    } catch (e) {
      debugPrint('WishlistService load cache error: $e');
    }

    // 2. Fetch from backend if token exists
    try {
      final token = await AuthService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        final reqClient = client ?? http.Client();
        final response = await reqClient.get(
          Uri.parse(ApiConfig.customerSavedUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            final dynamic rawList =
                decoded['items'] ??
                decoded['saved_items'] ??
                decoded['dishes'] ??
                decoded['food_items'];

            if (rawList is List) {
              final remoteItems = rawList
                  .whereType<Map<String, dynamic>>()
                  .map(WishlistItem.fromJson)
                  .toList();

              // Merge local items with remote items by ID
              final Map<String, WishlistItem> mergedMap = {};
              for (final itm in wishlistNotifier.value) {
                if (itm.id.isNotEmpty) mergedMap[itm.id] = itm;
              }
              for (final itm in remoteItems) {
                if (itm.id.isNotEmpty) mergedMap[itm.id] = itm;
              }

              final mergedList = mergedMap.values.toList();
              _updateState(mergedList);
              await _persistToLocal(mergedList);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('WishlistService remote sync error: $e');
    }

    _isLoaded = true;
    return wishlistNotifier.value;
  }

  /// Toggles an item in the wishlist: adds if not present, removes if present.
  static Future<bool> toggleWishlist(
    WishlistItem item, {
    http.Client? client,
  }) async {
    if (isInWishlist(item.id)) {
      return !(await removeFromWishlist(item.id, client: client));
    } else {
      return await addToWishlist(item, client: client);
    }
  }

  /// Adds an item to the wishlist (optimistic local update + background remote sync).
  static Future<bool> addToWishlist(
    WishlistItem item, {
    http.Client? client,
  }) async {
    if (item.id.isEmpty) return false;

    // Optimistic local update
    final current = List<WishlistItem>.from(wishlistNotifier.value);
    current.removeWhere((i) => i.id == item.id);
    current.insert(0, item);
    _updateState(current);
    await _persistToLocal(current);

    // Background backend sync
    try {
      final token = await AuthService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        final reqClient = client ?? http.Client();
        await reqClient.post(
          Uri.parse(ApiConfig.customerSavedItemUrl('items', item.id)),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(item.toJson()),
        );
      }
    } catch (e) {
      debugPrint('WishlistService addToWishlist sync error: $e');
    }

    return true;
  }

  /// Removes an item from the wishlist (optimistic local update + background remote sync).
  static Future<bool> removeFromWishlist(
    String itemId, {
    http.Client? client,
  }) async {
    if (itemId.isEmpty) return false;

    // Optimistic local update
    final current = List<WishlistItem>.from(wishlistNotifier.value);
    final initialLen = current.length;
    current.removeWhere((i) => i.id == itemId);
    if (current.length != initialLen) {
      _updateState(current);
      await _persistToLocal(current);
    }

    // Background backend sync
    try {
      final token = await AuthService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        final reqClient = client ?? http.Client();
        await reqClient.delete(
          Uri.parse(ApiConfig.customerSavedItemUrl('items', itemId)),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (e) {
      debugPrint('WishlistService removeFromWishlist sync error: $e');
    }

    return true;
  }

  /// Clears the entire local wishlist.
  static Future<void> clearWishlist() async {
    _updateState([]);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
    } catch (e) {
      debugPrint('WishlistService clear error: $e');
    }
  }

  /// Injects test or seeded default items.
  static void setMockItems(List<WishlistItem> mockItems) {
    _isLoaded = true;
    _updateState(mockItems);
  }
}

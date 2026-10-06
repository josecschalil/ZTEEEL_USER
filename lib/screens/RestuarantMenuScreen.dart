import '../app_colors.dart';
import 'package:flutter/material.dart';
import 'OfferExplanationScreen.dart';
import 'FoodItemPage.dart';
import 'CheckOutScreen.dart';
import '../config/api_config.dart';
import '../services/cart_service.dart';
import '../services/restaurant_service.dart';

abstract final class MenuColors {
  static const Color primary = AppColors.primary;
  static const Color primarySoft = AppColors.primarySoft;
  static const Color primaryDeep = AppColors.primaryDeep;
  static const Color cardDark = AppColors.cardDark;
  static const Color textMutedDark = AppColors.textMutedDark;
  static const Color borderDark = AppColors.borderDark;
}


/// ---------------------------------------------------------------------
/// Data models
/// ---------------------------------------------------------------------
class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final double discountedPrice;
  final String imageUrl;
  final String? badge; // e.g. "30% OFF", "BESTSELLER", "COMBO"
  final String? tag; // e.g. "VEG", "NON-VEG"
  final String? offerTitle;
  final double? discountPercentage;
  final List<String> foodTags;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.discountedPrice,
    required this.imageUrl,
    this.badge,
    this.tag,
    this.offerTitle,
    this.discountPercentage,
    this.foodTags = const [],
  });

  bool get hasDiscount => discountedPrice < (price - 0.009);
}

class MenuCategory {
  final String id;
  final String title;
  final List<MenuItem> items;
  const MenuCategory({
    required this.id,
    required this.title,
    required this.items,
  });
}

class OfferCard {
  final String id;
  final String badgeLabel;
  final String timer;
  final String headline;
  final String subline;
  final String fineprint;
  final String code;
  final List<Color> gradient;
  final double discountPercentage;
  final String scopeType;
  final List<String> itemIds;
  final List<String> categoryIds;
  final List<OfferApplicableItem> applicableItems;

  const OfferCard({
    required this.id,
    required this.badgeLabel,
    required this.timer,
    required this.headline,
    required this.subline,
    required this.fineprint,
    required this.code,
    required this.gradient,
    required this.discountPercentage,
    this.scopeType = 'all_menu',
    this.itemIds = const [],
    this.categoryIds = const [],
    this.applicableItems = const [],
  });
}

class VendorDetailData {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String description;
  final String imageUrl;
  final bool isOpen;
  final String openingHours;
  final List<String> tags;
  final double rating;
  final int reviewCount;
  final String distance;

  const VendorDetailData({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.description,
    required this.imageUrl,
    required this.isOpen,
    required this.openingHours,
    required this.tags,
    required this.rating,
    required this.reviewCount,
    required this.distance,
  });
}

/// Shared offer palette for restaurant and home offer cards.
const List<List<Color>> restaurantOfferGradients = [
  [AppColors.primary, AppColors.toneFFEA580C],
  [AppColors.toneFF9333EA, AppColors.toneFF4F46E5],
  [AppColors.toneFF0D9488, AppColors.toneFF0284C7],
  [AppColors.toneFFE11D48, AppColors.toneFFC026D3],
  [AppColors.toneFFD97706, AppColors.toneFFEA580C],
];

List<MenuCategory> _mapCategories(
  List<Map<String, dynamic>> categoryData,
  List<Map<String, dynamic>> offersData,
) {
  final categories = <MenuCategory>[];

  // Pre-index offers for O(1) matching
  double maxAllMenuDiscount = 0.0;
  String? allMenuOfferTitle;
  final Map<String, (double discount, String title)> itemOfferIndex = {};
  final Map<String, (double discount, String title)> categoryOfferIndex = {};

  for (final offer in offersData) {
    final discount = double.tryParse(offer['discount_percentage']?.toString() ?? '') ?? 0.0;
    if (discount <= 0) continue;
    final title = offer['title']?.toString() ?? '';
    final scopeType = offer['scope_type']?.toString() ?? 'all_menu';

    if (scopeType == 'all_menu') {
      if (discount > maxAllMenuDiscount) {
        maxAllMenuDiscount = discount;
        allMenuOfferTitle = title;
      }
    }

    if (offer['item_ids'] is List) {
      for (final id in offer['item_ids'] as List) {
        final idStr = id?.toString();
        if (idStr != null) {
          final existing = itemOfferIndex[idStr];
          if (existing == null || discount > existing.$1) {
            itemOfferIndex[idStr] = (discount, title);
          }
        }
      }
    }

    if (offer['category_ids'] is List) {
      for (final id in offer['category_ids'] as List) {
        final idStr = id?.toString();
        if (idStr != null) {
          final existing = categoryOfferIndex[idStr];
          if (existing == null || discount > existing.$1) {
            categoryOfferIndex[idStr] = (discount, title);
          }
        }
      }
    }
  }

  for (final category in categoryData) {
    final itemData = category['menu_items'];
    if (itemData is! List || itemData.isEmpty) continue;

    final categoryId = category['id']?.toString() ?? '';
    final categoryName = category['name']?.toString().trim() ?? 'Menu';
    final items = <MenuItem>[];

    for (final item in itemData.whereType<Map>()) {
      final id = item['id']?.toString() ?? '';
      final name = item['name']?.toString().trim() ?? 'Dish';
      final description = item['description']?.toString().trim() ?? '';
      final rawPrice = double.tryParse(item['price']?.toString() ?? '') ?? 0.0;
      final image = _resolveImageUrl(item['image']?.toString() ?? '');

      // Extract food tags
      final foodTagList = <String>[];
      if (item['food_tags'] is List) {
        for (final tagObj in (item['food_tags'] as List).whereType<Map>()) {
          final tagName = tagObj['name']?.toString() ?? '';
          if (tagName.isNotEmpty) foodTagList.add(tagName);
        }
      }

      // Check Best Offer
      Map<String, dynamic>? bestOfferMap;
      if (item['best_offer'] is Map<String, dynamic>) {
        bestOfferMap = Map<String, dynamic>.from(item['best_offer']);
      } else if (item['best_offer'] is Map) {
        bestOfferMap = Map<String, dynamic>.from(item['best_offer'] as Map);
      }

      double? discountPct;
      String? offerTitle;
      if (bestOfferMap != null) {
        discountPct = double.tryParse(bestOfferMap['discount_percentage']?.toString() ?? '');
        offerTitle = bestOfferMap['title']?.toString();
      }

      // Calculate or read discounted price (best offer with highest discount)
      double discountedPrice = rawPrice;
      if (item['discounted_price'] != null) {
        final parsed = double.tryParse(item['discounted_price'].toString());
        if (parsed != null) {
          discountedPrice = parsed;
        }
      } else if (discountPct != null && discountPct > 0) {
        discountedPrice = rawPrice * (1.0 - (discountPct / 100.0));
      }

      // Check pre-indexed offers if best_offer was null
      if (bestOfferMap == null && offersData.isNotEmpty) {
        double bestDis = maxAllMenuDiscount;
        String? bestTitle = allMenuOfferTitle;

        final catOffer = categoryOfferIndex[categoryId];
        if (catOffer != null && catOffer.$1 > bestDis) {
          bestDis = catOffer.$1;
          bestTitle = catOffer.$2;
        }

        final itemOffer = itemOfferIndex[id];
        if (itemOffer != null && itemOffer.$1 > bestDis) {
          bestDis = itemOffer.$1;
          bestTitle = itemOffer.$2;
        }

        if (bestDis > 0) {
          discountPct = bestDis;
          offerTitle = bestTitle;
          discountedPrice = rawPrice * (1.0 - (bestDis / 100.0));
        }
      }

      // Tag determination (VEG / NON-VEG)
      String? itemTag;
      final lowerName = name.toLowerCase();
      final lowerDesc = description.toLowerCase();
      final lowerTags = foodTagList.map((t) => t.toLowerCase()).toList();

      final isExplicitNonVeg = lowerTags.any((t) => t.contains('non-veg') || t.contains('meat') || t.contains('chicken') || t.contains('mutton') || t.contains('fish') || t.contains('beef') || t.contains('pork') || t.contains('egg')) ||
          lowerName.contains('chicken') || lowerName.contains('mutton') || lowerName.contains('fish') || lowerName.contains('beef') || lowerName.contains('pork') || lowerName.contains('egg') || lowerName.contains('calamari') || lowerName.contains('prawn') ||
          lowerDesc.contains('chicken') || lowerDesc.contains('meat') || lowerDesc.contains('mutton') || lowerDesc.contains('beef') || lowerDesc.contains('fish') || lowerDesc.contains('pork');

      final isExplicitVeg = lowerTags.any((t) => (t.contains('veg') && !t.contains('non-veg')) || t.contains('vegan') || t.contains('paneer') || t.contains('salad') || t.contains('pizza')) ||
          lowerName.contains('veg') || lowerName.contains('paneer') || lowerName.contains('mushroom') || lowerName.contains('salad') || lowerName.contains('bruschetta') ||
          lowerDesc.contains('vegetarian') || lowerDesc.contains('fresh vegetable') || lowerDesc.contains('paneer');

      if (isExplicitNonVeg) {
        itemTag = 'NON-VEG';
      } else if (isExplicitVeg) {
        itemTag = 'VEG';
      } else {
        itemTag = 'VEG';
      }

      // Badge determination
      String? badge;
      if (discountPct != null && discountPct > 0) {
        badge = '${discountPct.toInt()}% OFF';
      } else if (item['item_type'] == 'combo') {
        badge = 'COMBO';
      }

      items.add(
        MenuItem(
          id: id,
          name: name,
          description: description,
          price: rawPrice,
          discountedPrice: discountedPrice,
          imageUrl: image,
          badge: badge,
          tag: itemTag,
          offerTitle: offerTitle,
          discountPercentage: discountPct,
          foodTags: foodTagList,
        ),
      );
    }

    if (items.isNotEmpty) {
      categories.add(
        MenuCategory(
          id: categoryId,
          title: categoryName,
          items: items,
        ),
      );
    }
  }

  return categories;
}

List<OfferCard> _mapOffers(
  List<Map<String, dynamic>> offersData,
  List<MenuCategory> categories,
) {
  final cards = <OfferCard>[];
  var gradientIndex = 0;

  for (final offer in offersData) {
    final id = offer['id']?.toString() ?? '';
    final title = offer['title']?.toString().trim() ?? 'Special Offer';
    final desc = offer['description']?.toString().trim() ?? '';
    final discount = double.tryParse(offer['discount_percentage']?.toString() ?? '') ?? 0.0;
    final endsAt = offer['ends_at']?.toString();
    final gradient = restaurantOfferGradients[
        gradientIndex % restaurantOfferGradients.length];
    gradientIndex++;

    final scopeType = offer['scope_type']?.toString() ?? 'all_menu';

    final itemIds = <String>{};
    final categoryIds = <String>{};

    if (offer['targets'] is Map) {
      final targets = offer['targets'] as Map;
      if (targets['item_ids'] is List) {
        for (final x in targets['item_ids'] as List) {
          if (x != null) itemIds.add(x.toString());
        }
      }
      if (targets['category_ids'] is List) {
        for (final x in targets['category_ids'] as List) {
          if (x != null) categoryIds.add(x.toString());
        }
      }
    }
    if (offer['item_ids'] is List) {
      for (final x in offer['item_ids'] as List) {
        if (x != null) itemIds.add(x.toString());
      }
    }
    if (offer['category_ids'] is List) {
      for (final x in offer['category_ids'] as List) {
        if (x != null) categoryIds.add(x.toString());
      }
    }

    final applicableItems = <OfferApplicableItem>[];
    for (final category in categories) {
      final isCategoryTarget = scopeType == 'category_set' && categoryIds.contains(category.id);

      for (final item in category.items) {
        bool matches = false;
        if (scopeType == 'all_menu') {
          matches = true;
        } else if (isCategoryTarget) {
          matches = true;
        } else if (scopeType == 'item_set' && itemIds.contains(item.id)) {
          matches = true;
        } else if (item.offerTitle == title || (discount > 0 && item.discountPercentage == discount)) {
          matches = true;
        }

        if (matches) {
          final calculatedDiscountedPrice = (item.price * (1.0 - (discount / 100.0))).clamp(0.0, item.price);
          final bestPrice = item.hasDiscount
              ? item.discountedPrice
              : (discount > 0 ? calculatedDiscountedPrice : item.price);

          applicableItems.add(
            OfferApplicableItem(
              id: item.id,
              name: item.name,
              description: item.description,
              price: item.price,
              discountedPrice: bestPrice,
              imageUrl: item.imageUrl,
              badge: discount > 0 ? '${discount.toInt()}% OFF' : item.badge,
              tag: item.tag,
              categoryName: category.title,
            ),
          );
        }
      }
    }

    String timer = 'Limited Time';
    if (endsAt != null && endsAt.isNotEmpty) {
      try {
        final date = DateTime.parse(endsAt);
        final diff = date.difference(DateTime.now());
        if (!diff.isNegative) {
          final hours = diff.inHours.toString().padLeft(2, '0');
          final mins = (diff.inMinutes % 60).toString().padLeft(2, '0');
          timer = '$hours:$mins left';
        } else {
          timer = 'Ongoing';
        }
      } catch (_) {
        timer = 'Limited Offer';
      }
    }

    final headline = discount > 0 ? '${discount.toInt()}% OFF' : title;
    final subline = desc.isNotEmpty
        ? desc
        : (discount > 0 ? 'Auto-applied on $title' : 'Auto-applied on menu items');
    final code = 'SAVE${discount.toInt() > 0 ? discount.toInt() : ''}';

    cards.add(
      OfferCard(
        id: id,
        badgeLabel: discount > 0 ? '${discount.toInt()}% OFF' : 'DEAL',
        timer: timer,
        headline: headline,
        subline: subline,
        fineprint: 'Discount automatically applied to menu items',
        code: code,
        gradient: gradient,
        discountPercentage: discount,
        scopeType: scopeType,
        itemIds: itemIds.toList(),
        categoryIds: categoryIds.toList(),
        applicableItems: applicableItems,
      ),
    );
  }

  return cards;
}

String _resolveImageUrl(String image) {
  if (image.isEmpty) return '';
  if (image.startsWith('http://') || image.startsWith('https://')) return image;
  return '${ApiConfig.baseUrl}${image.startsWith('/') ? '' : '/'}$image';
}

String _formatBusinessHours(List<dynamic>? businessHours, bool isOpen) {
  if (businessHours == null || businessHours.isEmpty) {
    return isOpen ? 'Open Now • 10:00 AM – 11:00 PM' : 'Closed';
  }

  try {
    for (final day in businessHours) {
      if (day is Map && day['is_closed'] == false && day['slots'] is List && (day['slots'] as List).isNotEmpty) {
        final slot = (day['slots'] as List).first as Map;
        final opens = slot['opens_at']?.toString().substring(0, 5) ?? '10:00';
        final closes = slot['closes_at']?.toString().substring(0, 5) ?? '22:00';
        final status = isOpen ? 'Open Now' : 'Closed';
        return '$status • $opens – $closes (Mon - Sun)';
      }
    }
  } catch (_) {}

  return isOpen ? 'Open Now' : 'Closed';
}

/// ---------------------------------------------------------------------
/// Main screen
/// ---------------------------------------------------------------------
class RestaurantMenuScreen extends StatefulWidget {
  final String? vendorId;
  final String? restaurantName;
  final String? heroImageUrl;
  final String? cuisine;
  final bool? isOpen;

  const RestaurantMenuScreen({
    super.key,
    this.vendorId,
    this.restaurantName,
    this.heroImageUrl,
    this.cuisine,
    this.isOpen,
  });

  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  Map<String, int> _cart = {}; // itemId -> quantity
  int _tabIndex = 0; // Menu / Offers / Reviews / Info
  String _selectedPill = 'All Items';
  late final PageController _pageController;

  bool _isLoading = true;
  List<MenuCategory> _menuCategories = [];
  List<OfferCard> _vendorOffers = [];
  VendorDetailData? _vendorDetail;
  Map<String, dynamic>? _reviewsSummary;
  bool _isLoadingReviews = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _tabIndex);
    _initializeVendorInfo();
    _loadInitialCachedData();
    _loadData();
    _syncFromGlobalCart();
    CartService.cartNotifier.addListener(_syncFromGlobalCart);
    CartService.basketsNotifier.addListener(_syncFromGlobalCart);
  }

  void _loadInitialCachedData() {
    final vendorId = widget.vendorId;
    if (vendorId == null || vendorId.isEmpty) return;

    final cachedMenu = RestaurantService.getCachedMenu(vendorId);
    final cachedOffers = RestaurantService.getCachedOffers(vendorId);
    final cachedVendor = RestaurantService.getCachedVendor(vendorId);

    if (cachedMenu != null && cachedMenu.isNotEmpty) {
      final offersList = cachedOffers ?? const [];
      final parsedCategories = _mapCategories(cachedMenu, offersList);
      final parsedOffers = _mapOffers(offersList, parsedCategories);

      _menuCategories = parsedCategories;
      _vendorOffers = parsedOffers;
      _isLoading = false;

      if (cachedVendor != null) {
        _applyVendorDetail(cachedVendor, parsedCategories);
      }
    }
  }

  Future<void> _loadReviews() async {
    final vendorId = widget.vendorId;
    if (vendorId == null || vendorId.isEmpty) return;
    setState(() => _isLoadingReviews = true);
    final summary = await RestaurantService.fetchVendorReviews(vendorId);
    if (!mounted) return;
    setState(() {
      _reviewsSummary = summary;
      _isLoadingReviews = false;
      if (summary != null && _vendorDetail != null) {
        final rawRating = summary['rating'];
        final r = rawRating is num ? rawRating.toDouble() : double.tryParse(rawRating?.toString() ?? '');
        final rawCount = summary['review_count'];
        final c = rawCount is num ? rawCount.toInt() : int.tryParse(rawCount?.toString() ?? '');
        if (r != null && c != null) {
          _vendorDetail = VendorDetailData(
            id: _vendorDetail!.id,
            name: _vendorDetail!.name,
            address: _vendorDetail!.address,
            phone: _vendorDetail!.phone,
            description: _vendorDetail!.description,
            imageUrl: _vendorDetail!.imageUrl,
            isOpen: _vendorDetail!.isOpen,
            openingHours: _vendorDetail!.openingHours,
            tags: _vendorDetail!.tags,
            rating: r > 0 ? r : _vendorDetail!.rating,
            reviewCount: c,
            distance: _vendorDetail!.distance,
          );
        }
      }
    });
  }

  void _applyVendorDetail(Map<String, dynamic> vendorData, List<MenuCategory> categories) {
    final businessName = vendorData['business_name']?.toString() ?? widget.restaurantName ?? 'Restaurant';
    final address = vendorData['address']?.toString() ?? '';
    final phone = vendorData['phone_number']?.toString() ?? '';
    final desc = vendorData['shop_description']?.toString() ?? '';
    final coverImg = _resolveImageUrl(vendorData['cover_image']?.toString() ?? vendorData['icon_image']?.toString() ?? '');
    final isOpen = vendorData['is_open_now'] as bool? ?? widget.isOpen ?? true;
    final hoursStr = _formatBusinessHours(vendorData['business_hours'] as List<dynamic>?, isOpen);

    final rawRating = vendorData['rating'];
    final ratingVal = rawRating is num ? rawRating.toDouble() : double.tryParse(rawRating?.toString() ?? '') ?? 4.8;
    final rawCount = vendorData['review_count'];
    final reviewCountVal = rawCount is num ? rawCount.toInt() : int.tryParse(rawCount?.toString() ?? '') ?? 0;

    final featureList = <String>[];
    if (widget.cuisine?.isNotEmpty == true) featureList.add(widget.cuisine!);
    for (final cat in categories) {
      if (!featureList.contains(cat.title)) featureList.add(cat.title);
    }
    if (featureList.isEmpty) featureList.addAll(['Fresh Food', 'Fast Prep', 'Hygiene Verified']);

    _vendorDetail = VendorDetailData(
      id: widget.vendorId ?? '',
      name: businessName,
      address: address.isNotEmpty ? address : 'Address details on order',
      phone: phone,
      description: desc.isNotEmpty ? desc : 'Serving freshly made premium dishes with authentic recipes.',
      imageUrl: coverImg.isNotEmpty ? coverImg : (widget.heroImageUrl ?? ''),
      isOpen: isOpen,
      openingHours: hoursStr,
      tags: featureList,
      rating: ratingVal > 0 ? ratingVal : 4.8,
      reviewCount: reviewCountVal,
      distance: '1.8 km',
    );
  }

  void _syncFromGlobalCart() {
    if (!mounted) return;
    final currentVendorId = widget.vendorId ?? _vendorDetail?.id;
    if (currentVendorId == null || currentVendorId.isEmpty) return;

    final basket = CartService.getBasket(currentVendorId);
    if (basket != null && basket.isNotEmpty) {
      final updatedCart = <String, int>{};
      for (final item in basket.items) {
        final key = item.menuItemId.isNotEmpty ? item.menuItemId : item.id;
        updatedCart[key] = item.quantity;
      }
      setState(() {
        _cart = updatedCart;
      });
      return;
    }

    final current = CartService.currentCart;
    if (current != null && (current.vendor == null || current.vendor?.id == currentVendorId) && current.isNotEmpty) {
      final updatedCart = <String, int>{};
      for (final item in current.items) {
        final key = item.menuItemId.isNotEmpty ? item.menuItemId : item.id;
        updatedCart[key] = item.quantity;
      }
      setState(() {
        _cart = updatedCart;
      });
    } else {
      if (_cart.isNotEmpty) {
        setState(() {
          _cart = {};
        });
      }
    }
  }

  void _initializeVendorInfo() {
    _vendorDetail = VendorDetailData(
      id: widget.vendorId ?? '',
      name: widget.restaurantName ?? 'Restaurant',
      address: 'Restaurant Address',
      phone: '',
      description: 'Authentic flavors and fresh dishes prepared daily.',
      imageUrl: widget.heroImageUrl ?? '',
      isOpen: widget.isOpen ?? true,
      openingHours: (widget.isOpen ?? true) ? 'Open Now • 10:00 AM – 11:00 PM' : 'Closed',
      tags: widget.cuisine?.isNotEmpty == true ? [widget.cuisine!] : ['Multi-Cuisine'],
      rating: 4.8,
      reviewCount: 142,
      distance: '1.5 km',
    );
  }

  Future<void> _loadData() async {
    final vendorId = widget.vendorId;
    if (vendorId == null || vendorId.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (_menuCategories.isEmpty) {
      setState(() => _isLoading = true);
    }

    try {
      final results = await Future.wait([
        RestaurantService.fetchVendorMenu(vendorId, forceRefresh: true),
        RestaurantService.fetchVendorOffers(vendorId, forceRefresh: true),
        RestaurantService.fetchVendor(vendorId, forceRefresh: true),
        RestaurantService.fetchVendorReviews(vendorId),
      ]);

      if (!mounted) return;

      final menuData = results[0] as List<Map<String, dynamic>>;
      final offersData = results[1] as List<Map<String, dynamic>>;
      final vendorData = results[2] as Map<String, dynamic>?;
      final reviewsData = results[3] as Map<String, dynamic>?;

      final parsedCategories = _mapCategories(menuData, offersData);
      final parsedOffers = _mapOffers(offersData, parsedCategories);

      if (vendorData != null) {
        _applyVendorDetail(vendorData, parsedCategories);
      }

      if (reviewsData != null && _vendorDetail != null) {
        final rawRating = reviewsData['rating'];
        final r = rawRating is num ? rawRating.toDouble() : double.tryParse(rawRating?.toString() ?? '');
        final rawCount = reviewsData['review_count'];
        final c = rawCount is num ? rawCount.toInt() : int.tryParse(rawCount?.toString() ?? '');
        if (r != null && c != null && r > 0) {
          _vendorDetail = VendorDetailData(
            id: _vendorDetail!.id,
            name: _vendorDetail!.name,
            address: _vendorDetail!.address,
            phone: _vendorDetail!.phone,
            description: _vendorDetail!.description,
            imageUrl: _vendorDetail!.imageUrl,
            isOpen: _vendorDetail!.isOpen,
            openingHours: _vendorDetail!.openingHours,
            tags: _vendorDetail!.tags,
            rating: r,
            reviewCount: c,
            distance: _vendorDetail!.distance,
          );
        }
      }

      setState(() {
        _menuCategories = parsedCategories;
        _vendorOffers = parsedOffers;
        _reviewsSummary = reviewsData;
        _isLoading = false;
      });
      _syncFromGlobalCart();
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  MenuItem? _findMenuItem(String id) {
    for (final cat in _menuCategories) {
      for (final itm in cat.items) {
        if (itm.id == id) return itm;
      }
    }
    return null;
  }

  @override
  void dispose() {
    CartService.cartNotifier.removeListener(_syncFromGlobalCart);
    CartService.basketsNotifier.removeListener(_syncFromGlobalCart);
    _pageController.dispose();
    super.dispose();
  }

  double get _cartTotal {
    final currentVendorId = widget.vendorId ?? _vendorDetail?.id;
    final basket = CartService.getBasket(currentVendorId);
    if (basket != null && basket.isNotEmpty) {
      return basket.finalTotal > 0 ? basket.finalTotal : basket.subtotal;
    }
    final current = CartService.currentCart;
    if (current != null && (current.vendor == null || current.vendor?.id == currentVendorId) && current.isNotEmpty) {
      return current.finalTotal > 0 ? current.finalTotal : current.subtotal;
    }
    double total = 0;
    for (final category in _menuCategories) {
      for (final item in category.items) {
        final qty = _cart[item.id] ?? 0;
        total += qty * item.discountedPrice;
      }
    }
    return total;
  }

  int get _cartCount {
    final currentVendorId = widget.vendorId ?? _vendorDetail?.id;
    final basket = CartService.getBasket(currentVendorId);
    if (basket != null && basket.isNotEmpty) {
      return basket.totalItemCount;
    }
    final current = CartService.currentCart;
    if (current != null && (current.vendor == null || current.vendor?.id == currentVendorId) && current.isNotEmpty) {
      return current.totalItemCount;
    }
    return _cart.values.fold(0, (sum, q) => sum + q);
  }

  Future<void> _addItem(String id) async {
    final currentQty = _cart[id] ?? 0;
    final newQty = currentQty + 1;
    setState(() => _cart[id] = newQty);

    final item = _findMenuItem(id);
    final vendorId = widget.vendorId ?? _vendorDetail?.id;

    final res = await CartService.addItem(
      menuItemId: id,
      quantity: 1,
      vendorId: vendorId,
      vendorName: _vendorDetail?.name,
      vendorCoverImage: _vendorDetail?.imageUrl,
      itemName: item?.name,
      unitPrice: item?.price,
      discountedPrice: item?.discountedPrice,
      itemImage: item?.imageUrl,
      itemDescription: item?.description,
    );
    if (!mounted) return;

    if (res['conflict'] == true) {
      final shouldClear = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Start New Basket?'),
          content: const Text(
            'Your cart currently contains items from another restaurant. Would you like to clear your cart and start fresh with this order?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Start New', style: TextStyle(color: AppColors.white)),
            ),
          ],
        ),
      );

      if (shouldClear == true) {
        await CartService.clearCart();
        final retryRes = await CartService.addItem(
          menuItemId: id,
          quantity: 1,
          vendorId: vendorId,
          vendorName: _vendorDetail?.name,
          vendorCoverImage: _vendorDetail?.imageUrl,
          itemName: item?.name,
          unitPrice: item?.price,
          discountedPrice: item?.discountedPrice,
          itemImage: item?.imageUrl,
          itemDescription: item?.description,
        );
        if (mounted && retryRes['success'] == true) {
          setState(() {
            _cart = {id: 1};
          });
        }
      } else {
        setState(() {
          if (currentQty <= 0) {
            _cart.remove(id);
          } else {
            _cart[id] = currentQty;
          }
        });
      }
    }
  }

  Future<void> _setItemQuantity(String id, int targetQty) async {
    if (targetQty <= 0) {
      await _removeItem(id);
      return;
    }

    setState(() => _cart[id] = targetQty);
    final vendorId = widget.vendorId ?? _vendorDetail?.id;
    final item = _findMenuItem(id);

    await CartService.setItemQuantity(
      vendorId: vendorId ?? '',
      menuItemId: id,
      targetQuantity: targetQty,
      itemName: item?.name,
      unitPrice: item?.price,
      discountedPrice: item?.discountedPrice,
      itemImage: item?.imageUrl,
    );
  }

  Future<void> _removeItem(String id) async {
    final current = _cart[id] ?? 0;
    if (current <= 0) return;

    final newQty = current - 1;
    setState(() {
      if (newQty <= 0) {
        _cart.remove(id);
      } else {
        _cart[id] = newQty;
      }
    });

    final vendorId = widget.vendorId ?? _vendorDetail?.id;
    if (newQty <= 0) {
      await CartService.removeItem(id, vendorId: vendorId);
    } else {
      await CartService.updateQuantity(
        cartItemId: id,
        quantity: newQty,
        vendorId: vendorId,
      );
    }
  }

  void _proceedToCheckout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(vendorId: widget.vendorId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgDark : AppColors.bgLight;

    final vendor = _vendorDetail!;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _loadData,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: _HeroSection(
                      isDark: isDark,
                      restaurantName: vendor.name,
                      imageUrl: vendor.imageUrl,
                      cuisine: vendor.tags.join(', '),
                      isOpen: vendor.isOpen,
                      rating: vendor.rating,
                      reviewCount: vendor.reviewCount,
                      distance: vendor.distance,
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabsHeaderDelegate(
                      selectedIndex: _tabIndex,
                      offersCount: _vendorOffers.length,
                      isDark: isDark,
                      onSelect: (i) {
                        setState(() => _tabIndex = i);
                        _pageController.animateToPage(
                          i,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                ];
              },
              body: PageView(
                controller: _pageController,
                onPageChanged: (i) {
                  setState(() => _tabIndex = i);
                },
                children: [
                  _MenuView(
                    selectedPill: _selectedPill,
                    onSelectPill: (p) => setState(() => _selectedPill = p),
                    categories: _menuCategories,
                    offers: _vendorOffers,
                    cart: _cart,
                    isLoading: _isLoading,
                    isDark: isDark,
                    onAdd: _addItem,
                    onRemove: _removeItem,
                    onSetQuantity: _setItemQuantity,
                    restaurantName: vendor.name,
                  ),
                  _OffersView(
                    offers: _vendorOffers,
                    isDark: isDark,
                    restaurantName: vendor.name,
                    cart: _cart,
                    onAdd: _addItem,
                    onRemove: _removeItem,
                  ),
                  _ReviewsView(
                    vendorId: vendor.id,
                    vendorName: vendor.name,
                    rating: vendor.rating,
                    reviewCount: vendor.reviewCount,
                    isDark: isDark,
                    reviewsSummary: _reviewsSummary,
                    isLoading: _isLoadingReviews,
                    onRefresh: _loadReviews,
                  ),
                  _InfoView(
                    vendor: vendor,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
          // Fixed top action buttons over the hero image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _TopActionBar(isDark: isDark),
          ),
          // Floating "View Cart" button bar
          if (_cartCount > 0)
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: _ViewCartButton(
                count: _cartCount,
                total: _cartTotal,
                onTap: _proceedToCheckout,
              ),
            ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Fixed top bar: back / search / share
/// ---------------------------------------------------------------------
class _TopActionBar extends StatelessWidget {
  final bool isDark;
  const _TopActionBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 12,
        20,
        16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.black.withValues(alpha: 0.6), AppColors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _RoundIconButton(
            icon: Icons.chevron_left_rounded,
            size: 16,
            isDark: isDark,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          Row(
            children: [
              _RoundIconButton(icon: Icons.search_rounded, isDark: isDark),
              const SizedBox(width: 10),
              _RoundIconButton(icon: Icons.share_rounded, isDark: isDark),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final bool isDark;
  final VoidCallback? onTap;

  const _RoundIconButton({
    required this.icon,
    required this.isDark,
    this.size = 16,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark
              ? AppColors.black.withValues(alpha: 0.6)
              : AppColors.white.withValues(alpha: 0.9),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.toneFFEEEEEE,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isDark ? AppColors.white : AppColors.textPrimary,
          size: size,
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Hero image + restaurant info
/// ---------------------------------------------------------------------
class _HeroSection extends StatelessWidget {
  final bool isDark;
  final String restaurantName;
  final String imageUrl;
  final String cuisine;
  final bool isOpen;
  final double rating;
  final int reviewCount;
  final String distance;

  const _HeroSection({
    required this.isDark,
    required this.restaurantName,
    required this.imageUrl,
    required this.cuisine,
    required this.isOpen,
    required this.rating,
    required this.reviewCount,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? AppColors.bgDark : AppColors.bgLight;

    return SizedBox(
      height: 280,
      child: Stack(
        fit: StackFit.expand,
        children: [
          imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: isDark ? AppColors.cardDark : AppColors.materialGrey[300],
                    child: const Icon(Icons.restaurant_rounded, size: 60, color: AppColors.materialGrey),
                  ),
                )
              : Container(
                  color: isDark ? AppColors.cardDark : AppColors.materialGrey[300],
                  child: const Icon(Icons.restaurant_rounded, size: 60, color: AppColors.materialGrey),
                ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  bgColor,
                  bgColor.withValues(alpha: 0.5),
                  AppColors.transparent,
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          restaurantName,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.white
                                : AppColors.textPrimary,
                            letterSpacing: -0.4,
                            height: 1.1,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: (isOpen ? AppColors.vegGreen : AppColors.nonVegRed).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: (isOpen ? AppColors.vegGreen : AppColors.nonVegRed).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          isOpen ? 'OPEN NOW' : 'CLOSED',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isOpen ? AppColors.vegGreen : AppColors.nonVegRed,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: TextStyle(
                          color: isDark
                              ? AppColors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        ' ($reviewCount)',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.materialGrey[500],
                          fontSize: 13,
                        ),
                      ),
                      _Dot(isDark: isDark),
                      Flexible(
                        child: Text(
                          cuisine.isNotEmpty ? cuisine : 'Food & Beverages',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.materialGrey[700],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      _Dot(isDark: isDark),
                      Text(
                        distance,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool isDark;
  const _Dot({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? AppColors.white30 : AppColors.materialGrey[400],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Sticky tabs header: Menu / Offers / Reviews / Info
/// ---------------------------------------------------------------------
class _TabsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final int selectedIndex;
  final int offersCount;
  final bool isDark;
  final ValueChanged<int> onSelect;
  static const _tabs = ['Menu', 'Offers', 'Reviews', 'Info'];

  _TabsHeaderDelegate({
    required this.selectedIndex,
    required this.offersCount,
    required this.isDark,
    required this.onSelect,
  });

  @override
  double get minExtent => 46;

  @override
  double get maxExtent => 46;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final bgColor = isDark ? AppColors.bgDark : AppColors.bgLight;
    final borderColor = isDark
        ? AppColors.borderDark
        : AppColors.border;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final selected = i == selectedIndex;
          return Expanded(
            child: InkWell(
              onTap: () => onSelect(i),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected ? AppColors.primary : AppColors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _tabs[i],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selected
                            ? AppColors.primary
                            : (isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.materialGrey[500]),
                      ),
                    ),
                    if (_tabs[i] == 'Offers' && offersCount > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$offersCount',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabsHeaderDelegate oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.offersCount != offersCount ||
        oldDelegate.isDark != isDark;
  }
}

/// ---------------------------------------------------------------------
/// Category filter pills (All Items / Starters / Main Course / ...)
/// ---------------------------------------------------------------------
class _CategoryPills extends StatelessWidget {
  final String selected;
  final bool isDark;
  final List<String> labels;
  final ValueChanged<String> onSelect;
  const _CategoryPills({
    required this.selected,
    required this.isDark,
    required this.labels,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: labels.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final label = labels[i];
          final isSelected = label == selected;
          return InkWell(
            onTap: () => onSelect(label),
            borderRadius: BorderRadius.circular(999),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.cardDark : AppColors.white),
                borderRadius: BorderRadius.circular(999),
                border: isSelected
                    ? null
                    : Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.border,
                      ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? AppColors.white
                      : (isDark
                            ? AppColors.textMutedDark
                            : AppColors.toneFF2D2D2D),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// "Today's Offers" horizontal scroll
/// ---------------------------------------------------------------------
class _TodaysOffers extends StatelessWidget {
  final List<OfferCard> offers;
  final bool isDark;
  final String restaurantName;
  final Map<String, int> cart;
  final ValueChanged<String>? onAdd;
  final ValueChanged<String>? onRemove;

  const _TodaysOffers({
    required this.offers,
    required this.isDark,
    this.restaurantName = 'Restaurant',
    this.cart = const {},
    this.onAdd,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Offers 🔥",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                '${offers.length} Active',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 136,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: offers.length,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, i) => _OfferCardWidget(
                offer: offers[i],
                restaurantName: restaurantName,
                cart: cart,
                onAdd: onAdd,
                onRemove: onRemove,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferCardWidget extends StatelessWidget {
  final OfferCard offer;
  final String restaurantName;
  final Map<String, int> cart;
  final ValueChanged<String>? onAdd;
  final ValueChanged<String>? onRemove;

  const _OfferCardWidget({
    required this.offer,
    this.restaurantName = 'Restaurant',
    this.cart = const {},
    this.onAdd,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OfferExplanationScreen(
              title: offer.headline,
              subtitle: offer.subline,
              code: offer.code,
              badge: offer.badgeLabel,
              expiry: offer.timer,
              gradientColors: offer.gradient,
              applicableItems: offer.applicableItems,
              restaurantName: restaurantName,
              initialCart: cart,
              onAdd: onAdd,
              onRemove: onRemove,
              terms: const [
                'Discount applies automatically to eligible items on the menu.',
                'The maximum discount is always selected if multiple offers apply.',
                'No separate promo code redemption is needed in cart or checkout.',
                'Valid at participating store hours and availability.',
              ],
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: offer.gradient,
            ),
            boxShadow: [
              BoxShadow(
                color: offer.gradient.first.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -24,
                bottom: -24,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          offer.badgeLabel,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.black.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              color: AppColors.white,
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              offer.timer,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.headline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        offer.subline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Menu category section + item cards
/// ---------------------------------------------------------------------
class _CategorySection extends StatelessWidget {
  final MenuCategory category;
  final Map<String, int> cart;
  final bool isDark;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;
  final void Function(String id, int quantity)? onSetQuantity;

  const _CategorySection({
    required this.category,
    required this.cart,
    required this.isDark,
    required this.onAdd,
    required this.onRemove,
    this.onSetQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                category.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.toneFFEEEEEE,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${category.items.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textMutedDark : AppColors.materialGrey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Column(
            children: category.items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 26),
                    child: _MenuItemCard(
                      item: item,
                      categoryName: category.title,
                      quantity: cart[item.id] ?? 0,
                      isDark: isDark,
                      onAdd: () => onAdd(item.id),
                      onRemove: () => onRemove(item.id),
                      onSetQuantity: onSetQuantity != null
                          ? (qty) => onSetQuantity!(item.id, qty)
                          : null,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final String categoryName;
  final int quantity;
  final bool isDark;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final ValueChanged<int>? onSetQuantity;

  const _MenuItemCard({
    required this.item,
    required this.categoryName,
    required this.quantity,
    required this.isDark,
    required this.onAdd,
    required this.onRemove,
    this.onSetQuantity,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.cardDark : AppColors.white;
    final cardBorder = isDark ? AppColors.borderDark : AppColors.border;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FoodItemPage(
              id: item.id,
              name: item.name,
              category: categoryName,
              price: item.discountedPrice,
              originalPrice: item.hasDiscount ? item.price : null,
              description: item.description,
              isVeg: item.tag == 'VEG',
              isBestseller: item.badge != null || item.hasDiscount,
              rating: '4.8',
              photos: item.imageUrl.isNotEmpty ? [item.imageUrl] : const [],
              initialQuantity: quantity > 0 ? quantity : 1,
              onAddToCart: (targetQty) async {
                if (onSetQuantity != null) {
                  onSetQuantity!(targetQty);
                } else {
                  await CartService.addItem(menuItemId: item.id, quantity: targetQty);
                }
              },
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? AppColors.black.withValues(alpha: 0.2)
                  : AppColors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left: text content ──────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // VEG / NON-VEG dot indicator + Badge Row
                  Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          border: Border.all(
                            color: item.tag == 'VEG'
                                ? AppColors.materialGreen
                                : AppColors.toneFFB91C1C,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Center(
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: item.tag == 'VEG'
                                  ? AppColors.materialGreen
                                  : AppColors.toneFFB91C1C,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      if (item.badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.badge!,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Name
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      color: isDark ? AppColors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Description
                  if (item.description.isNotEmpty)
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.45,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMuted,
                      ),
                    ),
                  const SizedBox(height: 12),
                  // Price Section (showing original price & best discounted price)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '\$${item.discountedPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (item.hasDiscount) ...[
                        const SizedBox(width: 8),
                        Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textMutedDark : AppColors.materialGrey[500],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // ── Right: image + add/stepper ──────────────────────────
            SizedBox(
              width: 96,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Food image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: item.imageUrl.isNotEmpty
                        ? Image.network(
                            item.imageUrl,
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 96,
                              height: 96,
                              color: isDark ? AppColors.black26 : AppColors.materialGrey[200],
                              child: const Icon(Icons.fastfood_rounded, color: AppColors.materialGrey, size: 36),
                            ),
                          )
                        : Container(
                            width: 96,
                            height: 96,
                            color: isDark ? AppColors.black26 : AppColors.materialGrey[200],
                            child: const Icon(Icons.fastfood_rounded, color: AppColors.materialGrey, size: 36),
                          ),
                  ),
                  // Add / Stepper button — overlaps bottom centre of image
                  Positioned(
                    bottom: -14,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: quantity == 0
                          ? _AddButton(onAdd: onAdd)
                          : _StepperButton(
                              quantity: quantity,
                              onAdd: onAdd,
                              onRemove: onRemove,
                            ),
                    ),
                  ),
                ],
              ),
            ),
            // Space so the bottom of the card accommodates the overlapping button
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Add button (pill style)
/// ---------------------------------------------------------------------
class _AddButton extends StatelessWidget {
  final VoidCallback onAdd;
  const _AddButton({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Text(
          '+ Add',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Quantity stepper (pill style)
/// ---------------------------------------------------------------------
class _StepperButton extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  const _StepperButton({
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onRemove,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Icon(Icons.remove, color: AppColors.white, size: 14),
            ),
          ),
          Text(
            '$quantity',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Icon(Icons.add, color: AppColors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Floating "View Cart" button bar
/// ---------------------------------------------------------------------
class _ViewCartButton extends StatelessWidget {
  final int count;
  final double total;
  final VoidCallback onTap;

  const _ViewCartButton({
    required this.count,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'VIEW CART',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Row(
              children: [
                Text(
                  'Checkout',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, color: AppColors.white, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Swappable Tab Views (Menu, Offers, Reviews, Info)
/// ---------------------------------------------------------------------
class _MenuView extends StatelessWidget {
  final String selectedPill;
  final ValueChanged<String> onSelectPill;
  final List<MenuCategory> categories;
  final List<OfferCard> offers;
  final Map<String, int> cart;
  final bool isLoading;
  final bool isDark;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;
  final void Function(String id, int quantity)? onSetQuantity;
  final String restaurantName;

  const _MenuView({
    required this.selectedPill,
    required this.onSelectPill,
    required this.categories,
    required this.offers,
    required this.cart,
    required this.isLoading,
    required this.isDark,
    required this.onAdd,
    required this.onRemove,
    this.onSetQuantity,
    this.restaurantName = 'Restaurant',
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (categories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.restaurant_menu_rounded, size: 48, color: isDark ? AppColors.textMutedDark : AppColors.materialGrey[400]),
              const SizedBox(height: 12),
              Text(
                'No menu items found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Check back soon for freshly updated offerings!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textMutedDark : AppColors.materialGrey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final filteredCategories = selectedPill == 'All Items'
        ? categories
        : categories.where((c) => c.title == selectedPill).toList();

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _CategoryPills(
          selected: selectedPill,
          isDark: isDark,
          labels: [
            'All Items',
            ...categories.map((category) => category.title),
          ],
          onSelect: onSelectPill,
        ),
        _TodaysOffers(
          offers: offers,
          isDark: isDark,
          restaurantName: restaurantName,
          cart: cart,
          onAdd: onAdd,
          onRemove: onRemove,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              for (final category in filteredCategories)
                _CategorySection(
                  category: category,
                  cart: cart,
                  isDark: isDark,
                  onAdd: onAdd,
                  onRemove: onRemove,
                  onSetQuantity: onSetQuantity,
                ),
            ],
          ),
        ),
        const SizedBox(height: 120),
      ],
    );
  }
}

class _OffersView extends StatelessWidget {
  final List<OfferCard> offers;
  final bool isDark;
  final String restaurantName;
  final Map<String, int> cart;
  final ValueChanged<String>? onAdd;
  final ValueChanged<String>? onRemove;

  const _OffersView({
    required this.offers,
    required this.isDark,
    this.restaurantName = 'Restaurant',
    this.cart = const {},
    this.onAdd,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.cardDark : AppColors.white;
    final cardBorder = isDark ? AppColors.borderDark : AppColors.border;
    final textColor = isDark ? AppColors.white : AppColors.textPrimary;
    final subColor = isDark ? AppColors.textMutedDark : AppColors.materialGrey[600]!;

    if (offers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_offer_outlined, size: 48, color: isDark ? AppColors.textMutedDark : AppColors.materialGrey[400]),
              const SizedBox(height: 12),
              Text(
                'No Active Offers',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Check back soon for new discounts and exclusive promos!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: subColor),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final offer = offers[index];
        final accentColor = offer.gradient.first;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OfferExplanationScreen(
                  title: offer.headline,
                  subtitle: offer.subline,
                  code: offer.code,
                  badge: offer.badgeLabel,
                  expiry: offer.timer,
                  gradientColors: offer.gradient,
                  applicableItems: offer.applicableItems,
                  restaurantName: restaurantName,
                  initialCart: cart,
                  onAdd: onAdd,
                  onRemove: onRemove,
                  terms: const [
                    'Discount is automatically calculated on all eligible dishes.',
                    'Maximum discount is automatically selected across overlapping offers.',
                    'Zero coupon codes required; save seamlessly at checkout.',
                  ],
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cardBorder, width: 1),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? AppColors.black.withValues(alpha: 0.25)
                      : AppColors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(
                            alpha: isDark ? 0.2 : 0.1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.local_offer_rounded,
                          color: accentColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    offer.badgeLabel,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: accentColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              offer.headline,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              offer.subline,
                              style: TextStyle(fontSize: 12, color: subColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.black.withValues(alpha: 0.2)
                        : AppColors.toneFFF9FAFB,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                    border: Border(
                      top: BorderSide(color: cardBorder, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: subColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            offer.timer,
                            style: TextStyle(fontSize: 11, color: subColor),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'AUTO-APPLIED',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReviewsView extends StatelessWidget {
  final String vendorId;
  final String vendorName;
  final double rating;
  final int reviewCount;
  final bool isDark;
  final Map<String, dynamic>? reviewsSummary;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  const _ReviewsView({
    required this.vendorId,
    required this.vendorName,
    required this.rating,
    required this.reviewCount,
    required this.isDark,
    this.reviewsSummary,
    this.isLoading = false,
    required this.onRefresh,
  });

  void _openReviewBottomSheet(BuildContext context, {Map<String, dynamic>? initialReview}) {
    final bool isEditing = initialReview != null;
    int selectedRating = (initialReview?['rating'] as num?)?.toInt() ?? 5;
    final nameController = TextEditingController(text: initialReview?['user_name']?.toString() ?? '');
    final commentController = TextEditingController(text: initialReview?['comment']?.toString() ?? '');
    bool isSubmitting = false;

    final cardBg = isDark ? MenuColors.cardDark : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1D1E20);
    final subColor = isDark ? MenuColors.textMutedDark : Colors.grey[600]!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;

            final ratingLabels = {
              5: '⭐⭐⭐⭐⭐ Outstanding! Loved it',
              4: '⭐⭐⭐⭐ Very Good, would order again',
              3: '⭐⭐⭐ Average experience',
              2: '⭐⭐ Below expectations',
              1: '⭐ Terrible / Poor food quality',
            };

            return Container(
              padding: EdgeInsets.fromLTRB(24, 16, 24, bottomInset + 24),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEditing ? 'Edit Your Review' : 'Rate & Review',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                vendorName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: MenuColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: subColor),
                          onPressed: () => Navigator.pop(bottomSheetContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              final starNum = index + 1;
                              final isSelected = starNum <= selectedRating;
                              return GestureDetector(
                                onTap: isSubmitting
                                    ? null
                                    : () {
                                        setSheetState(() {
                                          selectedRating = starNum;
                                        });
                                      },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(
                                    isSelected
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    color: isSelected
                                        ? Colors.amber
                                        : (isDark ? Colors.white30 : Colors.grey[400]),
                                    size: 40,
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ratingLabels[selectedRating] ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.amber[200] : const Color(0xFFD97706),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Your Name (Optional)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      enabled: !isSubmitting,
                      style: TextStyle(color: textColor, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'e.g. Alex M.',
                        hintStyle: TextStyle(color: subColor, fontSize: 14),
                        filled: true,
                        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8F9FA),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? MenuColors.borderDark : const Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? MenuColors.borderDark : const Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: MenuColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Feedback & Comments',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentController,
                      enabled: !isSubmitting,
                      minLines: 3,
                      maxLines: 5,
                      style: TextStyle(color: textColor, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'How was the food quality, taste, packing, and speed?',
                        hintStyle: TextStyle(color: subColor, fontSize: 14),
                        filled: true,
                        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8F9FA),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? MenuColors.borderDark : const Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? MenuColors.borderDark : const Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: MenuColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MenuColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                setSheetState(() => isSubmitting = true);
                                final result = await RestaurantService.submitVendorReview(
                                  vendorId: vendorId,
                                  rating: selectedRating,
                                  comment: commentController.text.trim(),
                                  userName: nameController.text.trim(),
                                );
                                setSheetState(() => isSubmitting = false);

                                if (result['success'] == true) {
                                  if (bottomSheetContext.mounted) {
                                    Navigator.pop(bottomSheetContext);
                                  }
                                  await onRefresh();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isEditing
                                              ? 'Your review has been updated successfully!'
                                              : 'Thank you! Your review has been submitted.',
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                        backgroundColor: const Color(0xFF10B981),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          result['error']?.toString() ?? 'Failed to submit review.',
                                        ),
                                        backgroundColor: Colors.redAccent,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                isEditing ? 'Update Review' : 'Submit Review',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.cardDark : AppColors.white;
    final cardBorder = isDark ? AppColors.borderDark : AppColors.border;
    final textColor = isDark ? AppColors.white : AppColors.textPrimary;
    final subColor = isDark ? AppColors.textMutedDark : AppColors.materialGrey[600]!;

    final rawRating = reviewsSummary?['rating'];
    final double displayRating = rawRating is num
        ? rawRating.toDouble()
        : (double.tryParse(rawRating?.toString() ?? '') ?? (rating > 0 ? rating : 4.8));

    final rawCount = reviewsSummary?['review_count'];
    final int displayCount = rawCount is num
        ? rawCount.toInt()
        : (int.tryParse(rawCount?.toString() ?? '') ?? reviewCount);

    final rawPercentages = reviewsSummary?['percentages'] as Map<String, dynamic>?;
    final p5 = (rawPercentages?['5'] as num?)?.toDouble() ?? (displayCount > 0 ? 0.88 : 0.0);
    final p4 = (rawPercentages?['4'] as num?)?.toDouble() ?? (displayCount > 0 ? 0.09 : 0.0);
    final p3 = (rawPercentages?['3'] as num?)?.toDouble() ?? (displayCount > 0 ? 0.02 : 0.0);
    final p2 = (rawPercentages?['2'] as num?)?.toDouble() ?? 0.0;
    final p1 = (rawPercentages?['1'] as num?)?.toDouble() ?? 0.0;

    final reviewsList = (reviewsSummary?['reviews'] as List<dynamic>?) ?? [];
    final userReview = reviewsSummary?['user_review'] as Map<String, dynamic>?;
    final String? userReviewId = userReview?['id']?.toString();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        // Overall Rating Summary Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorder),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Text(
                    displayRating > 0 ? displayRating.toStringAsFixed(1) : '4.8',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (i) {
                      final starVal = i + 1;
                      if (displayRating >= starVal) {
                        return const Icon(Icons.star_rounded, color: AppColors.materialAmber, size: 18);
                      } else if (displayRating >= starVal - 0.5) {
                        return const Icon(Icons.star_half_rounded, color: AppColors.materialAmber, size: 18);
                      } else {
                        return Icon(Icons.star_outline_rounded, color: AppColors.materialGrey[400], size: 18);
                      }
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$displayCount verified ratings',
                    style: TextStyle(fontSize: 12, color: subColor),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _RatingBar(stars: '5 ★', percent: p5, isDark: isDark),
                    _RatingBar(stars: '4 ★', percent: p4, isDark: isDark),
                    _RatingBar(stars: '3 ★', percent: p3, isDark: isDark),
                    _RatingBar(stars: '2 ★', percent: p2, isDark: isDark),
                    _RatingBar(stars: '1 ★', percent: p1, isDark: isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // If user already reviewed, show "Your Review" with Edit option; otherwise show "Write a Review" CTA
        if (userReview != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: MenuColors.primary.withValues(alpha: isDark ? 0.45 : 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: MenuColors.primary.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: MenuColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_rounded, size: 14, color: MenuColors.primary),
                              SizedBox(width: 4),
                              Text(
                                'Your Review',
                                style: TextStyle(
                                  color: MenuColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (userReview['created_at_formatted'] != null &&
                            userReview['created_at_formatted'].toString().isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            userReview['created_at_formatted'].toString(),
                            style: TextStyle(fontSize: 11, color: subColor),
                          ),
                        ],
                      ],
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: MenuColors.primary,
                        side: const BorderSide(color: MenuColors.primary),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _openReviewBottomSheet(context, initialReview: userReview),
                      icon: const Icon(Icons.edit_outlined, size: 14),
                      label: const Text('Edit Review', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: List.generate(5, (i) {
                    final uRating = (userReview['rating'] as num?)?.toInt() ?? 5;
                    return Icon(
                      i < uRating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: i < uRating ? Colors.amber : Colors.grey[300],
                      size: 18,
                    );
                  }),
                ),
                if ((userReview['comment']?.toString() ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    userReview['comment'].toString(),
                    style: TextStyle(
                      fontSize: 13,
                      color: textColor.withValues(alpha: 0.95),
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          )
        else
          // Write a Review CTA Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        MenuColors.primary.withValues(alpha: 0.18),
                        MenuColors.cardDark,
                      ]
                    : [
                        MenuColors.primary.withValues(alpha: 0.08),
                        Colors.white,
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: MenuColors.primary.withValues(alpha: isDark ? 0.3 : 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: MenuColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.rate_review_rounded,
                    color: MenuColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rate & Review Food',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Share your experience with other diners',
                        style: TextStyle(
                          fontSize: 12,
                          color: subColor,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MenuColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _openReviewBottomSheet(context),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text(
                    'Review',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 22),

        // Section Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Customer Feedback',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${reviewsList.length} Reviews',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: subColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),


        // Loading or Reviews List
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 36),
            child: Center(
              child: CircularProgressIndicator(color: MenuColors.primary),
            ),
          )
        else if (reviewsList.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cardBorder),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 44,
                  color: isDark ? Colors.white24 : Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'No reviews yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Be the first to order and review $vendorName!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: subColor),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MenuColors.primary,
                    side: const BorderSide(color: MenuColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _openReviewBottomSheet(context),
                  icon: const Icon(Icons.star_outline_rounded, size: 18),
                  label: const Text('Write First Review'),
                ),
              ],
            ),
          )
        else
          ...reviewsList.map((reviewMap) {
            final Map review = reviewMap is Map ? reviewMap : {};
            final bool isCurrentUserReview = userReviewId != null &&
                review['id']?.toString() == userReviewId;
            final String uName = isCurrentUserReview
                ? '${(review['user_name']?.toString() ?? '').trim().isNotEmpty ? review['user_name'] : 'You'} (You)'
                : ((review['user_name']?.toString() ?? '').trim().isNotEmpty
                    ? review['user_name'].toString()
                    : 'Verified Diner');
            final int rScore = (review['rating'] as num?)?.toInt() ?? 5;
            final String comment = review['comment']?.toString() ?? '';
            final String dateStr = review['created_at_formatted']?.toString() ?? '';
            final bool isVerified = review['is_verified'] as bool? ?? true;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCurrentUserReview
                      ? MenuColors.primary.withValues(alpha: 0.4)
                      : cardBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: MenuColors.primary.withValues(alpha: 0.15),
                        child: Text(
                          uName.isNotEmpty ? uName[0].toUpperCase() : 'D',
                          style: const TextStyle(
                            color: MenuColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    uName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isCurrentUserReview ? MenuColors.primary : textColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isCurrentUserReview) ...[
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () => _openReviewBottomSheet(context, initialReview: userReview),
                                    child: const Icon(
                                      Icons.edit_note_rounded,
                                      size: 18,
                                      color: MenuColors.primary,
                                    ),
                                  ),
                                ],
                                if (isVerified) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle_rounded,
                                          color: Color(0xFF10B981),
                                          size: 11,
                                        ),
                                        SizedBox(width: 2),
                                        Text(
                                          'Verified',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF10B981),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (dateStr.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                dateStr,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: subColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            i < rScore
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: i < rScore ? Colors.amber : Colors.grey[300],
                            size: 16,
                          );
                        }),
                      ),
                    ],
                  ),
                  if (comment.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      comment,
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor.withValues(alpha: 0.9),
                        height: 1.45,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
      ],
    );
  }
}

class _RatingBar extends StatelessWidget {
  final String stars;
  final double percent;
  final bool isDark;
  const _RatingBar({
    required this.stars,
    required this.percent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              stars,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? AppColors.textMutedDark : AppColors.materialGrey[600],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: isDark ? AppColors.white10 : AppColors.materialGrey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.materialAmber),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoView extends StatelessWidget {
  final VendorDetailData vendor;
  final bool isDark;
  const _InfoView({
    required this.vendor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.cardDark : AppColors.white;
    final cardBorder = isDark ? AppColors.borderDark : AppColors.border;
    final textColor = isDark ? AppColors.white : AppColors.textPrimary;
    final subColor = isDark ? AppColors.textMutedDark : AppColors.materialGrey[600]!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location & Address',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          vendor.address,
                          style: TextStyle(fontSize: 12, color: subColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorder),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time_filled_rounded,
                    color: vendor.isOpen ? AppColors.vegGreen : AppColors.nonVegRed,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Opening Hours',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          vendor.openingHours,
                          style: TextStyle(fontSize: 12, color: subColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (vendor.phone.isNotEmpty) ...[
                const Divider(height: 24),
                Row(
                  children: [
                    const Icon(
                      Icons.phone_in_talk_rounded,
                      color: AppColors.toneFF3B82F6,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phone & Contact',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            vendor.phone,
                            style: TextStyle(fontSize: 12, color: subColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Hygiene & Safety Certified',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                vendor.description,
                style: TextStyle(fontSize: 12, color: subColor, height: 1.4),
              ),
              if (vendor.tags.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: vendor.tags
                      .map(
                        (tag) => _FeatureChip(
                          label: tag,
                          icon: Icons.check_circle_outline_rounded,
                          isDark: isDark,
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;
  const _FeatureChip({
    required this.label,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.white10 : AppColors.border,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

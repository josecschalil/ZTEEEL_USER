import '../app_colors.dart';
// ---------------------------------------------------------------------
// FOOD TYPE SHOPS SCREEN
// ---------------------------------------------------------------------
// Shown when a user taps a food category button on the dashboard
// (e.g. "Pizza", "Burger"). Lists every shop on the platform that sells
// that category — the exact item name can differ from shop to shop
// (e.g. "Margherita Pizza" at one place, "Farmhouse Special" at another),
// so each listing pairs the shop with the specific item it sells.
//
// Visually matches the shared Manrope typography from the application theme.
// picker screen: white background, restrained orange accent used only
// for the few things that need it (rating pill, price, CTA-ish bits) —
// everything else stays neutral ink/slate so the page doesn't feel
// painted orange.
//
// Usage:
// Navigator.push(context, MaterialPageRoute(
//   builder: (_) => FoodTypeShopsScreen(
//     foodType: 'Pizza',
//     // Optional — omit to use bundled sample data for preview/dev.
//     listings: myRealListings,
//   ),
// ));
// ---------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../services/food_tag_service.dart';
import 'MainCartScreen.dart';
import 'LocationPageScreen.dart';
import 'NotificationScreen.dart';
import 'RestuarantMenuScreen.dart';
import '../services/location_service.dart';
import '../widgets/category_row.dart';
import '../widgets/discovery_search_bar.dart';
import '../widgets/exploring_location.dart';
import '../widgets/shimmer_loading.dart';

/// ---------------------------------------------------------------------
/// Colors are supplied by the shared app palette.
/// ---------------------------------------------------------------------

typedef FoodTypeShopScreen = FoodTypeShopsScreen;

/// ---------------------------------------------------------------------
/// Model — a single shop's listing for the selected food category.
/// Two shops can share a food *type* (Pizza) while selling differently
/// named items, so `itemName` is deliberately separate from `shopName`.
/// ---------------------------------------------------------------------
class ShopFoodListing {
  final String id;
  final String shopName;
  final String itemName;
  final String? imageUrl;
  final double rating; // 0.0 - 5.0
  final int reviewCount;
  final int deliveryTimeMins;
  final double distanceKm;
  final int priceForOne; // in local currency, whole units
  final bool isVeg;
  final bool isPromoted;
  final String? offerLabel; // e.g. "20% OFF" — null if no offer

  const ShopFoodListing({
    required this.id,
    required this.shopName,
    required this.itemName,
    required this.rating,
    required this.reviewCount,
    required this.deliveryTimeMins,
    required this.distanceKm,
    required this.priceForOne,
    required this.isVeg,
    this.imageUrl,
    this.isPromoted = false,
    this.offerLabel,
  });
}

enum _SortOption { relevance, ratingHigh, priceLow, deliveryFast }

extension on _SortOption {
  String get label {
    switch (this) {
      case _SortOption.relevance:
        return 'Relevance';
      case _SortOption.ratingHigh:
        return 'Rating: High to low';
      case _SortOption.priceLow:
        return 'Price: Low to high';
      case _SortOption.deliveryFast:
        return 'Delivery time';
    }
  }

  String get shortLabel {
    switch (this) {
      case _SortOption.relevance:
        return 'Relevance';
      case _SortOption.ratingHigh:
        return 'Rating';
      case _SortOption.priceLow:
        return 'Price';
      case _SortOption.deliveryFast:
        return 'Fast Delivery';
    }
  }
}

enum _QuickFilter { ratingFour, pureVeg, fastDelivery, offers }

extension on _QuickFilter {
  String get label {
    switch (this) {
      case _QuickFilter.ratingFour:
        return 'Rating 4.0+';
      case _QuickFilter.pureVeg:
        return 'Pure Veg';
      case _QuickFilter.fastDelivery:
        return 'Under 30 mins';
      case _QuickFilter.offers:
        return 'Offers';
    }
  }
}

/// ---------------------------------------------------------------------
/// Screen
/// ---------------------------------------------------------------------
class FoodTypeShopsScreen extends StatefulWidget {
  final String foodType;
  final String? foodTagId;
  final List<ShopFoodListing>? listings;
  final ValueChanged<ShopFoodListing>? onShopSelected;
  final List<FoodTag>? foodTags;
  final bool autoFocusSearch;

  const FoodTypeShopsScreen({
    super.key,
    required this.foodType,
    this.foodTagId,
    this.listings,
    this.onShopSelected,
    this.foodTags,
    this.autoFocusSearch = false,
  });

  @override
  State<FoodTypeShopsScreen> createState() => _FoodTypeShopsScreenState();
}

class _FoodTypeShopsScreenState extends State<FoodTypeShopsScreen> {
  late String _activeFoodType;
  String? _activeFoodTagId;
  List<ShopFoodListing> _all = const [];
  List<FoodTag> _availableFoodTags = const [];
  final FocusNode _searchFocusNode = FocusNode();
  String _address = 'Choose your location';
  List<Map<String, dynamic>> _tagOffers = const [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  final Set<_QuickFilter> _activeFilters = {};
  _SortOption _sort = _SortOption.relevance;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _activeFoodType = widget.foodType;
    _activeFoodTagId = widget.foodTagId;
    _availableFoodTags = widget.foodTags ?? const [];

    LocationService.addressNotifier.addListener(_onAddressChanged);
    _restoreAddress();

    if (_availableFoodTags.isEmpty) {
      _loadFoodTags();
    }

    if (widget.listings != null) {
      _all = widget.listings!;
    } else if (_activeFoodTagId != null && _activeFoodTagId!.isNotEmpty) {
      _isLoading = true;
      _loadFoodTagDiscovery(_activeFoodTagId!);
    } else {
      _all = _sampleListingsFor(_activeFoodType);
    }

    if (widget.autoFocusSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    LocationService.addressNotifier.removeListener(_onAddressChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onAddressChanged() {
    if (!mounted) return;
    final live = LocationService.addressNotifier.value;
    if (_address != live) {
      setState(() => _address = live);
    }
  }

  Future<void> _restoreAddress() async {
    final live = LocationService.addressNotifier.value;
    if (live.isNotEmpty && live != 'Choose your location') {
      setState(() => _address = live);
    } else {
      final saved = await LocationService.load();
      if (!mounted || saved == null) return;
      setState(() {
        _address = saved.address.isEmpty ? 'Selected location' : saved.address;
      });
    }
  }

  Future<void> _openLocationPicker() async {
    final result = await Navigator.of(context).push<PickedLocation>(
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
    if (!mounted || result == null) return;
    final address = result.address.isEmpty ? 'Selected location' : result.address;
    LocationService.addressNotifier.value = address;
    setState(() => _address = address);
  }

  Future<void> _refreshData() async {
    final foodTagsFuture = _loadFoodTags(forceRefresh: true);
    if (_activeFoodTagId != null && _activeFoodTagId!.isNotEmpty) {
      await Future.wait([
        foodTagsFuture,
        _loadFoodTagDiscovery(_activeFoodTagId!),
      ]);
    } else {
      await foodTagsFuture;
      if (mounted) {
        setState(() {
          _all = _sampleListingsFor(_activeFoodType);
        });
      }
    }
  }

  Future<void> _loadFoodTags({bool forceRefresh = false}) async {
    final tags = await FoodTagService.fetchFoodTags(forceRefresh: forceRefresh);
    if (!mounted) return;
    setState(() {
      _availableFoodTags = tags;
    });
  }

  void _selectFoodTag(FoodTag? tag) {
    if (tag == null) {
      setState(() {
        _activeFoodType = 'All';
        _activeFoodTagId = null;
        _isLoading = false;
        _tagOffers = const [];
        _all = _sampleListingsFor('All');
      });
    } else {
      setState(() {
        _activeFoodType = tag.name;
        _activeFoodTagId = tag.id;
        _isLoading = true;
      });
      _loadFoodTagDiscovery(tag.id);
    }
  }

  Future<void> _loadFoodTagDiscovery([String? tagId]) async {
    final targetTagId = tagId ?? _activeFoodTagId ?? '';
    if (targetTagId.isEmpty) return;
    final responses = await Future.wait([
      FoodTagService.fetchTagVendors(targetTagId),
      FoodTagService.fetchTagOffers(targetTagId),
    ]);
    final vendors = responses[0];
    final offers = _uniqueOffers(responses[1]);
    if (!mounted) return;
    setState(() {
      _all = vendors.map(_listingFromFoodTagVendor).toList();
      _tagOffers = offers;
      _isLoading = false;
    });
  }

  ShopFoodListing _listingFromFoodTagVendor(dynamic raw) {
    final Map<String, dynamic> vendor = raw is Map<String, dynamic>
        ? raw
        : (raw is Map ? Map<String, dynamic>.from(raw) : const {});
    final bestOffer = vendor['best_offer'];
    final offer = bestOffer is Map ? bestOffer : null;
    final rawImage = vendor['cover_image']?.toString() ??
        vendor['icon_image']?.toString() ??
        vendor['image']?.toString() ??
        vendor['image_url']?.toString() ??
        vendor['banner']?.toString() ??
        '';
    final imageUrl = rawImage.isEmpty
        ? null
        : (rawImage.startsWith('http://') || rawImage.startsWith('https://')
            ? rawImage
            : '${ApiConfig.baseUrl}${rawImage.startsWith('/') ? '' : '/'}$rawImage');
    final matchingItems =
        int.tryParse(vendor['matching_item_count']?.toString() ?? '') ?? 0;
    final discount =
        double.tryParse(offer?['discount_percentage']?.toString() ?? '') ?? 0;
    final offerLabel = discount > 0
        ? '${discount.toStringAsFixed(discount % 1 == 0 ? 0 : 1)}% OFF'
        : (offer?['title']?.toString() ?? vendor['offer_label']?.toString());

    final id = vendor['id']?.toString() ?? '';
    final name = vendor['business_name']?.toString().trim() ??
        vendor['name']?.toString().trim() ??
        vendor['shop_name']?.toString().trim() ??
        'Restaurant';
    final rating = double.tryParse(
            vendor['rating']?.toString() ??
                vendor['average_rating']?.toString() ??
                '') ??
        4.2;
    final reviewCount = int.tryParse(
            vendor['review_count']?.toString() ??
                vendor['rating_count']?.toString() ??
                '') ??
        50;
    final deliveryMins = int.tryParse(
            vendor['eta_minutes']?.toString() ??
                vendor['delivery_time_mins']?.toString() ??
                vendor['delivery_time']?.toString() ??
                '') ??
        25;
    final distance = double.tryParse(
            vendor['distance_km']?.toString() ??
                vendor['distance']?.toString() ??
                '') ??
        1.5;
    final priceForOne = (double.tryParse(
                vendor['lowest_matching_item_price']?.toString() ??
                    vendor['price_for_one']?.toString() ??
                    '') ??
            199)
        .round();
    final isVeg = vendor['is_veg'] == true || vendor['is_pure_veg'] == true;
    final isPromoted = offer != null || vendor['is_promoted'] == true;

    return ShopFoodListing(
      id: id,
      shopName: name,
      itemName: matchingItems > 0
          ? (matchingItems == 1
              ? '1 matching item'
              : '$matchingItems matching items')
          : '$_activeFoodType Special',
      imageUrl: imageUrl ??
          (rawImage.isNotEmpty ? FoodTag.resolveImage(rawImage) : null),
      rating: rating,
      reviewCount: reviewCount,
      deliveryTimeMins: deliveryMins,
      distanceKm: distance,
      priceForOne: priceForOne,
      isVeg: isVeg,
      isPromoted: isPromoted,
      offerLabel: offerLabel,
    );
  }

  List<Map<String, dynamic>> _uniqueOffers(List<Map<String, dynamic>> offers) {
    final seen = <String>{};
    return offers.where((row) {
      final vendor = row['vendor'];
      final offer = row['offer'];
      final key =
          '${vendor is Map ? vendor['id'] : ''}:${offer is Map ? offer['id'] : ''}';
      return key != ':' && seen.add(key);
    }).toList();
  }

  void _openVendorItems(ShopFoodListing listing) {
    widget.onShopSelected?.call(listing);
    if (_activeFoodTagId != null && _activeFoodTagId!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FoodTagVendorItemsScreen(
            vendorId: listing.id,
            vendorName: listing.shopName,
            foodTagId: _activeFoodTagId!,
            foodTagName: _activeFoodType,
            heroImageUrl: listing.imageUrl,
          ),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RestaurantMenuScreen(
          vendorId: listing.id,
          restaurantName: listing.shopName,
          heroImageUrl: listing.imageUrl,
          cuisine: _activeFoodType,
          isOpen: true,
        ),
      ),
    );
  }

  List<ShopFoodListing> get _filtered {
    var result = _all.where((l) {
      if (_query.trim().isNotEmpty) {
        final q = _query.toLowerCase();
        final matches =
            l.shopName.toLowerCase().contains(q) ||
            l.itemName.toLowerCase().contains(q);
        if (!matches) return false;
      }
      if (_activeFilters.contains(_QuickFilter.pureVeg) && !l.isVeg) {
        return false;
      }
      if (_activeFilters.contains(_QuickFilter.ratingFour) && l.rating < 4.0) {
        return false;
      }
      if (_activeFilters.contains(_QuickFilter.fastDelivery) &&
          l.deliveryTimeMins >= 30) {
        return false;
      }
      if (_activeFilters.contains(_QuickFilter.offers) &&
          l.offerLabel == null) {
        return false;
      }
      return true;
    }).toList();

    switch (_sort) {
      case _SortOption.relevance:
        result.sort((a, b) {
          if (a.isPromoted != b.isPromoted) {
            return a.isPromoted ? -1 : 1;
          }
          return b.rating.compareTo(a.rating);
        });
        break;
      case _SortOption.ratingHigh:
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case _SortOption.priceLow:
        result.sort((a, b) => a.priceForOne.compareTo(b.priceForOne));
        break;
      case _SortOption.deliveryFast:
        result.sort((a, b) => a.deliveryTimeMins.compareTo(b.deliveryTimeMins));
        break;
    }
    return result;
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) => _FilterModalSheet(
        activeFilters: Set<_QuickFilter>.from(_activeFilters),
        currentSort: _sort,
        onApply: (filters, sort) {
          setState(() {
            _activeFilters
              ..clear()
              ..addAll(filters);
            _sort = sort;
          });
        },
      ),
    );
  }

  int get _activeCount {
    var count = _activeFilters.length;
    if (_sort != _SortOption.relevance) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              address: _address,
              onLocationTap: _openLocationPicker,
              foodType: _activeFoodType,
              selectedTagId: _activeFoodTagId,
              foodTags: _availableFoodTags,
              searchFocusNode: _searchFocusNode,
              onClearSearch: () {
                _searchController.clear();
                setState(() => _query = '');
              },
              onSelectTag: _selectFoodTag,
              resultCount: results.length,
              onBack: () => Navigator.of(context).maybePop(),
              searchController: _searchController,
              onSearchChanged: (v) => setState(() => _query = v),
              onFilterTap: _openFilterSheet,
              filterLabel: 'Filters',
              activeFilterCount: _activeCount,
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEF0)),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.white,
                onRefresh: _refreshData,
                child: _isLoading
                    ? const _FoodTypeShopLoadingSkeleton()
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        children: [
                          if (_tagOffers.isNotEmpty) ...[
                            _FoodTagOfferRail(
                              foodTagName: _activeFoodType,
                              offers: _tagOffers,
                              onVendorTap: (vendor) => _openVendorItems(
                                _listingFromFoodTagVendor(vendor),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          if (_activeFoodTagId != null) ...[
                            Text(
                              '$_activeFoodType shops',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ] else ...[
                            const Text(
                              'Restaurant results',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                          if (results.isEmpty)
                            const _EmptyState()
                          else
                            for (final listing in results) ...[
                              _ShopListingCard(
                                listing: listing,
                                onTap: () => _openVendorItems(listing),
                              ),
                              const SizedBox(height: 12),
                            ],
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodTagOfferRail extends StatelessWidget {
  final String foodTagName;
  final List<Map<String, dynamic>> offers;
  final ValueChanged<Map<String, dynamic>> onVendorTap;

  const _FoodTagOfferRail({
    required this.foodTagName,
    required this.offers,
    required this.onVendorTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$foodTagName offers',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 144,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: offers.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final row = offers[index];
              final vendor = row['vendor'] is Map
                  ? Map<String, dynamic>.from(row['vendor'] as Map)
                  : <String, dynamic>{};
              final item = row['item'] is Map
                  ? Map<String, dynamic>.from(row['item'] as Map)
                  : <String, dynamic>{};
              final offer = row['offer'] is Map
                  ? Map<String, dynamic>.from(row['offer'] as Map)
                  : <String, dynamic>{};
              final discount = double.tryParse(
                offer['discount_percentage']?.toString() ?? '',
              );
              final rawImage = item['image']?.toString() ?? '';
              final imageUrl = rawImage.isEmpty
                  ? null
                  : FoodTag.resolveImage(rawImage);
              return SizedBox(
                width: 220,
                child: Material(
                  color: AppColors.cardLight,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: vendor['id'] == null
                        ? null
                        : () => onVendorTap(vendor),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          _ThumbImage(url: imageUrl, isVeg: false),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  discount != null && discount > 0
                                      ? '${discount.toStringAsFixed(discount % 1 == 0 ? 0 : 1)}% OFF'
                                      : (offer['title']?.toString() ??
                                            'Special offer'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  vendor['business_name']?.toString() ??
                                      'Restaurant',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  item['name']?.toString() ?? foodTagName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Shows only the menu items carrying the food tag the customer selected.
class FoodTagVendorItemsScreen extends StatefulWidget {
  final String vendorId;
  final String vendorName;
  final String foodTagId;
  final String foodTagName;
  final String? heroImageUrl;

  const FoodTagVendorItemsScreen({
    super.key,
    required this.vendorId,
    required this.vendorName,
    required this.foodTagId,
    required this.foodTagName,
    this.heroImageUrl,
  });

  @override
  State<FoodTagVendorItemsScreen> createState() =>
      _FoodTagVendorItemsScreenState();
}

class _FoodTagVendorItemsScreenState extends State<FoodTagVendorItemsScreen> {
  List<Map<String, dynamic>> _items = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await FoodTagService.fetchVendorTagItems(
      widget.vendorId,
      widget.foodTagId,
    );
    if (!mounted) return;
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.vendorName,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${widget.foodTagName} items',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.white,
        onRefresh: _loadItems,
        child: _isLoading
            ? const _FoodTagVendorItemsLoadingSkeleton()
            : _items.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.all(16),
                children: const [_EmptyState()],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _FoodTagMenuItemCard(item: _items[index]),
              ),
      ),
    );
  }
}

class _FoodTagMenuItemCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _FoodTagMenuItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final rawImage = item['image']?.toString() ?? '';
    final imageUrl = rawImage.isEmpty ? null : FoodTag.resolveImage(rawImage);
    final offer = item['best_offer'];
    final discount = offer is Map
        ? double.tryParse(offer['discount_percentage']?.toString() ?? '')
        : null;
    final price = double.tryParse(item['price']?.toString() ?? '') ?? 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ThumbImage(url: imageUrl, isVeg: false),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name']?.toString() ?? 'Menu item',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                if ((item['description']?.toString() ?? '').isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    item['description'].toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  '₹${price.toStringAsFixed(price % 1 == 0 ? 0 : 2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (discount != null && discount > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${discount.toStringAsFixed(discount % 1 == 0 ? 0 : 1)}% OFF',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Header: back button, title, live result count, search field, sort
/// ---------------------------------------------------------------------
class _Header extends StatelessWidget {
  final String address;
  final VoidCallback onLocationTap;
  final String foodType;
  final String? selectedTagId;
  final List<FoodTag> foodTags;
  final FocusNode searchFocusNode;
  final VoidCallback onClearSearch;
  final ValueChanged<FoodTag?> onSelectTag;
  final int resultCount;
  final VoidCallback onBack;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterTap;
  final String filterLabel;
  final int activeFilterCount;
  final int cartItemCount;

  const _Header({
    required this.address,
    required this.onLocationTap,
    required this.foodType,
    required this.selectedTagId,
    required this.foodTags,
    required this.searchFocusNode,
    required this.onClearSearch,
    required this.onSelectTag,
    required this.resultCount,
    required this.onBack,
    required this.searchController,
    required this.onSearchChanged,
    required this.onFilterTap,
    required this.filterLabel,
    required this.activeFilterCount,
    this.cartItemCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardLight,
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── top row: back ← | address | notif + cart ──
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 4, 6, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: onBack,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: ExploringLocation(
                    address: address,
                    label: 'Searching in',
                    onTap: onLocationTap,
                  ),
                ),
                IconButton(
                  tooltip: 'Notifications',
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    size: 22,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  ),
                ),
                Semantics(
                  label: 'Cart, $cartItemCount items',
                  child: IconButton(
                    tooltip: 'Cart',
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MainCartScreenPage(),
                      ),
                    ),
                    icon: Badge(
                      isLabelVisible: cartItemCount > 0,
                      backgroundColor: AppColors.orange,
                      textColor: AppColors.textOnAccent,
                      label: Text(cartItemCount > 99 ? '99+' : '$cartItemCount'),
                      child: const Icon(
                        Icons.shopping_cart_outlined,
                        size: 22,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── search bar ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Hero(
              tag: 'discovery_search_bar_hero',
              child: Material(
                color: Colors.transparent,
                child: DiscoverySearchBar.editable(
                  hintText: foodType == 'All'
                      ? 'Search food...'
                      : 'Search in $foodType...',
                  selectedFilterLabel: filterLabel,
                  selectedCount: activeFilterCount,
                  filterIcon: Icons.tune_rounded,
                  showFilterPill: true,
                  controller: searchController,
                  focusNode: searchFocusNode,
                  onChanged: onSearchChanged,
                  onClear: onClearSearch,
                  onFilterTap: onFilterTap,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          CategoryRow(
            scrollKey: const PageStorageKey('search-categories'),
            foodTags: foodTags,
            isLoading: foodTags.isEmpty,
            selectedTagId: selectedTagId,
            selectedTagName: foodType,
            onTagTap: onSelectTag,
            padding: const EdgeInsets.symmetric(horizontal: 18),
          ),
        ],
      ),
    );
  }
}

// ── Filter bottom sheet ───────────────────────────────────────────────
class _FilterModalSheet extends StatefulWidget {
  final Set<_QuickFilter> activeFilters;
  final _SortOption currentSort;
  final void Function(Set<_QuickFilter> filters, _SortOption sort) onApply;

  const _FilterModalSheet({
    required this.activeFilters,
    required this.currentSort,
    required this.onApply,
  });

  @override
  State<_FilterModalSheet> createState() => _FilterModalSheetState();
}

class _FilterModalSheetState extends State<_FilterModalSheet> {
  late Set<_QuickFilter> _filters;
  late _SortOption _sort;

  @override
  void initState() {
    super.initState();
    _filters = Set.from(widget.activeFilters);
    _sort = widget.currentSort;
  }

  void _clearAll() => setState(() {
        _filters.clear();
        _sort = _SortOption.relevance;
      });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scroll) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearAll,
                    child: const Text(
                      'Clear all',
                      style: TextStyle(color: AppColors.orange),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEEEF0)),
            // Scrollable content
            Expanded(
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  // ── Dietary preference ──
                  const Text(
                    'Dietary Preference',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FilterSheetSwitchTile(
                    label: 'Pure Veg',
                    leading: const _PureVegIcon(),
                    value: _filters.contains(_QuickFilter.pureVeg),
                    onChanged: (v) => setState(() {
                      if (v) {
                        _filters.add(_QuickFilter.pureVeg);
                      } else {
                        _filters.remove(_QuickFilter.pureVeg);
                      }
                    }),
                  ),
                  const SizedBox(height: 20),
                  // ── Quick filters ──
                  const Text(
                    'Quick Filters',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FilterSheetChip(
                        label: 'Rating 4.0+',
                        isActive: _filters.contains(_QuickFilter.ratingFour),
                        onTap: () => setState(() {
                          _filters.contains(_QuickFilter.ratingFour)
                              ? _filters.remove(_QuickFilter.ratingFour)
                              : _filters.add(_QuickFilter.ratingFour);
                        }),
                      ),
                      _FilterSheetChip(
                        label: 'Under 30 mins',
                        isActive: _filters.contains(_QuickFilter.fastDelivery),
                        onTap: () => setState(() {
                          _filters.contains(_QuickFilter.fastDelivery)
                              ? _filters.remove(_QuickFilter.fastDelivery)
                              : _filters.add(_QuickFilter.fastDelivery);
                        }),
                      ),
                      _FilterSheetChip(
                        label: 'Offers & Deals',
                        isActive: _filters.contains(_QuickFilter.offers),
                        onTap: () => setState(() {
                          _filters.contains(_QuickFilter.offers)
                              ? _filters.remove(_QuickFilter.offers)
                              : _filters.add(_QuickFilter.offers);
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // ── Sort by ──
                  const Text(
                    'Sort By',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  for (final option in _SortOption.values)
                    RadioListTile<_SortOption>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.orange,
                      title: Text(
                        option.label,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      value: option,
                      groupValue: _sort,
                      onChanged: (v) => setState(() => _sort = v!),
                    ),
                ],
              ),
            ),
            // ── Apply button ──
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                MediaQuery.of(context).padding.bottom + 12,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    widget.onApply(_filters, _sort);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSheetSwitchTile extends StatelessWidget {
  final String label;
  final Widget leading;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _FilterSheetSwitchTile({
    required this.label,
    required this.leading,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        leading,
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Switch(
          value: value,
          activeColor: AppColors.orange,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _FilterSheetChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterSheetChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primarySoft : AppColors.cardLight,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.borderLight,
            width: isActive ? 1.2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _PureVegIcon extends StatelessWidget {
  const _PureVegIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green, width: 1.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Center(
        child: Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Shop listing card
/// ---------------------------------------------------------------------
class _ShopListingCard extends StatelessWidget {
  final ShopFoodListing listing;
  final VoidCallback onTap;

  const _ShopListingCard({required this.listing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ThumbImage(url: listing.imageUrl, isVeg: listing.isVeg),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (listing.isPromoted) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PROMOTED',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      listing.shopName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      listing.itemName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          _RatingPill(rating: listing.rating),
                          const SizedBox(width: 8),
                          Icon(Icons.circle, size: 3, color: AppColors.textMuted),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.schedule,
                            size: 13,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${listing.deliveryTimeMins} mins',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.circle, size: 3, color: AppColors.textMuted),
                          const SizedBox(width: 8),
                          Text(
                            '${listing.distanceKm.toStringAsFixed(1)} km',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Text(
                            '₹${listing.priceForOne} for one',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (listing.offerLabel != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                listing.offerLabel!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small rounded rating badge — the one spot allowed a filled orange tint.
class _RatingPill extends StatelessWidget {
  final double rating;
  const _RatingPill({required this.rating});

  @override
  Widget build(BuildContext context) {
    final good = rating >= 4.0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: good
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.primarySoft,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: 13,
            color: good ? AppColors.success : AppColors.primary,
          ),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: good ? AppColors.success : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Thumbnail with graceful fallback when there's no image / it fails to
/// load — avoids ever showing a broken-image icon.
class _ThumbImage extends StatelessWidget {
  final String? url;
  final bool isVeg;
  const _ThumbImage({required this.url, required this.isVeg});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 84,
            height: 84,
            child: url != null
                ? Image.network(
                    url!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const _ThumbFallback();
                    },
                    errorBuilder: (context, error, stack) =>
                        const _ThumbFallback(),
                  )
                : const _ThumbFallback(),
          ),
        ),
        Positioned(
          top: 4,
          left: 4,
          child: Container(
            width: 15,
            height: 15,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: isVeg ? AppColors.success : AppColors.primary,
                width: 1.2,
              ),
            ),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isVeg ? AppColors.success : AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ThumbFallback extends StatelessWidget {
  const _ThumbFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      color: AppColors.backgroundLight,
      alignment: Alignment.center,
      child: const Icon(
        Icons.restaurant_menu,
        size: 26,
        color: AppColors.textMuted,
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Sort bottom sheet
/// ---------------------------------------------------------------------
class _SortSheet extends StatelessWidget {
  final _SortOption current;
  final ValueChanged<_SortOption> onSelected;

  const _SortSheet({required this.current, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        20 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const Text(
            'Sort by',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          for (final option in _SortOption.values)
            InkWell(
              onTap: () => onSelected(option),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      option == current
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      size: 19,
                      color: option == current
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      option.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: option == current
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: option == current
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
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

/// ---------------------------------------------------------------------
/// Empty state — shown when filters/search leave nothing to display
/// ---------------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off,
                size: 28,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No shops match right now',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Try clearing a filter or searching a different term.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Sample data — used only when no `listings` are passed in, so the
/// screen is previewable standalone. Replace with your real API/DB call.
/// ---------------------------------------------------------------------
List<ShopFoodListing> _sampleListingsFor(String foodType) {
  final t = foodType.toLowerCase();

  if (t.contains('pizza')) {
    return const [
      ShopFoodListing(
        id: 'p1',
        shopName: "Napoli's Pizzeria",
        itemName: 'Margherita Pizza',
        rating: 4.6,
        reviewCount: 812,
        deliveryTimeMins: 28,
        distanceKm: 1.2,
        priceForOne: 249,
        isVeg: true,
        isPromoted: true,
        offerLabel: '20% OFF',
        imageUrl: null,
      ),
      ShopFoodListing(
        id: 'p2',
        shopName: 'Pizza Junction',
        itemName: 'Farmhouse Special',
        rating: 4.3,
        reviewCount: 540,
        deliveryTimeMins: 35,
        distanceKm: 2.4,
        priceForOne: 299,
        isVeg: true,
        imageUrl: null,
      ),
      ShopFoodListing(
        id: 'p3',
        shopName: 'Cheesy Bites',
        itemName: 'Chicken Tikka Pizza',
        rating: 4.1,
        reviewCount: 210,
        deliveryTimeMins: 40,
        distanceKm: 3.1,
        priceForOne: 329,
        isVeg: false,
        imageUrl: null,
      ),
      ShopFoodListing(
        id: 'p4',
        shopName: "La Bella Pizza Co.",
        itemName: 'Peppy Paneer Pizza',
        rating: 3.9,
        reviewCount: 96,
        deliveryTimeMins: 25,
        distanceKm: 0.8,
        priceForOne: 279,
        isVeg: true,
        offerLabel: 'Buy 1 Get 1',
        imageUrl: null,
      ),
    ];
  }

  if (t.contains('burger')) {
    return const [
      ShopFoodListing(
        id: 'b1',
        shopName: 'The Burger Co.',
        itemName: 'Classic Cheese Burger',
        rating: 4.5,
        reviewCount: 670,
        deliveryTimeMins: 22,
        distanceKm: 1.0,
        priceForOne: 179,
        isVeg: false,
        isPromoted: true,
        imageUrl: null,
      ),
      ShopFoodListing(
        id: 'b2',
        shopName: 'Wich Please',
        itemName: 'Veg Burger Supreme',
        rating: 4.2,
        reviewCount: 305,
        deliveryTimeMins: 30,
        distanceKm: 1.8,
        priceForOne: 149,
        isVeg: true,
        offerLabel: '15% OFF',
        imageUrl: null,
      ),
      ShopFoodListing(
        id: 'b3',
        shopName: 'Grill House',
        itemName: 'Spicy Chicken Burger',
        rating: 3.8,
        reviewCount: 142,
        deliveryTimeMins: 38,
        distanceKm: 2.9,
        priceForOne: 199,
        isVeg: false,
        imageUrl: null,
      ),
    ];
  }

  // Generic fallback for any other category.
  return [
    ShopFoodListing(
      id: 'g1',
      shopName: 'Local Favourite',
      itemName: '$foodType Special',
      rating: 4.4,
      reviewCount: 220,
      deliveryTimeMins: 27,
      distanceKm: 1.4,
      priceForOne: 199,
      isVeg: true,
      isPromoted: true,
    ),
    ShopFoodListing(
      id: 'g2',
      shopName: 'City Kitchen',
      itemName: 'Classic $foodType',
      rating: 4.0,
      reviewCount: 88,
      deliveryTimeMins: 34,
      distanceKm: 2.6,
      priceForOne: 229,
      isVeg: false,
    ),
  ];
}

class _FoodTypeShopLoadingSkeleton extends StatelessWidget {
  const _FoodTypeShopLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ShimmerLoading(
            child: Container(
              width: 140,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        for (int i = 0; i < 4; i++) ...[
          const _ShopListingCardSkeleton(),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _ShopListingCardSkeleton extends StatelessWidget {
  const _ShopListingCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: ShimmerLoading(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 140,
                      height: 15,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceRaised,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceRaised,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceRaised,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 50,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceRaised,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 42,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceRaised,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 75,
                          height: 13,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceRaised,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 60,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceRaised,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FoodTagVendorItemsLoadingSkeleton extends StatelessWidget {
  const _FoodTagVendorItemsLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => const _FoodTagMenuItemCardSkeleton(),
    );
  }
}

class _FoodTagMenuItemCardSkeleton extends StatelessWidget {
  const _FoodTagMenuItemCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: ShimmerLoading(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 130,
                      height: 15,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceRaised,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 180,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceRaised,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceRaised,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 60,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceRaised,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

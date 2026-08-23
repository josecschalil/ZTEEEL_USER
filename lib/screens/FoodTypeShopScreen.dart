// ---------------------------------------------------------------------
// FOOD TYPE SHOPS SCREEN
// ---------------------------------------------------------------------
// Shown when a user taps a food category button on the dashboard
// (e.g. "Pizza", "Burger"). Lists every shop on the platform that sells
// that category — the exact item name can differ from shop to shop
// (e.g. "Margherita Pizza" at one place, "Farmhouse Special" at another),
// so each listing pairs the shop with the specific item it sells.
//
// Visually matches LocationColors / PlusJakartaSans from the location
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
import 'FoodDetailScreen.dart';

/// ---------------------------------------------------------------------
/// Shared palette (kept identical to the rest of the app)
/// ---------------------------------------------------------------------
class AppColors {
  static const primary = Color(0xFFEE5B2B);
  static const primarySoft = Color(0xFFFDECE4);
  static const backgroundLight = Color(0xFFF8F6F6);
  static const cardLight = Colors.white;
  static const borderLight = Color(0xFFE2E8F0);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textMuted = Color(0xFF94A3B8);
  static const success = Color(0xFF16A34A);
}

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
  final List<ShopFoodListing>? listings;
  final ValueChanged<ShopFoodListing>? onShopSelected;

  const FoodTypeShopsScreen({
    super.key,
    required this.foodType,
    this.listings,
    this.onShopSelected,
  });

  @override
  State<FoodTypeShopsScreen> createState() => _FoodTypeShopsScreenState();
}

class _FoodTypeShopsScreenState extends State<FoodTypeShopsScreen> {
  late final List<ShopFoodListing> _all;
  final TextEditingController _searchController = TextEditingController();
  final Set<_QuickFilter> _activeFilters = {};
  _SortOption _sort = _SortOption.relevance;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _all = widget.listings ?? _sampleListingsFor(widget.foodType);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      if (_activeFilters.contains(_QuickFilter.ratingFour) && l.rating < 4.0) {
        return false;
      }
      if (_activeFilters.contains(_QuickFilter.pureVeg) && !l.isVeg) {
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

  void _openSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _SortSheet(
        current: _sort,
        onSelected: (option) {
          setState(() => _sort = option);
          Navigator.pop(context);
        },
      ),
    );
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
              foodType: widget.foodType,
              resultCount: results.length,
              onBack: () => Navigator.of(context).maybePop(),
              searchController: _searchController,
              onSearchChanged: (v) => setState(() => _query = v),
              onSortTap: _openSortSheet,
              sortLabel: _sort.label,
            ),
            _FilterRow(
              active: _activeFilters,
              onToggle: (filter) => setState(() {
                if (_activeFilters.contains(filter)) {
                  _activeFilters.remove(filter);
                } else {
                  _activeFilters.add(filter);
                }
              }),
            ),
            Expanded(
              child: results.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final listing = results[i];
                        return _ShopListingCard(
                          listing: listing,
                          onTap: () {
                            widget.onShopSelected?.call(listing);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const FoodDetailsScreen(),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Header: back button, title, live result count, search field, sort
/// ---------------------------------------------------------------------
class _Header extends StatelessWidget {
  final String foodType;
  final int resultCount;
  final VoidCallback onBack;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSortTap;
  final String sortLabel;

  const _Header({
    required this.foodType,
    required this.resultCount,
    required this.onBack,
    required this.searchController,
    required this.onSearchChanged,
    required this.onSortTap,
    required this.sortLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardLight,
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      foodType,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$resultCount ${resultCount == 1 ? 'shop' : 'shops'} near you',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Search shop or dish name',
                      hintStyle: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        color: AppColors.textMuted,
                        fontSize: 13.5,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: onSortTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.swap_vert,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Sort',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Horizontal quick-filter chip row
/// ---------------------------------------------------------------------
class _FilterRow extends StatelessWidget {
  final Set<_QuickFilter> active;
  final ValueChanged<_QuickFilter> onToggle;

  const _FilterRow({required this.active, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardLight,
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _QuickFilter.values.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final filter = _QuickFilter.values[i];
            final isActive = active.contains(filter);
            return InkWell(
              onTap: () => onToggle(filter),
              borderRadius: BorderRadius.circular(999),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primarySoft : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.borderLight,
                    width: isActive ? 1.2 : 1,
                  ),
                ),
                child: Text(
                  filter.label,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          },
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
      color: AppColors.cardLight,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
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
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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
                        fontFamily: 'PlusJakartaSans',
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
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
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
                            fontFamily: 'PlusJakartaSans',
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
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          '₹${listing.priceForOne} for one',
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
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
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
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
            ? AppColors.success.withOpacity(0.1)
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
              fontFamily: 'PlusJakartaSans',
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
              color: Colors.white,
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
              fontFamily: 'PlusJakartaSans',
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
                        fontFamily: 'PlusJakartaSans',
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
                fontFamily: 'PlusJakartaSans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Try clearing a filter or searching a different term.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
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

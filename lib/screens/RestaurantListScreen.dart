import 'package:flutter/material.dart';
import 'RestuarantMenuScreen.dart';

/// ---------------------------------------------------------------------------
/// NEARBY RESTAURANTS — REDESIGNED
/// ---------------------------------------------------------------------------
/// Visual redesign only:
/// - All existing data, filters, sorting and navigation are preserved.
/// - Restaurant selection still opens RestaurantMenuScreen.
/// - Search still checks restaurant names and cuisines.
/// - Promoted, open/closed, rating, distance, ETA, delivery and price data
///   remain unchanged.
/// - The visual language is intentionally editorial / premium rather than
///   looking like a generic AI-generated card list.
/// ---------------------------------------------------------------------------

class AppColors {
  static const primary = Color(0xFFEE5B2B);
  static const primarySoft = Color(0xFFFFF0EA);

  static const background = Color(0xFFFAFAFC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF0F0F3);

  static const textPrimary = Color(0xFF2C1810);
  static const textSecondary = Color(0xFF7A6B63);
  static const textMuted = Color(0xFFA89890);

  static const border = Color(0xFFF0F0F3);
  static const success = Color(0xFF179B55);
  static const warning = Color(0xFFD99018);
  static const cardOverlay = Color(0xFF3D2B23);
}

typedef RestaurantListScreen = NearbyRestaurantsScreen;

class RestaurantListing {
  final String id;
  final String name;
  final String? imageUrl;
  final IconData fallbackIcon;
  final List<String> cuisines;
  final double rating;
  final int reviewCount;
  final double distanceKm;
  final int etaMins;
  final bool isOpenNow;
  final bool isPromoted;
  final bool hasFreeDelivery;
  final String priceLevel;

  const RestaurantListing({
    required this.id,
    required this.name,
    required this.fallbackIcon,
    required this.cuisines,
    required this.rating,
    required this.reviewCount,
    required this.distanceKm,
    required this.etaMins,
    required this.isOpenNow,
    required this.priceLevel,
    this.imageUrl,
    this.isPromoted = false,
    this.hasFreeDelivery = false,
  });
}

enum _QuickFilter { openNow, nearby, topRated, freeDelivery }

extension on _QuickFilter {
  String get label {
    switch (this) {
      case _QuickFilter.openNow:
        return 'Open now';
      case _QuickFilter.nearby:
        return 'Under 2 km';
      case _QuickFilter.topRated:
        return 'Top rated';
      case _QuickFilter.freeDelivery:
        return 'Free delivery';
    }
  }

  IconData get icon {
    switch (this) {
      case _QuickFilter.openNow:
        return Icons.schedule_rounded;
      case _QuickFilter.nearby:
        return Icons.near_me_rounded;
      case _QuickFilter.topRated:
        return Icons.star_rounded;
      case _QuickFilter.freeDelivery:
        return Icons.delivery_dining_rounded;
    }
  }
}

enum _SortOption { relevance, distance, rating, deliveryTime }

extension on _SortOption {
  String get label {
    switch (this) {
      case _SortOption.relevance:
        return 'Relevance';
      case _SortOption.distance:
        return 'Distance';
      case _SortOption.rating:
        return 'Rating';
      case _SortOption.deliveryTime:
        return 'Delivery time';
    }
  }
}

class NearbyRestaurantsScreen extends StatefulWidget {
  final List<RestaurantListing>? restaurants;
  final ValueChanged<RestaurantListing>? onRestaurantSelected;

  const NearbyRestaurantsScreen({
    super.key,
    this.restaurants,
    this.onRestaurantSelected,
  });

  @override
  State<NearbyRestaurantsScreen> createState() =>
      _NearbyRestaurantsScreenState();
}

class _NearbyRestaurantsScreenState extends State<NearbyRestaurantsScreen> {
  late final List<RestaurantListing> _all;
  final TextEditingController _searchController = TextEditingController();

  final Set<_QuickFilter> _activeFilters = {};
  _SortOption _sort = _SortOption.relevance;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _all = widget.restaurants ?? _sampleRestaurants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RestaurantListing> get _filtered {
    var result = _all.where((r) {
      if (_query.trim().isNotEmpty) {
        final q = _query.toLowerCase();
        final matches =
            r.name.toLowerCase().contains(q) ||
            r.cuisines.any((c) => c.toLowerCase().contains(q));
        if (!matches) return false;
      }

      if (_activeFilters.contains(_QuickFilter.openNow) && !r.isOpenNow) {
        return false;
      }

      if (_activeFilters.contains(_QuickFilter.nearby) && r.distanceKm > 2.0) {
        return false;
      }

      if (_activeFilters.contains(_QuickFilter.topRated) && r.rating < 4.3) {
        return false;
      }

      if (_activeFilters.contains(_QuickFilter.freeDelivery) &&
          !r.hasFreeDelivery) {
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
      case _SortOption.distance:
        result.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        break;
      case _SortOption.rating:
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case _SortOption.deliveryTime:
        result.sort((a, b) => a.etaMins.compareTo(b.etaMins));
        break;
    }

    return result;
  }

  void _openRestaurant(RestaurantListing restaurant) {
    widget.onRestaurantSelected?.call(restaurant);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RestaurantMenuScreen()),
    );
  }

  void _openSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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

    final closest = [..._all]
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              resultCount: results.length,
              onBack: () => Navigator.of(context).maybePop(),
              searchController: _searchController,
              onSearchChanged: (v) => setState(() => _query = v),
              onSortTap: _openSortSheet,
            ),
            _FilterRow(
              active: _activeFilters,
              onToggle: (filter) {
                setState(() {
                  if (_activeFilters.contains(filter)) {
                    _activeFilters.remove(filter);
                  } else {
                    _activeFilters.add(filter);
                  }
                });
              },
            ),
            Expanded(
              child: results.isEmpty
                  ? const _EmptyState()
                  : ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 32),
                      children: [
                        _ClosestRail(
                          restaurants: closest.take(6).toList(),
                          onTap: _openRestaurant,
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'All nearby places',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                              Text(
                                '${results.length} results',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        for (final restaurant in results) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _RestaurantCard(
                              restaurant: restaurant,
                              onTap: () => _openRestaurant(restaurant),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Header
/// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  final int resultCount;
  final VoidCallback onBack;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSortTap;

  const _Header({
    required this.resultCount,
    required this.onBack,
    required this.searchController,
    required this.onSearchChanged,
    required this.onSortTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _RoundIconButton(icon: Icons.arrow_back_rounded, onTap: onBack),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Restaurants near you',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.65,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$resultCount ${resultCount == 1 ? 'place' : 'places'} '
                      'deliver to your location',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _RoundIconButton(icon: Icons.tune_rounded, onTap: onSortTap),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Search restaurants or cuisines',
                      hintStyle: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 21,
                        color: AppColors.textSecondary,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Material(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(15),
                child: InkWell(
                  onTap: onSortTap,
                  borderRadius: BorderRadius.circular(15),
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.swap_vert_rounded,
                      color: Colors.white,
                      size: 21,
                    ),
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

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Filter row
/// ---------------------------------------------------------------------------

class _FilterRow extends StatelessWidget {
  final Set<_QuickFilter> active;
  final ValueChanged<_QuickFilter> onToggle;

  const _FilterRow({required this.active, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _QuickFilter.values.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final filter = _QuickFilter.values[index];
            final selected = active.contains(filter);

            return Material(
              color: selected ? AppColors.primary : AppColors.background,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => onToggle(filter),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(
                        filter.icon,
                        size: 15,
                        color: selected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        filter.label,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
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

/// ---------------------------------------------------------------------------
/// Closest rail
/// ---------------------------------------------------------------------------

class _ClosestRail extends StatelessWidget {
  final List<RestaurantListing> restaurants;
  final ValueChanged<RestaurantListing> onTap;

  const _ClosestRail({required this.restaurants, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (restaurants.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 17, 16, 11),
          child: Row(
            children: [
              Text(
                'Closest to you',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: AppColors.textPrimary,
                ),
              ),
              Spacer(),
              Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 126,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: restaurants.length,
            separatorBuilder: (_, __) => const SizedBox(width: 11),
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];

              return Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  onTap: () => onTap(restaurant),
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    width: 92,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(7, 7, 7, 8),
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: SizedBox(
                                  width: 78,
                                  height: 70,
                                  child: _RestaurantImage(
                                    restaurant: restaurant,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: -2,
                                bottom: -4,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: restaurant.isOpenNow
                                        ? AppColors.success
                                        : AppColors.textMuted,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            restaurant.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${restaurant.distanceKm.toStringAsFixed(1)} km',
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
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

/// ---------------------------------------------------------------------------
/// Main restaurant card
/// ---------------------------------------------------------------------------

class _RestaurantCard extends StatelessWidget {
  final RestaurantListing restaurant;
  final VoidCallback onTap;

  const _RestaurantCard({required this.restaurant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 168,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _RestaurantImage(restaurant: restaurant),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: Row(
                      children: [
                        if (restaurant.isPromoted)
                          _ImageBadge(
                            icon: Icons.bolt_rounded,
                            label: 'PROMOTED',
                            dark: true,
                          ),
                        if (restaurant.isPromoted && restaurant.hasFreeDelivery)
                          const SizedBox(width: 6),
                        if (restaurant.hasFreeDelivery)
                          const _ImageBadge(
                            icon: Icons.delivery_dining_rounded,
                            label: 'FREE DELIVERY',
                            dark: false,
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardOverlay.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: restaurant.isOpenNow
                                  ? AppColors.success
                                  : Colors.white54,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            restaurant.isOpenNow ? 'Open now' : 'Closed',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurant.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.35,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              restaurant.cuisines.join(' · '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      _RatingBadge(rating: restaurant.rating),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(height: 1, color: AppColors.border),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.near_me_rounded,
                        size: 15,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${restaurant.distanceKm.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Icon(
                        Icons.schedule_rounded,
                        size: 15,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${restaurant.etaMins} mins',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        restaurant.priceLevel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestaurantImage extends StatelessWidget {
  final RestaurantListing restaurant;

  const _RestaurantImage({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    if (restaurant.imageUrl != null) {
      return Image.network(
        restaurant.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _PhotoFallback(icon: restaurant.fallbackIcon),
      );
    }

    return _PhotoFallback(icon: restaurant.fallbackIcon);
  }
}

class _PhotoFallback extends StatelessWidget {
  final IconData icon;

  const _PhotoFallback({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primarySoft, AppColors.surfaceAlt],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 38, color: AppColors.primary),
    );
  }
}

class _ImageBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool dark;

  const _ImageBadge({
    required this.icon,
    required this.label,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: dark ? AppColors.cardOverlay : Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: dark ? Colors.white : AppColors.success),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.35,
              color: dark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;

  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    final ratingColor = rating >= 4.3 ? AppColors.success : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: ratingColor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 15, color: ratingColor),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: ratingColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Sort sheet
/// ---------------------------------------------------------------------------

class _SortSheet extends StatelessWidget {
  final _SortOption current;
  final ValueChanged<_SortOption> onSelected;

  const _SortSheet({required this.current, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        10,
        20,
        18 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const Text(
            'Sort restaurants',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose how nearby places should be ordered.',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          for (final option in _SortOption.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Material(
                color: option == current
                    ? AppColors.primarySoft
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () => onSelected(option),
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 13,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          option == current
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          size: 20,
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
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: option == current
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        if (option == current)
                          const Icon(
                            Icons.check_rounded,
                            size: 19,
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Empty state
/// ---------------------------------------------------------------------------

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
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.storefront_outlined,
                size: 31,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No restaurants match right now',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try clearing a filter or searching something else.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Sample data — unchanged from the original screen.
/// ---------------------------------------------------------------------------

List<RestaurantListing> _sampleRestaurants() {
  return const [
    RestaurantListing(
      id: 'r1',
      name: "Napoli's Kitchen",
      imageUrl:
          'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=600&fit=crop',
      fallbackIcon: Icons.local_pizza,
      cuisines: ['Italian', 'Pizza'],
      rating: 4.6,
      reviewCount: 812,
      distanceKm: 0.8,
      etaMins: 25,
      isOpenNow: true,
      isPromoted: true,
      hasFreeDelivery: true,
      priceLevel: '₹₹',
    ),
    RestaurantListing(
      id: 'r2',
      name: 'Spice Route',
      imageUrl:
          'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=600&fit=crop',
      fallbackIcon: Icons.rice_bowl,
      cuisines: ['North Indian', 'Biryani'],
      rating: 4.4,
      reviewCount: 654,
      distanceKm: 1.2,
      etaMins: 32,
      isOpenNow: true,
      priceLevel: '₹₹',
    ),
    RestaurantListing(
      id: 'r3',
      name: 'Wich Please',
      imageUrl:
          'https://images.unsplash.com/photo-1466978913421-dad2ebd01d17?w=600&fit=crop',
      fallbackIcon: Icons.lunch_dining,
      cuisines: ['Burgers', 'American'],
      rating: 4.2,
      reviewCount: 305,
      distanceKm: 1.5,
      etaMins: 28,
      isOpenNow: true,
      hasFreeDelivery: true,
      priceLevel: '₹',
    ),
    RestaurantListing(
      id: 'r4',
      name: 'Sakura Sushi Bar',
      imageUrl:
          'https://images.unsplash.com/photo-1579027989536-b7b1f875659b?w=600&fit=crop',
      fallbackIcon: Icons.set_meal,
      cuisines: ['Japanese', 'Sushi'],
      rating: 4.7,
      reviewCount: 421,
      distanceKm: 2.3,
      etaMins: 40,
      isOpenNow: false,
      priceLevel: '₹₹₹',
    ),
    RestaurantListing(
      id: 'r5',
      name: 'Green Bowl Co.',
      imageUrl:
          'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=600&fit=crop',
      fallbackIcon: Icons.eco,
      cuisines: ['Healthy', 'Salads'],
      rating: 4.1,
      reviewCount: 96,
      distanceKm: 1.9,
      etaMins: 22,
      isOpenNow: true,
      hasFreeDelivery: true,
      priceLevel: '₹₹',
    ),
    RestaurantListing(
      id: 'r6',
      name: 'Momo Street',
      imageUrl:
          'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=600&fit=crop',
      fallbackIcon: Icons.dinner_dining,
      cuisines: ['Tibetan', 'Street Food'],
      rating: 4.5,
      reviewCount: 288,
      distanceKm: 2.6,
      etaMins: 35,
      isOpenNow: true,
      priceLevel: '₹',
    ),
    RestaurantListing(
      id: 'r7',
      name: 'La Pasta Casa',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBJSMfmwvvapG0ZHxYVePZV8uQK-WLKaOEBlNU9foogkBwzEY19ieziXMxOYMCX9IYuRqVLhcqWCTifN7QdZEEqEN8lDswHzWTC85QA716MmM_ZSZMnzW02rcdwwDJooMYoPnPnf3aPk-VikoWOdXQ20ZaHpC25Efb0cY9Ny4akg6_z0o_MckdyPF8P-9Pc5aqeflowj9BIXYHyx56_gOS9liUE9vu4vySXUoDz4bJZ3C_YHKPo8OqOLiFZ4ZtqCMc5fqX9v0UzPaKn',
      fallbackIcon: Icons.ramen_dining,
      cuisines: ['Italian', 'Continental'],
      rating: 3.9,
      reviewCount: 142,
      distanceKm: 3.1,
      etaMins: 45,
      isOpenNow: true,
      priceLevel: '₹₹₹',
    ),
    RestaurantListing(
      id: 'r8',
      name: 'Taco Fiesta',
      imageUrl:
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&fit=crop',
      fallbackIcon: Icons.tapas,
      cuisines: ['Mexican'],
      rating: 4.3,
      reviewCount: 178,
      distanceKm: 1.1,
      etaMins: 27,
      isOpenNow: false,
      priceLevel: '₹₹',
    ),
  ];
}

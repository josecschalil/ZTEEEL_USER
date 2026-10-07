import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_colors.dart';
import '../config/api_config.dart';
import '../services/restaurant_service.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/discovery_search_bar.dart';
import '../widgets/exploring_location.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/shimmer_loading.dart';
import 'RestuarantMenuScreen.dart';
import '../services/cart_service.dart';
import '../services/location_service.dart';
import '../services/discovery_preferences_service.dart';
import 'LocationPageScreen.dart';
import 'MainCartScreen.dart';
import 'NotificationScreen.dart';

export '../widgets/restaurant_card.dart';

typedef RestaurantListScreen = NearbyRestaurantsScreen;

RestaurantListing restaurantListingFromVendor(Map<String, dynamic> vendor) {
  final image = vendor['cover_image'] ?? vendor['icon_image'];
  final imageUrl = image is String && image.isNotEmpty
      ? (image.startsWith('http://') || image.startsWith('https://')
            ? image
            : '${ApiConfig.baseUrl}${image.startsWith('/') ? '' : '/'}$image')
      : null;

  final id = vendor['id']?.toString() ?? '';
  final name = vendor['business_name']?.toString().trim() ?? 'Restaurant';

  final List<String> cuisines = [];
  if (vendor['cuisines'] is List) {
    for (final c in vendor['cuisines'] as List) {
      final str = c?.toString().trim() ?? '';
      if (str.isNotEmpty) cuisines.add(str);
    }
  } else if (vendor['category']?.toString().trim().isNotEmpty == true) {
    final cat = vendor['category'].toString().trim();
    if (cat.isNotEmpty) cuisines.add(cat);
  }
  if (cuisines.isEmpty) cuisines.add('Multi-Cuisine');

  bool isPromoted = false;
  bool hasFreeDelivery = false;
  if (vendor['best_offer'] is Map) {
    isPromoted = true;
    final bestOffer = vendor['best_offer'] as Map;
    if (bestOffer['title']?.toString().toLowerCase().contains(
          'free delivery',
        ) ==
        true) {
      hasFreeDelivery = true;
    }
  }

  final distanceKm =
      double.tryParse(vendor['distance_km']?.toString() ?? '') ?? 0.0;
  final calculatedEta = (12 + distanceKm * 2.5).round().clamp(15, 90);
  final etaMins =
      int.tryParse(
        vendor['eta_minutes']?.toString() ??
            vendor['eta']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ??
            '',
      ) ??
      calculatedEta;
  final rating =
      double.tryParse(
        vendor['rating']?.toString() ??
            vendor['average_rating']?.toString() ??
            '',
      ) ??
      4.8;
  final reviewCount =
      int.tryParse(
        vendor['review_count']?.toString() ??
            vendor['rating_count']?.toString() ??
            '',
      ) ??
      120;
  final isOpenNow = vendor['is_open_now'] is bool
      ? vendor['is_open_now'] as bool
      : true;

  return RestaurantListing(
    id: id,
    name: name,
    imageUrl: imageUrl,
    fallbackIcon: Icons.restaurant_rounded,
    cuisines: cuisines,
    rating: rating,
    reviewCount: reviewCount,
    distanceKm: distanceKm,
    etaMins: etaMins,
    isOpenNow: isOpenNow,
    isPromoted: isPromoted,
    hasFreeDelivery: hasFreeDelivery,
    priceLevel: '₹₹',
  );
}

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
  final String? offerLabel;
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
    this.offerLabel,
    this.hasFreeDelivery = false,
  });
}

enum _QuickFilter { openNow, topRated, freeDelivery }

/// An optional starting filter for callers that open restaurant discovery from
/// a focused action on the Home feed. The screen remains fully usable without
/// a preset, preserving existing callers.
enum RestaurantBrowsePreset { under30Minutes, rated4Plus, openNow }

extension on _QuickFilter {
  String get label {
    switch (this) {
      case _QuickFilter.openNow:
        return 'Open now';
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
  final RestaurantBrowsePreset? preset;
  final bool showBackButton;
  final VoidCallback? onOpenCart;
  final double bottomOverlayPadding;
  final Future<void> Function()? onRefresh;

  const NearbyRestaurantsScreen({
    super.key,
    this.restaurants,
    this.onRestaurantSelected,
    this.preset,
    this.showBackButton = true,
    this.onOpenCart,
    this.bottomOverlayPadding = 0,
    this.onRefresh,
  });

  @override
  State<NearbyRestaurantsScreen> createState() =>
      _NearbyRestaurantsScreenState();
}

class _NearbyRestaurantsScreenState extends State<NearbyRestaurantsScreen> {
  List<RestaurantListing> _all = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _address = 'Choose your location';

  final Set<_QuickFilter> _activeFilters = {};
  _SortOption _sort = _SortOption.relevance;
  late double _maxDistanceKm;
  String _query = '';

  double get _maxAllowedRadius => DiscoveryPreferencesService.maxRadiusKm;

  @override
  void initState() {
    super.initState();
    _maxDistanceKm = _maxAllowedRadius;
    LocationService.addressNotifier.addListener(_onAddressChanged);
    DiscoveryPreferencesService.maxRadiusNotifier.addListener(_onRadiusPreferenceChanged);
    _restoreLocation();
    if (widget.preset == RestaurantBrowsePreset.openNow) {
      _activeFilters.add(_QuickFilter.openNow);
    }
    if (widget.restaurants != null && widget.restaurants!.isNotEmpty) {
      _all = List.from(widget.restaurants!);
    } else if (RestaurantService.cachedRestaurants.isNotEmpty) {
      _all = RestaurantService.cachedRestaurants
          .map(restaurantListingFromVendor)
          .toList();
      _loadLiveRestaurants(isSilent: true);
    } else {
      _loadLiveRestaurants();
    }
  }

  @override
  void dispose() {
    LocationService.addressNotifier.removeListener(_onAddressChanged);
    DiscoveryPreferencesService.maxRadiusNotifier.removeListener(_onRadiusPreferenceChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onRadiusPreferenceChanged() {
    if (!mounted) return;
    if (_maxDistanceKm > _maxAllowedRadius) {
      setState(() => _maxDistanceKm = _maxAllowedRadius);
    }
  }

  void _onAddressChanged() {
    if (!mounted) return;
    final live = LocationService.addressNotifier.value;
    if (_address != live) {
      setState(() => _address = live);
      _loadLiveRestaurants();
    }
  }

  Future<void> _restoreLocation() async {
    final saved = await LocationService.load();
    if (!mounted || saved == null) return;
    final newAddress = saved.address.isEmpty ? 'Selected location' : saved.address;
    LocationService.addressNotifier.value = newAddress;
    setState(() {
      _address = newAddress;
    });
  }

  Future<void> _openLocationPicker() async {
    final result = await Navigator.of(context).push<PickedLocation>(
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
    if (!mounted || result == null) return;
    final newAddress = result.address.isEmpty ? 'Selected location' : result.address;
    LocationService.addressNotifier.value = newAddress;
    setState(() {
      _address = newAddress;
    });
    _loadLiveRestaurants();
  }

  @override
  void didUpdateWidget(covariant NearbyRestaurantsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.restaurants != null) {
      setState(() {
        _all = List.from(widget.restaurants!);
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    if (widget.onRefresh != null) {
      await widget.onRefresh!();
      if (mounted && widget.restaurants != null) {
        setState(() {
          _all = List.from(widget.restaurants!);
          _isLoading = false;
        });
      }
      return;
    }
    await _loadLiveRestaurants(isSilent: true, forceRefresh: true);
  }

  Future<void> _loadLiveRestaurants({
    bool isSilent = false,
    bool forceRefresh = false,
  }) async {
    if (!isSilent && _all.isEmpty) {
      setState(() => _isLoading = true);
    }
    final vendors = await RestaurantService.fetchRestaurants(
      forceRefresh: forceRefresh,
    );
    if (!mounted) return;
    setState(() {
      _all = vendors.map(restaurantListingFromVendor).toList();
      _isLoading = false;
    });
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

      if (_maxDistanceKm < _maxAllowedRadius && r.distanceKm > _maxDistanceKm) {
        return false;
      }

      if (_activeFilters.contains(_QuickFilter.topRated) && r.rating < 4.3) {
        return false;
      }

      if (_activeFilters.contains(_QuickFilter.freeDelivery) &&
          !r.hasFreeDelivery) {
        return false;
      }

      if (widget.preset == RestaurantBrowsePreset.under30Minutes &&
          r.etaMins > 30) {
        return false;
      }

      if (widget.preset == RestaurantBrowsePreset.rated4Plus &&
          r.rating < 4.0) {
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

  String get _searchPillLabel => _maxDistanceKm < _maxAllowedRadius
      ? '${_maxDistanceKm.round()} km'
      : (_activeFilters.contains(_QuickFilter.openNow)
          ? 'Open now'
          : 'All shops');

  void _openRestaurant(RestaurantListing restaurant) {
    widget.onRestaurantSelected?.call(restaurant);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RestaurantMenuScreen(
          vendorId: restaurant.id,
          restaurantName: restaurant.name,
          heroImageUrl: restaurant.imageUrl,
          cuisine: restaurant.cuisines.join(' · '),
          isOpen: restaurant.isOpenNow,
        ),
      ),
    );
  }

  void _openSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (context) => _FilterAndSortSheet(
        currentSort: _sort,
        currentDistance: _maxDistanceKm.clamp(1.0, _maxAllowedRadius),
        maxAllowedRadius: _maxAllowedRadius,
        activeFilters: _activeFilters,
        onApply: (distance, sort, filters) {
          setState(() {
            _maxDistanceKm = distance;
            _sort = sort;
            _activeFilters
              ..clear()
              ..addAll(filters);
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;

    final closest = [...results]
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    return Scaffold(
      backgroundColor: AppColors.white,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: AppColors.transparent,
          systemStatusBarContrastEnforced: false,
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              AppTopBar(
                showBackButton: widget.showBackButton,
                onOpenCart: widget.onOpenCart,
              ),
              _Header(
                resultCount: results.length,
                searchController: _searchController,
                onSearchChanged: (v) => setState(() => _query = v),
                selectedFilterLabel: _searchPillLabel,
                onOpenNowToggle: () {
                  setState(() {
                    if (_activeFilters.contains(_QuickFilter.openNow)) {
                      _activeFilters.remove(_QuickFilter.openNow);
                    } else {
                      _activeFilters.add(_QuickFilter.openNow);
                    }
                  });
                },
                onSortTap: _openSortSheet,
              ),
              _FilterRow(
                active: _activeFilters,
                maxDistanceKm: _maxDistanceKm,
                maxAllowedRadius: _maxAllowedRadius,
                onDistanceTap: _openSortSheet,
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
                child: RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.white,
                  onRefresh: _handleRefresh,
                  child: _isLoading
                      ? _RestaurantListLoadingSkeleton(
                          bottomOverlayPadding: widget.bottomOverlayPadding,
                        )
                      : results.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: EdgeInsets.fromLTRB(
                            16,
                            8,
                            16,
                            32 + widget.bottomOverlayPadding,
                          ),
                          children: const [_EmptyState()],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: EdgeInsets.fromLTRB(
                            16,
                            8,
                            16,
                            32 + widget.bottomOverlayPadding,
                          ),
                          itemCount: results.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final restaurant = results[index];
                            return RestaurantCard(
                              key: ValueKey('restaurant-item-${restaurant.id}'),
                              restaurant: restaurant,
                              onTap: () => _openRestaurant(restaurant),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
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
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String selectedFilterLabel;
  final VoidCallback onOpenNowToggle;
  final VoidCallback onSortTap;

  const _Header({
    required this.resultCount,
    required this.searchController,
    required this.onSearchChanged,
    required this.selectedFilterLabel,
    required this.onOpenNowToggle,
    required this.onSortTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
                      '$resultCount ${resultCount == 1 ? 'place' : 'places'} deliver to your location',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: DiscoverySearchBar.editable(
                  hintText: 'Search restaurants or cuisines',
                  selectedFilterLabel: selectedFilterLabel,
                  backgroundColor: AppColors.surfaceRaised,
                  showFilterPill: false,
                  controller: searchController,
                  onChanged: onSearchChanged,
                  onClear: () {
                    searchController.clear();
                    onSearchChanged('');
                  },
                  shellKey: const ValueKey('nearby-search-field'),
                  searchKey: const ValueKey('nearby-search'),
                  filterKey: const ValueKey('nearby-open-now-toggle'),
                  onFilterTap: onOpenNowToggle,
                ),
              ),
              const SizedBox(width: 9),
              Material(
                color: AppColors.surfaceRaised,
                shape: const CircleBorder(),
                child: InkWell(
                  key: const ValueKey('nearby-sort-button'),
                  onTap: onSortTap,
                  customBorder: const CircleBorder(),
                  child: const SizedBox(
                    width: 52,
                    height: 52,
                    child: Icon(
                      Icons.tune_rounded,
                      color: AppColors.textPrimary,
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
      color: AppColors.surfaceRaised,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
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
  final double maxDistanceKm;
  final double maxAllowedRadius;
  final ValueChanged<_QuickFilter> onToggle;
  final VoidCallback onDistanceTap;

  const _FilterRow({
    required this.active,
    required this.maxDistanceKm,
    required this.maxAllowedRadius,
    required this.onToggle,
    required this.onDistanceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: SizedBox(
        height: 38,
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          children: [
            if (maxDistanceKm < maxAllowedRadius) ...[
              Material(
                color: AppColors.orange,
                shape: const StadiumBorder(
                  side: BorderSide(color: AppColors.orange, width: 1),
                ),
                child: InkWell(
                  onTap: onDistanceTap,
                  customBorder: const StadiumBorder(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.near_me_rounded, size: 15, color: AppColors.white),
                        const SizedBox(width: 6),
                        Text(
                          'Within ${maxDistanceKm.round()} km',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            ..._QuickFilter.values.map((filter) {
              final selected = active.contains(filter);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Material(
                  color: selected ? AppColors.orange : AppColors.white,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: selected ? AppColors.orange : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  child: InkWell(
                    key: ValueKey('nearby-filter-${filter.name}'),
                    onTap: () => onToggle(filter),
                    customBorder: const StadiumBorder(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Icon(
                            filter.icon,
                            size: 15,
                            color: selected ? AppColors.white : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            filter.label,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                              color: selected ? AppColors.white : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
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
          height: 126.0 + (MediaQuery.textScalerOf(context).scale(12.0) - 12.0) * 4,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: restaurants.length,
            separatorBuilder: (_, __) => const SizedBox(width: 11),
            itemBuilder: (context, index) {
              final restaurant = restaurants[index];

              return Container(
                key: ValueKey('nearby-closest-${restaurant.id}'),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.07),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.025),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: AppColors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => onTap(restaurant),
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
                                    child: RestaurantImage(
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
                                          ? AppColors.green
                                          : AppColors.textMuted,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.white,
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
/// Filter & Sort sheet
/// ---------------------------------------------------------------------------

class _FilterAndSortSheet extends StatelessWidget {
  final _SortOption currentSort;
  final double currentDistance;
  final double maxAllowedRadius;
  final Set<_QuickFilter> activeFilters;
  final void Function(double distance, _SortOption sort, Set<_QuickFilter> filters) onApply;

  const _FilterAndSortSheet({
    required this.currentSort,
    required this.currentDistance,
    required this.maxAllowedRadius,
    required this.activeFilters,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    double tempDistance = currentDistance;
    _SortOption tempSort = currentSort;
    final Set<_QuickFilter> tempFilters = Set.from(activeFilters);

    return StatefulBuilder(
      builder: (context, setSheetState) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            24 + MediaQuery.of(context).padding.bottom,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter & Sort',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (tempDistance < maxAllowedRadius || tempSort != _SortOption.relevance || tempFilters.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setSheetState(() {
                            tempDistance = maxAllowedRadius;
                            tempSort = _SortOption.relevance;
                            tempFilters.clear();
                          });
                        },
                        child: const Text(
                          'Reset all',
                          style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // DISTANCE METER SLIDER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.near_me_rounded, size: 17, color: AppColors.orange),
                        SizedBox(width: 6),
                        Text(
                          'Maximum Distance',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.orangeTint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tempDistance >= maxAllowedRadius ? '${maxAllowedRadius.round()} km (Max)' : 'Within ${tempDistance.round()} km',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.orange,
                    inactiveTrackColor: const Color(0xFFE5E7EB),
                    thumbColor: AppColors.orange,
                    overlayColor: AppColors.orange.withValues(alpha: 0.15),
                    trackHeight: 4.0,
                  ),
                  child: Slider(
                    value: tempDistance,
                    min: 1.0,
                    max: maxAllowedRadius,
                    divisions: maxAllowedRadius.round() - 1 > 0 ? maxAllowedRadius.round() - 1 : 1,
                    label: tempDistance >= maxAllowedRadius ? '${maxAllowedRadius.round()} km (Max)' : '${tempDistance.round()} km',
                    onChanged: (val) {
                      setSheetState(() => tempDistance = val);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [5.0, 10.0, 25.0, 50.0, maxAllowedRadius].where((p) => p <= maxAllowedRadius).toSet().toList().map((preset) {
                      final isSelected = (tempDistance - preset).abs() < 1.0;
                      return GestureDetector(
                        onTap: () => setSheetState(() => tempDistance = preset),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.orange
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            preset == maxAllowedRadius ? '${preset.toInt()} km (Max)' : '${preset.toInt()} km',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 18),

                // SORT OPTIONS
                const Text(
                  'Sort By',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _SortOption.values.map((option) {
                    final isSelected = option == tempSort;
                    return GestureDetector(
                      onTap: () => setSheetState(() => tempSort = option),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.orangeTint : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.orange : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                              size: 15,
                              color: isSelected ? AppColors.orange : AppColors.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              option.label,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),

                // QUICK FILTERS
                const Text(
                  'Quick Filters',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _QuickFilter.values.map((filter) {
                    final isSelected = tempFilters.contains(filter);
                    return GestureDetector(
                      onTap: () {
                        setSheetState(() {
                          if (isSelected) {
                            tempFilters.remove(filter);
                          } else {
                            tempFilters.add(filter);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.orange : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.orange : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              filter.icon,
                              size: 15,
                              color: isSelected ? AppColors.white : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              filter.label,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? AppColors.white : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // APPLY BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      onApply(tempDistance, tempSort, tempFilters);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                    ),
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

class _RestaurantListLoadingSkeleton extends StatelessWidget {
  final double bottomOverlayPadding;

  const _RestaurantListLoadingSkeleton({this.bottomOverlayPadding = 0});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 32 + bottomOverlayPadding),
      children: [
        const _ClosestRailSkeleton(),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              ShimmerLoading(
                child: Container(
                  width: 140,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const Spacer(),
              ShimmerLoading(
                child: Container(
                  width: 60,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < 3; i++) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: RestaurantCardSkeleton(),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _ClosestRailSkeleton extends StatelessWidget {
  const _ClosestRailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 17, 16, 11),
          child: ShimmerLoading(
            child: Container(
              width: 120,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.surfaceRaised,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 126.0 + (MediaQuery.textScalerOf(context).scale(12.0) - 12.0) * 4,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(width: 11),
            itemBuilder: (context, index) {
              return ShimmerLoading(
                child: Container(
                  width: 92,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(7, 7, 7, 8),
                  child: Column(
                    children: [
                      Container(
                        width: 78,
                        height: 70,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceRaised,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 65,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceRaised,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 45,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceRaised,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
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

List<RestaurantListing> sampleRestaurants() => const [];

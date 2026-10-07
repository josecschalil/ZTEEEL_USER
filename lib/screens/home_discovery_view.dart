import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';
import '../services/food_tag_service.dart';
import '../services/location_service.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/category_row.dart';
import '../widgets/discovery_search_bar.dart';
import '../widgets/exploring_location.dart';
import '../widgets/offer_widgets.dart';
import 'DealsScreen.dart';
import 'FoodTypeShopScreen.dart';
import 'LocationPageScreen.dart';
import 'NotificationScreen.dart';
import 'OfferExplanationScreen.dart';
import 'RestaurantListScreen.dart';
import 'RestuarantMenuScreen.dart';
import 'SearchScreen.dart';

class HomeRestaurant {
  final String id;
  final String name;
  final String cuisine;
  final double rating;
  final int reviewCount;
  final String distance;
  final String eta;
  final bool isOpen;
  final String? imageUrl;
  final String? offerLabel;

  const HomeRestaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.eta,
    required this.isOpen,
    this.imageUrl,
    this.offerLabel,
  });

  RestaurantListing toRestaurantListing() => RestaurantListing(
    id: id,
    name: name,
    imageUrl: imageUrl,
    fallbackIcon: Icons.restaurant_menu_rounded,
    cuisines: cuisine
        .split('·')
        .map((v) => v.trim())
        .where((v) => v.isNotEmpty)
        .toList(),
    rating: rating,
    reviewCount: reviewCount,
    distanceKm: double.tryParse(distance.split(' ').first) ?? 1.2,
    etaMins: int.tryParse(eta.split(RegExp(r'[^0-9]')).first) ?? 25,
    isOpenNow: isOpen,
    isPromoted: offerLabel != null,
    offerLabel: offerLabel,
    hasFreeDelivery:
        offerLabel?.toLowerCase().contains('free delivery') == true,
    priceLevel: '₹₹',
  );
}

class HomeDiscoveryView extends StatefulWidget {
  final List<HomeRestaurant> restaurants;
  final List<Deal> deals;
  final VoidCallback onSeeAllDeals;
  final VoidCallback? onOpenCart;
  final int cartItemCount;
  final bool isLoadingRestaurants;
  final bool isLoadingDeals;
  final List<FoodTag> foodTags;
  final bool isLoadingFoodTags;
  final String firstName;
  final double bottomOverlayPadding;
  final Future<void> Function()? onRefresh;

  const HomeDiscoveryView({
    super.key,
    required this.restaurants,
    required this.deals,
    required this.onSeeAllDeals,
    this.onOpenCart,
    this.cartItemCount = 0,
    this.isLoadingRestaurants = false,
    this.isLoadingDeals = false,
    this.foodTags = const [],
    this.isLoadingFoodTags = false,
    this.firstName = '',
    this.bottomOverlayPadding = 0,
    this.onRefresh,
  });

  @override
  State<HomeDiscoveryView> createState() => _HomeDiscoveryViewState();
}

class _HomeDiscoveryViewState extends State<HomeDiscoveryView> {
  String _address = 'Choose your location';

  @override
  void initState() {
    super.initState();
    LocationService.addressNotifier.addListener(_onAddressChanged);
    _restoreLocation();
  }

  @override
  void dispose() {
    LocationService.addressNotifier.removeListener(_onAddressChanged);
    super.dispose();
  }

  void _onAddressChanged() {
    if (!mounted) return;
    final live = LocationService.addressNotifier.value;
    if (_address != live) {
      setState(() => _address = live);
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
  }

  void _openRestaurants({RestaurantBrowsePreset? preset}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NearbyRestaurantsScreen(
          restaurants: widget.restaurants
              .map((r) => r.toRestaurantListing())
              .toList(),
          preset: preset,
        ),
      ),
    );
  }

  void _openSearchDiscovery(FoodTag? tag) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FoodTypeShopsScreen(
          foodType: tag?.name ?? 'All',
          foodTagId: tag?.id,
          foodTags: widget.foodTags,
          autoFocusSearch: tag == null,
        ),
      ),
    );
  }

  OfferCardOption _optionForIndex(int index) {
    switch (index % 3) {
      case 0:
        return OfferCardOption.dark;
      case 1:
        return OfferCardOption.white;
      case 2:
      default:
        return OfferCardOption.gradient;
    }
  }

  ImageProvider _foodImageFor(int index) {
    final assetIndex = (index % 5) + 1;
    return AssetImage('assets/images/offers/food_0$assetIndex.png');
  }

  OfferCardData _dealToOfferCardData(Deal deal) {
    final index = widget.deals.indexOf(deal);
    final option = _optionForIndex(index >= 0 ? index : 0);
    final foodImage = _foodImageFor(index >= 0 ? index : 0);

    return OfferCardData(
      id: deal.id ?? deal.title,
      title: deal.title,
      discount: deal.discount,
      restaurant: deal.restaurant,
      distance: deal.distance,
      category: deal.cuisine,
      timeLeft: deal.timeLeft,
      subtitle: deal.description.isNotEmpty
          ? deal.description
          : 'Special discount on select orders',
      savings: deal.discount.isNotEmpty ? 'Save ${deal.discount}' : 'Save ₹120',
      option: option,
      foodImage: foodImage,
    );
  }

  void _openDeal(Deal deal) {
    final cardData = _dealToOfferCardData(deal);
    final subtitle = deal.description.isNotEmpty
        ? deal.description
        : [
            deal.restaurant,
            deal.distance,
          ].where((value) => value.isNotEmpty).join(' · ');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OfferExplanationScreen(
          title: deal.title,
          subtitle: subtitle.isEmpty ? 'On selected items' : subtitle,
          badge: deal.discount,
          expiry: deal.timeLeft.isEmpty ? 'Limited time' : deal.timeLeft,
          restaurantName: deal.restaurant,
          offerCardData: cardData,
          vendorId: deal.vendorId,
          dealId: deal.id ?? deal.title,
          discountPercent: deal.discountPercent,
          scopeType: deal.scopeType,
          itemIds: deal.itemIds,
          categoryIds: deal.categoryIds,
        ),
      ),
    );
  }

  String get _headline {
    if (widget.isLoadingDeals || widget.deals.isEmpty) {
      return 'Discover your next favorite meal.';
    }
    if (widget.deals.length == 1) return '1 offer near you';
    return '${widget.deals.length} offers near you';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: AppColors.transparent,
        systemStatusBarContrastEnforced: false,
      ),
      child: Material(
        color: AppColors.white,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFFFFF0EA),
                Color(0xFFFFF7F4),
                AppColors.white,
              ],
              stops: [0.0, 0.28, 0.70],
            ),
          ),
          child: RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.white,
            onRefresh: widget.onRefresh ?? () async {},
            child: CustomScrollView(
              key: const PageStorageKey('home-discovery-feed'),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTopBar(
                        onOpenCart: widget.onOpenCart,
                        locationKey: const ValueKey('home-location'),
                        notificationsKey: const ValueKey('home-notifications'),
                        cartKey: const ValueKey('home-cart'),
                      ),
                      const SizedBox(height: 12),
                      _HomeSearchBar(
                        onRestaurantsTap: () => _openRestaurants(),
                        onOpenNow: () => _openRestaurants(
                          preset: RestaurantBrowsePreset.openNow,
                        ),
                        onSearchTap: () => _openSearchDiscovery(null),
                      ),
                      const SizedBox(height: 6),
                      _CategoryRow(
                        foodTags: widget.foodTags,
                        isLoading: widget.isLoadingFoodTags,
                        onTagTap: _openSearchDiscovery,
                      ),
                      const SizedBox(height: 6),
                      widget.isLoadingDeals && widget.deals.isEmpty
                          ? const OfferRail(offers: [], isLoading: true)
                          : widget.deals.isEmpty
                          ? const _HomeEmptyState(
                              message:
                                  'No offers available right now. Check back soon.',
                            )
                          : OfferRail(
                              offers: widget.deals.map(_dealToOfferCardData).toList(),
                              isLoading: widget.isLoadingDeals,
                              onOfferTap: (card) {
                                final deal = widget.deals.firstWhere(
                                  (d) => (d.id ?? d.title) == card.id,
                                  orElse: () => Deal(
                                    id: card.id,
                                    title: card.title,
                                    restaurant: card.restaurant,
                                    distance: card.distance,
                                    discount: card.discount,
                                    timeLeft: card.timeLeft,
                                    imageUrl: '',
                                  ),
                                );
                                _openDeal(deal);
                              },
                              onSeeAll: widget.onSeeAllDeals,
                            ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: _HomeSectionHeader(
                title: 'Restaurants near you',
                actionKey: 'home-see-all-restaurants',
                onAction: _openRestaurants,
              ),
            ),
            if (widget.isLoadingRestaurants && widget.restaurants.isEmpty)
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(18, 4, 18, 20),
                sliver: SliverToBoxAdapter(child: _RestaurantFeedSkeleton()),
              )
            else if (widget.restaurants.isEmpty)
              const SliverToBoxAdapter(
                child: _HomeEmptyState(
                  message:
                      'Restaurants will appear here when they are available for your location.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                sliver: SliverList.separated(
                  itemCount: widget.restaurants.length,
                  itemBuilder: (context, index) => RestaurantCard(
                    key: ValueKey(
                      'home-restaurant-${widget.restaurants[index].id}',
                    ),
                    restaurant: widget.restaurants[index].toRestaurantListing(),
                    onTap: () {
                      final restaurant = widget.restaurants[index];
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RestaurantMenuScreen(
                            vendorId: restaurant.id,
                            restaurantName: restaurant.name,
                            heroImageUrl: restaurant.imageUrl,
                            cuisine: restaurant.cuisine,
                            isOpen: restaurant.isOpen,
                          ),
                        ),
                      );
                    },
                  ),
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                ),
              ),
              if (widget.bottomOverlayPadding > 0)
                SliverToBoxAdapter(
                  child: SizedBox(height: widget.bottomOverlayPadding + 16),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
}

class _HomeSearchBar extends StatelessWidget {
  final VoidCallback onRestaurantsTap;
  final VoidCallback onOpenNow;
  final VoidCallback? onSearchTap;

  const _HomeSearchBar({
    required this.onRestaurantsTap,
    required this.onOpenNow,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Expanded(
            child: Hero(
              tag: 'discovery_search_bar_hero',
              child: Material(
                color: Colors.transparent,
                child: DiscoverySearchBar.navigation(
                  hintText: 'Search food...',
                  selectedFilterLabel: 'Open now',
                  shellKey: const ValueKey('home-search-field'),
                  searchKey: const ValueKey('home-search'),
                  filterKey: const ValueKey('home-open-now'),
                  onSearchTap: onSearchTap ??
                      () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SearchScreen(),
                            ),
                          ),
                  onFilterTap: onOpenNow,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _RoundIconButton(
            key: const ValueKey('home-restaurants-btn'),
            icon: Icons.restaurant_rounded,
            tooltip: 'Browse restaurants',
            size: 52,
            onTap: onRestaurantsTap,
          ),
        ],
      ),
    );
  }
}

typedef _CategoryRow = CategoryRow;


class _HomeSectionHeader extends StatelessWidget {
  final String title;
  final String actionKey;
  final VoidCallback onAction;

  const _HomeSectionHeader({
    required this.title,
    required this.actionKey,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 10, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            key: ValueKey(actionKey),
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.orange,
              minimumSize: const Size(64, 44),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              textStyle: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            child: const Text('See all'),
          ),
        ],
      ),
    );
  }
}

class _RestaurantFeedSkeleton extends StatelessWidget {
  const _RestaurantFeedSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: index == 2 ? 0 : 14),
          child: Semantics(
            label: 'Loading restaurants',
            container: true,
            child: const RestaurantCardSkeleton(),
          ),
        ),
      ),
    );
  }
}

class _HomeEmptyState extends StatelessWidget {
  final String message;

  const _HomeEmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(message, style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final double size;

  const _RoundIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Center(
              child: Icon(icon, size: 21, color: AppColors.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}

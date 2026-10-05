import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';
import '../services/food_tag_service.dart';
import '../services/location_service.dart';
import '../widgets/category_row.dart';
import '../widgets/discovery_search_bar.dart';
import 'DealsScreen.dart';
import 'FoodTypeShopScreen.dart';
import 'LocationPageScreen.dart';
import 'NotificationScreen.dart';
import 'OfferExplanationScreen.dart';
import 'RestuarantMenuScreen.dart';
import 'RestaurantListScreen.dart';
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
    fallbackIcon: Icons.restaurant_rounded,
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
    hasFreeDelivery:
        offerLabel?.toLowerCase().contains('free delivery') == true,
    priceLevel: '₹₹',
  );
}

class HomeDiscoveryView extends StatefulWidget {
  final List<HomeRestaurant> restaurants;
  final List<Deal> deals;
  final VoidCallback onSeeAllDeals;
  final VoidCallback onOpenCart;
  final int cartItemCount;
  final bool isLoadingRestaurants;
  final bool isLoadingDeals;
  final List<FoodTag> foodTags;
  final bool isLoadingFoodTags;
  final String firstName;

  const HomeDiscoveryView({
    super.key,
    required this.restaurants,
    required this.deals,
    required this.onSeeAllDeals,
    required this.onOpenCart,
    this.cartItemCount = 0,
    this.isLoadingRestaurants = false,
    this.isLoadingDeals = false,
    this.foodTags = const [],
    this.isLoadingFoodTags = false,
    this.firstName = '',
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
          restaurants: widget.restaurants.isEmpty
              ? null
              : widget.restaurants.map((r) => r.toRestaurantListing()).toList(),
          preset: preset,
        ),
      ),
    );
  }

  void _openSearchDiscovery(FoodTag? tag) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) =>
            FoodTypeShopsScreen(
              foodType: tag?.name ?? 'All',
              foodTagId: tag?.id,
              foodTags: widget.foodTags,
              autoFocusSearch: tag == null,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  void _openDeal(Deal deal) {
    final subtitle = deal.description.isNotEmpty
        ? deal.description
        : [
            deal.restaurant,
            deal.distance,
          ].where((value) => value.isNotEmpty).join(' · ');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OfferExplanationScreen(
          title: deal.title,
          subtitle: subtitle.isEmpty ? 'Special offer' : subtitle,
          badge: deal.discount,
          expiry: deal.timeLeft.isEmpty ? 'Limited time' : deal.timeLeft,
          gradientColors: _restaurantOfferGradientFor(deal),
          restaurantName: deal.restaurant,
        ),
      ),
    );
  }

  String get _headline {
    if (widget.isLoadingDeals || widget.deals.isEmpty) {
      return 'Discover your next favorite meal.';
    }
    if (widget.deals.length == 1) return 'There is 1 food offer near you.';
    return 'There are ${widget.deals.length} food offers near you.';
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
        child: CustomScrollView(
          key: const PageStorageKey('home-discovery-feed'),
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                color: AppColors.white,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HomeHeader(
                        address: _address,
                        cartItemCount: widget.cartItemCount,
                        onLocation: _openLocationPicker,
                        onOpenCart: widget.onOpenCart,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.firstName.isEmpty
                                  ? 'Hello!'
                                  : 'Hello, ${widget.firstName}!',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 320),
                              child: Text(
                                _headline,
                                key: const ValueKey('home-offer-count'),
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _HomeSearchBar(
                        onMap: _openLocationPicker,
                        onOpenNow: () => _openRestaurants(
                          preset: RestaurantBrowsePreset.openNow,
                        ),
                        onSearchTap: () => _openSearchDiscovery(null),
                      ),
                      const SizedBox(height: 14),
                      _CategoryRow(
                        foodTags: widget.foodTags,
                        isLoading: widget.isLoadingFoodTags,
                        onTagTap: _openSearchDiscovery,
                      ),
                      const SizedBox(height: 18),
                      widget.isLoadingDeals && widget.deals.isEmpty
                          ? const _OfferRail(isLoading: true)
                          : widget.deals.isEmpty
                          ? const _HomeEmptyState(
                              message:
                                  'No offers available right now. Check back soon.',
                            )
                          : _OfferRail(
                              itemCount: widget.deals.length,
                              onSeeAll: widget.onSeeAllDeals,
                              itemBuilder: (context, index) {
                                final deal = widget.deals[index];
                                return _OfferCard(
                                  deal: deal,
                                  onTap: () => _openDeal(deal),
                                );
                              },
                            ),
                      const SizedBox(height: 18),
                    ],
                  ),
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
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final String address;
  final int cartItemCount;
  final VoidCallback onLocation;
  final VoidCallback onOpenCart;

  const _HomeHeader({
    required this.address,
    required this.cartItemCount,
    required this.onLocation,
    required this.onOpenCart,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 10, 0),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              key: const ValueKey('home-location'),
              onTap: onLocation,
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 44,
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            key: const ValueKey('home-notifications'),
            tooltip: 'Notifications',
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            icon: const Icon(Icons.notifications_none_rounded, size: 22),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
          Semantics(
            label: 'Cart, $cartItemCount items',
            child: IconButton(
              key: const ValueKey('home-cart'),
              tooltip: 'Cart',
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              onPressed: onOpenCart,
              icon: Badge(
                key: const ValueKey('home-cart-badge'),
                isLabelVisible: cartItemCount > 0,
                backgroundColor: AppColors.orange,
                textColor: AppColors.textOnAccent,
                label: Text(cartItemCount > 99 ? '99+' : '$cartItemCount'),
                child: const Icon(Icons.shopping_cart_outlined, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeSearchBar extends StatelessWidget {
  final VoidCallback onMap;
  final VoidCallback onOpenNow;
  final VoidCallback? onSearchTap;

  const _HomeSearchBar({
    required this.onMap,
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
                              builder: (_) => const SearchScreen(),
                            ),
                          ),
                  onFilterTap: onOpenNow,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _RoundIconButton(
            key: const ValueKey('home-map'),
            icon: Icons.map_outlined,
            tooltip: 'Choose location on map',
            size: 52,
            onTap: onMap,
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
      padding: const EdgeInsets.fromLTRB(18, 0, 10, 8),
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

typedef _RailItemBuilder = Widget Function(BuildContext context, int index);

class _OfferRail extends StatelessWidget {
  final int itemCount;
  final _RailItemBuilder? itemBuilder;
  final bool isLoading;
  final VoidCallback? onSeeAll;

  const _OfferRail({
    this.itemCount = 0,
    this.itemBuilder,
    this.isLoading = false,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 36)
            .clamp(280.0, 320.0)
            .toDouble();
        final height = width * 152 / 320;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 10, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Offers 🔥",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                  if (!isLoading)
                    TextButton(
                      key: const ValueKey('home-see-all-deals'),
                      onPressed: onSeeAll,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.orange,
                        minimumSize: const Size(64, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        textStyle: Theme.of(context).textTheme.labelLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      child: const Text('See all'),
                    ),
                ],
              ),
            ),
            SizedBox(
              height: height,
              child: ListView.separated(
                key: const PageStorageKey('home-offers-rail'),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                itemCount: isLoading ? 3 : itemCount,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) => SizedBox(
                  width: width,
                  child: isLoading
                      ? const _OfferSkeletonCard()
                      : itemBuilder!(context, index),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OfferCard extends StatelessWidget {
  final Deal deal;
  final VoidCallback onTap;

  const _OfferCard({required this.deal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final gradient = _restaurantOfferGradientFor(deal);
    return Material(
      color: AppColors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        key: ValueKey('home-deal-${deal.id ?? deal.title}'),
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: gradient,
                  ),
                ),
              ),
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
              Positioned(
                left: 14,
                right: 14,
                top: 13,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _OfferPill(label: deal.discount),
                    _OfferPill(
                      label: deal.timeLeft.isEmpty
                          ? 'Limited time'
                          : deal.timeLeft,
                      icon: Icons.timer_outlined,
                      dark: true,
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 14,
                right: 12,
                bottom: 13,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deal.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.3,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            [
                              deal.restaurant,
                              deal.distance,
                            ].where((value) => value.isNotEmpty).join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
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

class _OfferPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool dark;

  const _OfferPill({required this.label, this.icon, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: dark
            ? AppColors.black.withValues(alpha: 0.38)
            : AppColors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: AppColors.white),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

List<Color> _restaurantOfferGradientFor(Deal deal) {
  final value = deal.id ?? deal.title;
  final index = value.codeUnits.fold<int>(0, (sum, codeUnit) => sum + codeUnit);
  return restaurantOfferGradients[index % restaurantOfferGradients.length];
}


class _OfferSkeletonCard extends StatelessWidget {
  const _OfferSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading offers',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(18),
        ),
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
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
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

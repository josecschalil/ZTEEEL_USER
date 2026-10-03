import 'dart:async';

import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../services/location_service.dart';
import 'DealsScreen.dart';
import 'FoodTypeShopScreen.dart' hide AppColors;
import 'LocationPageScreen.dart';
import 'NotificationScreen.dart';
import 'PopularFoodScreen.dart' hide AppColors;
import 'RestuarantMenuScreen.dart';
import 'RestaurantListScreen.dart' hide AppColors;
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
}

class HomeCategory {
  final String label;
  final IconData icon;

  const HomeCategory(this.label, this.icon);
}

const homeCategories = [
  HomeCategory('Biryani', Icons.rice_bowl_rounded),
  HomeCategory('Pizza', Icons.local_pizza_rounded),
  HomeCategory('Burger', Icons.lunch_dining_rounded),
  HomeCategory('Chinese', Icons.ramen_dining_rounded),
  HomeCategory('Drinks', Icons.local_drink_rounded),
];

class HomeDiscoveryView extends StatelessWidget {
  final List<HomeRestaurant> restaurants;
  final List<Deal> deals;
  final VoidCallback onSeeAllDeals;

  const HomeDiscoveryView({
    super.key,
    required this.restaurants,
    required this.deals,
    required this.onSeeAllDeals,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        key: const ValueKey('home-discovery-feed'),
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _HomeHeader()),
          SliverToBoxAdapter(child: _HomeSearchBar()),
          SliverToBoxAdapter(
            child: _QuickActions(onSeeAllDeals: onSeeAllDeals),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
              child: _OfferCarousel(deals: deals, onSeeAllDeals: onSeeAllDeals),
            ),
          ),
          SliverToBoxAdapter(
            child: _HomeSectionHeader(
              title: 'What are you craving?',
              actionLabel: 'See all',
              onAction: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PopularFoodItemsScreen(),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: _CategoryRow()),
          SliverToBoxAdapter(
            child: _HomeSectionHeader(
              title: 'Popular near you',
              actionLabel: 'See all',
              onAction: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => NearbyRestaurantsScreen()),
              ),
            ),
          ),
          if (restaurants.isEmpty)
            const SliverToBoxAdapter(child: _RestaurantsEmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 112),
              sliver: SliverList.separated(
                itemCount: restaurants.length,
                itemBuilder: (context, index) =>
                    _RestaurantRow(restaurant: restaurants[index]),
                separatorBuilder: (_, _) =>
                    const Divider(height: 28, color: AppColors.border),
              ),
            ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatefulWidget {
  @override
  State<_HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<_HomeHeader> {
  String _label = 'Delivering to';
  String _address = 'Choose your location';

  @override
  void initState() {
    super.initState();
    _restoreLocation();
  }

  Future<void> _restoreLocation() async {
    final saved = await LocationService.load();
    if (!mounted || saved == null) return;
    setState(() {
      _label = saved.label.isEmpty ? 'Delivering to' : saved.label;
      _address = saved.address.isEmpty ? 'Selected location' : saved.address;
    });
  }

  Future<void> _openLocationPicker() async {
    final result = await Navigator.of(context).push<PickedLocation>(
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
    if (!mounted || result == null) return;
    setState(() {
      _label = result.label.isEmpty ? 'Delivering to' : result.label;
      _address = result.address.isEmpty ? 'Selected location' : result.address;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              key: const ValueKey('home-location'),
              onTap: _openLocationPicker,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _label == 'Delivering to' ? _label : 'Delivering to',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.35,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            key: const ValueKey('home-notifications'),
            tooltip: 'Notifications',
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.textPrimary,
              size: 22,
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                key: const ValueKey('home-search'),
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const SearchScreen())),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 16),
                    Icon(Icons.search_rounded, color: AppColors.textMuted),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Search dishes or restaurants',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _RoundIconButton(
              key: const ValueKey('home-filter'),
              compact: true,
              icon: Icons.tune_rounded,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => NearbyRestaurantsScreen()),
              ),
            ),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onSeeAllDeals;

  const _QuickActions({required this.onSeeAllDeals});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        key: const ValueKey('home-quick-actions'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
        children: [
          _QuickAction(
            label: 'Offers',
            icon: Icons.local_offer_rounded,
            onTap: onSeeAllDeals,
          ),
          _QuickAction(
            label: 'Under 30 min',
            icon: Icons.bolt_rounded,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const NearbyRestaurantsScreen(
                  preset: RestaurantBrowsePreset.under30Minutes,
                ),
              ),
            ),
          ),
          _QuickAction(
            label: '4.0+',
            icon: Icons.star_rounded,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const NearbyRestaurantsScreen(
                  preset: RestaurantBrowsePreset.rated4Plus,
                ),
              ),
            ),
          ),
          _QuickAction(
            label: 'Veg',
            icon: Icons.eco_rounded,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    const FoodTypeShopsScreen(foodType: 'Vegetarian'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: AppColors.orange),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OfferCarousel extends StatefulWidget {
  final List<Deal> deals;
  final VoidCallback onSeeAllDeals;

  const _OfferCarousel({required this.deals, required this.onSeeAllDeals});

  @override
  State<_OfferCarousel> createState() => _OfferCarouselState();
}

class _OfferCarouselState extends State<_OfferCarousel> {
  final PageController _controller = PageController();
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant _OfferCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deals.length != widget.deals.length) {
      _index = 0;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.deals.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_index + 1) % widget.deals.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.deals.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 156,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            PageView.builder(
              clipBehavior: Clip.hardEdge,
              controller: _controller,
              itemCount: widget.deals.length,
              onPageChanged: (value) => setState(() => _index = value),
              itemBuilder: (context, index) => _OfferCard(
                deal: widget.deals[index],
                onTap: () => _openDeal(context, widget.deals[index]),
              ),
            ),
            if (widget.deals.length > 1)
              Positioned(
                right: 14,
                bottom: 12,
                child: Row(
                  children: List.generate(widget.deals.length, (index) {
                    final active = index == _index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: active ? 14 : 5,
                      height: 5,
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        color: active ? Colors.white : Colors.white54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openDeal(BuildContext context, Deal deal) {
    if (deal.vendorId != null && deal.vendorId!.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RestaurantMenuScreen(
            vendorId: deal.vendorId!,
            restaurantName: deal.restaurant,
            heroImageUrl: deal.imageUrl,
            cuisine: 'Featured offer',
            isOpen: true,
          ),
        ),
      );
    } else {
      widget.onSeeAllDeals();
    }
  }
}

class _OfferCard extends StatelessWidget {
  final Deal deal;
  final VoidCallback onTap;

  const _OfferCard({required this.deal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/home/home_food_banner.png',
              fit: BoxFit.cover,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xE01F1712),
                    Color(0x601F1712),
                    Color(0x001F1712),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 72),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deal.discount,
                        style: const TextStyle(
                          color: Color(0xFFFFB18C),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .65,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        deal.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          height: 1.05,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.55,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        '${deal.restaurant} · ${deal.distance}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFEDE7E2),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Order now →',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
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

class _HomeSectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _HomeSectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -.4,
              ),
            ),
          ),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _RestaurantsEmptyState extends StatelessWidget {
  const _RestaurantsEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(28, 12, 28, 128),
      child: Text(
        'Restaurants will appear here when they are available for your location.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          height: 1.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: homeCategories
            .map(
              (category) => Expanded(
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          FoodTypeShopsScreen(foodType: category.label),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.orangeTint,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          category.icon,
                          color: AppColors.orange,
                          size: 25,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        category.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _RestaurantRow extends StatelessWidget {
  final HomeRestaurant restaurant;

  const _RestaurantRow({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RestaurantMenuScreen(
            vendorId: restaurant.id,
            restaurantName: restaurant.name,
            heroImageUrl: restaurant.imageUrl,
            cuisine: restaurant.cuisine,
            isOpen: restaurant.isOpen,
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 102,
                height: 102,
                child: restaurant.imageUrl == null
                    ? Image.asset(
                        'assets/images/home/home_food_banner.png',
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        restaurant.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Image.asset(
                          'assets/images/home/home_food_banner.png',
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -.3,
                          ),
                        ),
                      ),
                      if (restaurant.rating > 0) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.star_rounded,
                          size: 15,
                          color: Color(0xFFC4922E),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          restaurant.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (restaurant.cuisine.isNotEmpty) const SizedBox(height: 3),
                  Text(
                    restaurant.cuisine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (restaurant.eta.isNotEmpty ||
                      restaurant.distance.isNotEmpty)
                    const SizedBox(height: 7),
                  if (restaurant.eta.isNotEmpty ||
                      restaurant.distance.isNotEmpty)
                    Text(
                      [
                        restaurant.eta,
                        restaurant.distance,
                      ].where((value) => value.isNotEmpty).join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  if (restaurant.offerLabel != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      restaurant.offerLabel!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
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

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool compact;

  const _RoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = compact ? 40.0 : 42.0;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(compact ? 12 : 21),
      child: InkWell(
        key: key,
        onTap: onTap,
        borderRadius: BorderRadius.circular(compact ? 12 : 21),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(compact ? 12 : 21),
          ),
          child: Icon(icon, size: 21, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

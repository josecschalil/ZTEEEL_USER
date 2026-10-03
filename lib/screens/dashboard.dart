import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../config/api_config.dart';
import '../services/offer_service.dart';
import '../services/restaurant_service.dart';
import '../widgets/bottom_nav_bar.dart';
import 'DealsScreen.dart';
import 'MainCartScreen.dart';
import 'ProfileScreen.dart';
import 'RestaurantListScreen.dart' hide AppColors;
import 'home_discovery_view.dart';

const _fallbackRestaurants = [
  HomeRestaurant(
    id: 'sample-spice-route',
    name: 'Spice Route',
    cuisine: 'North Indian · Biryani',
    rating: 4.6,
    reviewCount: 812,
    distance: '0.8 km',
    eta: '20–25 min',
    isOpen: true,
    offerLabel: '20% OFF up to ₹100',
  ),
  HomeRestaurant(
    id: 'sample-napoli',
    name: "Napoli's Kitchen",
    cuisine: 'Italian · Pizza',
    rating: 4.5,
    reviewCount: 654,
    distance: '1.2 km',
    eta: '25–30 min',
    isOpen: true,
  ),
  HomeRestaurant(
    id: 'sample-green-bowl',
    name: 'Green Bowl Co.',
    cuisine: 'Healthy · Salads',
    rating: 4.4,
    reviewCount: 305,
    distance: '1.5 km',
    eta: '20–25 min',
    isOpen: true,
    offerLabel: 'Free delivery',
  ),
];

HomeRestaurant _homeRestaurantFromVendor(
  Map<String, dynamic> vendor,
  int index,
) {
  final fallback = _fallbackRestaurants[index % _fallbackRestaurants.length];
  final image = vendor['cover_image'] ?? vendor['icon_image'];
  final imageUrl = image is String && image.isNotEmpty
      ? (image.startsWith('http://') || image.startsWith('https://')
            ? image
            : '${ApiConfig.baseUrl}${image.startsWith('/') ? '' : '/'}$image')
      : null;
  final id = _valueOrFallback(vendor['id'], fallback.id);
  final name = _valueOrFallback(vendor['business_name'], fallback.name);
  final description = vendor['shop_description']?.toString().trim() ?? '';
  final category = vendor['category']?.toString().trim() ?? '';
  return HomeRestaurant(
    id: id,
    name: name,
    cuisine: description.isNotEmpty
        ? description
        : category.isNotEmpty
        ? category
        : fallback.cuisine,
    rating: _numberValue(vendor['rating'] ?? vendor['average_rating']) > 0
        ? _numberValue(vendor['rating'] ?? vendor['average_rating'])
        : fallback.rating,
    reviewCount:
        _integerValue(vendor['review_count'] ?? vendor['rating_count']) > 0
        ? _integerValue(vendor['review_count'] ?? vendor['rating_count'])
        : fallback.reviewCount,
    distance: _textValue(vendor['distance_km'] ?? vendor['distance']).isNotEmpty
        ? _textValue(vendor['distance_km'] ?? vendor['distance'])
        : fallback.distance,
    eta:
        _textValue(
          vendor['delivery_time'] ?? vendor['eta_minutes'] ?? vendor['eta'],
        ).isNotEmpty
        ? _textValue(
            vendor['delivery_time'] ?? vendor['eta_minutes'] ?? vendor['eta'],
          )
        : fallback.eta,
    isOpen: vendor['is_open_now'] is bool
        ? vendor['is_open_now'] as bool
        : fallback.isOpen,
    imageUrl: imageUrl ?? fallback.imageUrl,
    offerLabel: fallback.offerLabel,
  );
}

double _numberValue(Object? value) =>
    double.tryParse(value?.toString() ?? '') ?? 0;

int _integerValue(Object? value) => int.tryParse(value?.toString() ?? '') ?? 0;

String _textValue(Object? value) => value?.toString().trim() ?? '';

String _valueOrFallback(Object? value, String fallback) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

List<HomeRestaurant> _homeRestaurants(List<HomeRestaurant> live) {
  return [...live, ..._fallbackRestaurants].take(3).toList();
}

RestaurantListing _toRestaurantListing(HomeRestaurant restaurant) =>
    RestaurantListing(
      id: restaurant.id,
      name: restaurant.name,
      imageUrl: restaurant.imageUrl,
      fallbackIcon: Icons.restaurant_rounded,
      cuisines: restaurant.cuisine
          .split('·')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(),
      rating: restaurant.rating,
      reviewCount: restaurant.reviewCount,
      distanceKm: double.tryParse(restaurant.distance.split(' ').first) ?? 0,
      etaMins: int.tryParse(restaurant.eta.split(RegExp(r'[^0-9]')).first) ?? 0,
      isOpenNow: restaurant.isOpen,
      isPromoted: restaurant.offerLabel != null,
      hasFreeDelivery: restaurant.offerLabel == 'Free delivery',
      priceLevel: '₹₹',
    );

class HomeDiscoveryScreen extends StatefulWidget {
  const HomeDiscoveryScreen({super.key});

  @override
  State<HomeDiscoveryScreen> createState() => _HomeDiscoveryScreenState();
}

class _HomeDiscoveryScreenState extends State<HomeDiscoveryScreen> {
  int _navIndex = 0;
  List<HomeRestaurant> _liveRestaurants = const [];
  List<Deal> _liveDeals = const [];

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
    _loadDeals();
  }

  Future<void> _loadRestaurants() async {
    final vendors = await RestaurantService.fetchRestaurants();
    if (!mounted || vendors.isEmpty) return;
    setState(
      () => _liveRestaurants = vendors
          .asMap()
          .entries
          .map((entry) => _homeRestaurantFromVendor(entry.value, entry.key))
          .toList(),
    );
  }

  Future<void> _loadDeals() async {
    final offers = await OfferService.fetchOffers();
    if (!mounted || offers.isEmpty) return;
    final hydrated = await dealsFromOffers(offers);
    if (mounted && hydrated.isNotEmpty) setState(() => _liveDeals = hydrated);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeDiscoveryView(
        restaurants: _homeRestaurants(_liveRestaurants),
        deals: dashboardDeals(_liveDeals),
        onSeeAllDeals: () => setState(() => _navIndex = 1),
      ),
      HotDealsRow(previewDeals: dashboardDeals(_liveDeals)),
      NearbyRestaurantsScreen(
        restaurants: _liveRestaurants.isEmpty
            ? null
            : _liveRestaurants.map(_toRestaurantListing).toList(),
      ),
      const MainCartScreenPage(showBottomNav: false),
      ProfileScreen(
        showBottomNav: false,
        onBack: () => setState(() => _navIndex = 0),
      ),
    ];
    final showNav = _navIndex != 4;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(index: _navIndex, children: pages),
      bottomNavigationBar: showNav
          ? AppBottomNavBar(
              currentIndex: _navIndex,
              onTap: (index) => setState(() => _navIndex = index),
            )
          : null,
    );
  }
}

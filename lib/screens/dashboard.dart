import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../config/api_config.dart';
import '../services/offer_service.dart';
import '../services/restaurant_service.dart';
import '../widgets/bottom_nav_bar.dart';
import 'DealsScreen.dart';
import 'MainCartScreen.dart';
import 'ProfileScreen.dart';
import 'RecentOrderScreen.dart';
import 'home_discovery_view.dart';

HomeRestaurant _homeRestaurantFromVendor(Map<String, dynamic> vendor) {
  final image = vendor['cover_image'] ?? vendor['icon_image'];
  final imageUrl = image is String && image.isNotEmpty
      ? (image.startsWith('http://') || image.startsWith('https://')
            ? image
            : '${ApiConfig.baseUrl}${image.startsWith('/') ? '' : '/'}$image')
      : null;

  final id = vendor['id']?.toString() ?? '';
  final name = vendor['business_name']?.toString().trim() ?? 'Restaurant';

  String cuisine = 'Multi-Cuisine';
  if (vendor['cuisines'] is List && (vendor['cuisines'] as List).isNotEmpty) {
    cuisine = (vendor['cuisines'] as List).join(' · ');
  } else if (vendor['shop_description']?.toString().trim().isNotEmpty == true) {
    cuisine = vendor['shop_description']!.toString().trim();
  } else if (vendor['category']?.toString().trim().isNotEmpty == true) {
    cuisine = vendor['category']!.toString().trim();
  }

  String? offerLabel;
  if (vendor['best_offer'] is Map) {
    final bestOffer = vendor['best_offer'] as Map;
    final discount = double.tryParse(bestOffer['discount_percentage']?.toString() ?? '') ?? 0;
    if (discount > 0) {
      offerLabel = '${discount.toInt()}% OFF';
    } else if (bestOffer['title']?.toString().isNotEmpty == true) {
      offerLabel = bestOffer['title'].toString();
    }
  }

  final distanceStr = vendor['distance_km'] != null && vendor['distance_km'].toString().isNotEmpty
      ? '${vendor['distance_km']} km'
      : '1.2 km';

  final etaStr = vendor['delivery_time']?.toString() ?? vendor['eta']?.toString() ?? '20–30 min';

  return HomeRestaurant(
    id: id,
    name: name,
    cuisine: cuisine,
    rating: _numberValue(vendor['rating'] ?? vendor['average_rating']) > 0
        ? _numberValue(vendor['rating'] ?? vendor['average_rating'])
        : 4.8,
    reviewCount: _integerValue(vendor['review_count'] ?? vendor['rating_count']) > 0
        ? _integerValue(vendor['review_count'] ?? vendor['rating_count'])
        : 120,
    distance: distanceStr,
    eta: etaStr,
    isOpen: vendor['is_open_now'] is bool ? vendor['is_open_now'] as bool : true,
    imageUrl: imageUrl,
    offerLabel: offerLabel,
  );
}

double _numberValue(Object? value) =>
    double.tryParse(value?.toString() ?? '') ?? 0;

int _integerValue(Object? value) => int.tryParse(value?.toString() ?? '') ?? 0;


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
    if (RestaurantService.cachedRestaurants.isNotEmpty) {
      _liveRestaurants = RestaurantService.cachedRestaurants
          .map((v) => _homeRestaurantFromVendor(v))
          .toList();
    }
    _loadRestaurants();
    _loadDeals();
  }

  Future<void> _loadRestaurants() async {
    final vendors = await RestaurantService.fetchRestaurants();
    if (!mounted || vendors.isEmpty) return;
    setState(
      () => _liveRestaurants = vendors
          .map((v) => _homeRestaurantFromVendor(v))
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
        restaurants: _liveRestaurants,
        deals: dashboardDeals(_liveDeals),
        onSeeAllDeals: () => setState(() => _navIndex = 1),
      ),
      const DealsScreen(),
      const OrdersScreen(),
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

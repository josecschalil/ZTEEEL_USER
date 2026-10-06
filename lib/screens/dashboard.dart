import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../config/api_config.dart';
import '../services/cart_service.dart';
import '../services/food_tag_service.dart';
import '../services/offer_service.dart';
import '../services/restaurant_service.dart';
import '../services/auth_service.dart';
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
    final discount =
        double.tryParse(bestOffer['discount_percentage']?.toString() ?? '') ??
        0;
    if (discount > 0) {
      offerLabel = '${discount.toInt()}% OFF';
    } else if (bestOffer['title']?.toString().isNotEmpty == true) {
      offerLabel = bestOffer['title'].toString();
    }
  }

  final distanceStr =
      vendor['distance_km'] != null &&
          vendor['distance_km'].toString().isNotEmpty
      ? '${vendor['distance_km']} km'
      : '1.2 km';

  final etaStr =
      vendor['delivery_time']?.toString() ??
      vendor['eta']?.toString() ??
      '20–30 min';

  return HomeRestaurant(
    id: id,
    name: name,
    cuisine: cuisine,
    rating: _numberValue(vendor['rating'] ?? vendor['average_rating']) > 0
        ? _numberValue(vendor['rating'] ?? vendor['average_rating'])
        : 4.8,
    reviewCount:
        _integerValue(vendor['review_count'] ?? vendor['rating_count']) > 0
        ? _integerValue(vendor['review_count'] ?? vendor['rating_count'])
        : 120,
    distance: distanceStr,
    eta: etaStr,
    isOpen: vendor['is_open_now'] is bool
        ? vendor['is_open_now'] as bool
        : true,
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
  List<FoodTag> _foodTags = const [];
  bool _isLoadingRestaurants = true;
  bool _isLoadingDeals = true;
  bool _isLoadingFoodTags = true;
  String _firstName = '';
  String _fullName = '';
  String _phoneNumber = '';

  @override
  void initState() {
    super.initState();
    if (RestaurantService.cachedRestaurants.isNotEmpty) {
      _liveRestaurants = RestaurantService.cachedRestaurants
          .map((v) => _homeRestaurantFromVendor(v))
          .where((r) => r.isOpen)
          .toList();
      _isLoadingRestaurants = false;
    }
    if (FoodTagService.cachedFoodTags.isNotEmpty) {
      _foodTags = FoodTagService.cachedFoodTags;
      _isLoadingFoodTags = false;
    }
    _loadRestaurants();
    _loadDeals();
    _loadFoodTags();
    _loadCustomerProfile();
  }

  Future<void> _loadCustomerProfile() async {
    final profile = await AuthService.getCustomerProfile();
    if (!mounted || profile == null) return;
    final firstName = profile['first_name']?.toString().trim() ?? '';
    final lastName = profile['last_name']?.toString().trim() ?? '';
    setState(() {
      _firstName = firstName;
      _fullName = [firstName, lastName].where((part) => part.isNotEmpty).join(' ');
      _phoneNumber = profile['phone_number']?.toString().trim() ?? '';
    });
  }

  Future<void> _loadRestaurants() async {
    final vendors = await RestaurantService.fetchRestaurants();
    if (!mounted) return;
    setState(() {
      _liveRestaurants = vendors
          .map((v) => _homeRestaurantFromVendor(v))
          .where((r) => r.isOpen)
          .toList();
      _isLoadingRestaurants = false;
    });
  }

  Future<void> _loadDeals() async {
    final offers = await OfferService.fetchOffers();
    if (!mounted) return;
    final hydrated = <Deal>[];
    if (offers.isNotEmpty) {
      final vendors = await RestaurantService.fetchRestaurants();
      if (!mounted) return;
      final vendorsById = {
        for (final vendor in vendors) vendor['id']?.toString(): vendor,
      };
      for (final offer in offers) {
        final vendorRef = offer['vendor'];
        final vendorId = (vendorRef is Map ? vendorRef['id'] : vendorRef)
            ?.toString();
        hydrated.add(
          Deal.fromBackend(
            offer: {...offer, 'vendor': vendorId},
            vendor:
                vendorsById[vendorId] ??
                (vendorRef is Map
                    ? Map<String, dynamic>.from(vendorRef)
                    : null),
          ),
        );
      }
    }
    if (!mounted) return;
    setState(() {
      _liveDeals = hydrated;
      _isLoadingDeals = false;
    });
  }

  Future<void> _loadFoodTags() async {
    final cached = await FoodTagService.loadCachedFoodTags();
    if (mounted && cached.isNotEmpty && _foodTags.isEmpty) {
      setState(() {
        _foodTags = cached;
        _isLoadingFoodTags = false;
      });
      _precacheTagImages(cached);
    }
    final tags = await FoodTagService.fetchFoodTags();
    if (!mounted) return;
    setState(() {
      _foodTags = tags;
      _isLoadingFoodTags = false;
    });
    _precacheTagImages(tags);
  }

  void _precacheTagImages(List<FoodTag> tags) {
    if (!mounted) return;
    for (final tag in tags) {
      if (tag.imageUrl != null && tag.imageUrl!.isNotEmpty) {
        precacheImage(NetworkImage(tag.imageUrl!), context).catchError((_) {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      ValueListenableBuilder<Map<String, CartData>>(
        valueListenable: CartService.basketsNotifier,
        builder: (context, baskets, child) => HomeDiscoveryView(
          restaurants: _liveRestaurants,
          deals: _liveDeals,
          isLoadingRestaurants: _isLoadingRestaurants,
          isLoadingDeals: _isLoadingDeals,
          foodTags: _foodTags,
          isLoadingFoodTags: _isLoadingFoodTags,
          firstName: _firstName,
          cartItemCount: CartService.grandTotalItemCount,
          onSeeAllDeals: () => setState(() => _navIndex = 1),
          onOpenCart: () => setState(() => _navIndex = 3),
        ),
      ),
      DealsScreen(onOpenCart: () => setState(() => _navIndex = 3)),
      const OrdersScreen(),
      const MainCartScreenPage(showBottomNav: false),
      ProfileScreen(
        showBottomNav: false,
        onBack: () => setState(() => _navIndex = 0),
        fullName: _fullName,
        phoneNumber: _phoneNumber,
      ),
    ];
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: IndexedStack(index: _navIndex, children: pages),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _navIndex,
        onTap: (index) => setState(() => _navIndex = index),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../config/api_config.dart';
import '../services/food_tag_service.dart';
import '../services/offer_service.dart';
import '../services/restaurant_service.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../widgets/bottom_nav_bar.dart';
import 'DealsScreen.dart';
import 'MainCartScreen.dart';
import 'ProfileScreen.dart';
import 'RecentOrderScreen.dart';
import 'RestaurantListScreen.dart';
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

  final rawDistance = vendor['distance_km'];
  final distanceStr =
      rawDistance != null && rawDistance.toString().trim().isNotEmpty
          ? '${rawDistance} km'
          : '';

  final distanceNum = double.tryParse(rawDistance?.toString() ?? '') ?? 1.5;
  final calculatedEta = (12 + distanceNum * 2.5).round().clamp(15, 90);
  final etaStr =
      vendor['delivery_time']?.toString() ??
      vendor['eta']?.toString() ??
      '$calculatedEta min';

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
        : (vendor['is_open'] is bool
            ? vendor['is_open'] as bool
            : (vendor['isOpen'] is bool
                ? vendor['isOpen'] as bool
                : (vendor['open_now'] is bool
                    ? vendor['open_now'] as bool
                    : true))),
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
    LocationService.locationNotifier.addListener(_onLocationChanged);

    // 1. Check in-memory caches for instant render
    if (RestaurantService.cachedRestaurants.isNotEmpty) {
      _liveRestaurants = RestaurantService.cachedRestaurants
          .map((v) => _homeRestaurantFromVendor(v))
          .toList();
      _isLoadingRestaurants = false;
    }
    if (OfferService.cachedOffers.isNotEmpty) {
      _liveDeals = _buildDealsFromOffersAndVendors(
        OfferService.cachedOffers,
        RestaurantService.cachedRestaurants,
      );
      _isLoadingDeals = false;
    }
    if (FoodTagService.cachedFoodTags.isNotEmpty) {
      _foodTags = FoodTagService.cachedFoodTags;
      _isLoadingFoodTags = false;
    }

    _loadDiscoveryData();
    _loadCustomerProfile();
  }

  @override
  void dispose() {
    LocationService.locationNotifier.removeListener(_onLocationChanged);
    super.dispose();
  }

  void _onLocationChanged() {
    if (!mounted) return;
    _loadDiscoveryData(forceRefresh: true);
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

  Future<void> _loadDiscoveryData({bool forceRefresh = false}) async {
    if (forceRefresh && mounted) {
      setState(() {
        _isLoadingRestaurants = true;
        _isLoadingDeals = true;
        _isLoadingFoodTags = true;
      });
    }

    // 1. Instant local disk cache load
    final cachedDiskVendorsFuture = RestaurantService.loadCachedRestaurants();
    final cachedDiskOffersFuture = OfferService.loadCachedOffers();
    final cachedDiskTagsFuture = FoodTagService.loadCachedFoodTags();

    final diskResults = await Future.wait([
      cachedDiskVendorsFuture,
      cachedDiskOffersFuture,
      cachedDiskTagsFuture,
    ]);

    final diskVendors = diskResults[0] as List<Map<String, dynamic>>;
    final diskOffers = diskResults[1] as List<Map<String, dynamic>>;
    final diskTags = diskResults[2] as List<FoodTag>;

    if (mounted) {
      setState(() {
        if (_liveRestaurants.isEmpty && diskVendors.isNotEmpty) {
          _liveRestaurants = diskVendors.map(_homeRestaurantFromVendor).toList();
          _isLoadingRestaurants = false;
        }
        if (_liveDeals.isEmpty && diskOffers.isNotEmpty) {
          _liveDeals = _buildDealsFromOffersAndVendors(diskOffers, diskVendors);
          _isLoadingDeals = false;
        }
        if (_foodTags.isEmpty && diskTags.isNotEmpty) {
          _foodTags = diskTags;
          _isLoadingFoodTags = false;
        }
      });
      if (diskTags.isNotEmpty) {
        _precacheTagImages(diskTags);
      }
    }

    // 2. Parallel network fetches in single round-trip
    final networkResults = await Future.wait([
      RestaurantService.fetchRestaurants(forceRefresh: true),
      OfferService.fetchOffers(forceRefresh: true),
      FoodTagService.fetchFoodTags(forceRefresh: true),
    ]);

    final freshVendors = networkResults[0] as List<Map<String, dynamic>>;
    final freshOffers = networkResults[1] as List<Map<String, dynamic>>;
    final freshTags = networkResults[2] as List<FoodTag>;

    if (!mounted) return;
    setState(() {
      _liveRestaurants = freshVendors.map(_homeRestaurantFromVendor).toList();
      _isLoadingRestaurants = false;
      _liveDeals = _buildDealsFromOffersAndVendors(freshOffers, freshVendors);
      _isLoadingDeals = false;
      _foodTags = freshTags;
      _isLoadingFoodTags = false;
    });
    _precacheTagImages(freshTags);
  }

  List<Deal> _buildDealsFromOffersAndVendors(
    List<Map<String, dynamic>> offers,
    List<Map<String, dynamic>> vendors,
  ) {
    if (offers.isEmpty) return const [];
    final vendorsById = {
      for (final vendor in vendors) vendor['id']?.toString(): vendor,
    };
    final deals = <Deal>[];
    for (final offer in offers) {
      final vendorRef = offer['vendor'];
      final vendorId =
          (vendorRef is Map ? vendorRef['id'] : vendorRef)?.toString();
      final vendorData =
          vendorsById[vendorId] ??
          (vendorRef is Map ? Map<String, dynamic>.from(vendorRef) : null);
      deals.add(
        Deal.fromBackend(
          offer: {...offer, 'vendor': vendorId},
          vendor: vendorData,
        ),
      );
    }
    return deals;
  }

  void _precacheTagImages(List<FoodTag> tags) {
    if (!mounted) return;
    for (final tag in tags) {
      if (tag.imageUrl != null && tag.imageUrl!.isNotEmpty) {
        precacheImage(NetworkImage(tag.imageUrl!), context).catchError((_) {});
      }
    }
  }

  void _openCart() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MainCartScreenPage(showBottomNav: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final bottomOverlayPadding = keyboardOpen
        ? 0.0
        : AppBottomNavBar.overlayClearance(context);
    final pages = <Widget>[
      HomeDiscoveryView(
        restaurants: _liveRestaurants,
        deals: _liveDeals,
        isLoadingRestaurants: _isLoadingRestaurants,
        isLoadingDeals: _isLoadingDeals,
        foodTags: _foodTags,
        isLoadingFoodTags: _isLoadingFoodTags,
        firstName: _firstName,
        onSeeAllDeals: () => setState(() => _navIndex = 1),
        onSeeAllRestaurants: () => setState(() => _navIndex = 2),
        onOpenCart: _openCart,
        bottomOverlayPadding: bottomOverlayPadding,
        onRefresh: _loadDiscoveryData,
      ),
      DealsScreen(
        onOpenCart: _openCart,
        bottomOverlayPadding: bottomOverlayPadding,
      ),
      NearbyRestaurantsScreen(
        showBackButton: false,
        onOpenCart: _openCart,
        bottomOverlayPadding: bottomOverlayPadding,
        onRefresh: _loadDiscoveryData,
      ),
      OrdersScreen(
        onOpenCart: _openCart,
        bottomOverlayPadding: bottomOverlayPadding,
      ),
      ProfileScreen(
        showBottomNav: false,
        onBack: () => setState(() => _navIndex = 0),
        fullName: _fullName,
        phoneNumber: _phoneNumber,
        bottomOverlayPadding: bottomOverlayPadding,
        onRefresh: _loadCustomerProfile,
      ),
    ];
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          Positioned.fill(child: IndexedStack(index: _navIndex, children: pages)),
          if (!keyboardOpen)
            Align(
              alignment: Alignment.bottomCenter,
              child: AppBottomNavBar(
                currentIndex: _navIndex,
                onTap: (index) => setState(() => _navIndex = index),
              ),
            ),
        ],
      ),
    );
  }
}

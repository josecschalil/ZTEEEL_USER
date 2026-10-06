import '../app_colors.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/api_config.dart';
import '../services/offer_service.dart';
import '../services/restaurant_service.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/discovery_search_bar.dart';
import 'RestuarantMenuScreen.dart';

/// ---------------------------------------------------------------------
/// Enriched Deal Model
/// ---------------------------------------------------------------------
class Deal {
  final String? id;
  final String? vendorId;
  final String title;
  final String description;
  final String restaurant;
  final String? restaurantImage;
  final String cuisine;
  final double rating;
  final int reviewCount;
  final String distance;
  final String discount;
  final double discountPercent;
  final String scopeType;
  final List<String> itemIds;
  final List<String> categoryIds;
  final String timeLeft;
  final String imageUrl;
  final bool isFlash;
  final bool isMega;
  final DateTime? endsAt;

  const Deal({
    this.id,
    this.vendorId,
    required this.title,
    this.description = '',
    required this.restaurant,
    this.restaurantImage,
    this.cuisine = 'Multi-Cuisine',
    this.rating = 4.8,
    this.reviewCount = 120,
    required this.distance,
    required this.discount,
    this.discountPercent = 0.0,
    this.scopeType = 'all_menu',
    this.itemIds = const [],
    this.categoryIds = const [],
    required this.timeLeft,
    required this.imageUrl,
    this.isFlash = false,
    this.isMega = false,
    this.endsAt,
  });

  factory Deal.fromBackend({
    required Map<String, dynamic> offer,
    Map<String, dynamic>? vendor,
    String? fallbackImage,
  }) {
    final id = offer['id']?.toString();
    final vendorId = offer['vendor']?.toString() ?? vendor?['id']?.toString() ?? '';
    final title = offer['title']?.toString().trim() ?? 'Special Deal';
    final desc = offer['description']?.toString().trim() ?? '';
    final discountPct = double.tryParse(offer['discount_percentage']?.toString() ?? '') ?? 0.0;
    final scopeType = offer['scope_type']?.toString() ?? 'all_menu';

    final itemIds = <String>[];
    final categoryIds = <String>[];

    if (offer['targets'] is Map) {
      final targets = offer['targets'] as Map;
      if (targets['item_ids'] is List) {
        for (final x in targets['item_ids'] as List) {
          if (x != null && x.toString().isNotEmpty) itemIds.add(x.toString());
        }
      }
      if (targets['category_ids'] is List) {
        for (final x in targets['category_ids'] as List) {
          if (x != null && x.toString().isNotEmpty) categoryIds.add(x.toString());
        }
      }
    }
    if (offer['item_ids'] is List) {
      for (final x in offer['item_ids'] as List) {
        if (x != null && x.toString().isNotEmpty) itemIds.add(x.toString());
      }
    }
    if (offer['category_ids'] is List) {
      for (final x in offer['category_ids'] as List) {
        if (x != null && x.toString().isNotEmpty) categoryIds.add(x.toString());
      }
    }

    final vName = vendor?['business_name']?.toString().trim() ?? 'Restaurant Partner';
    final vImg = _resolveImageUrl(vendor?['cover_image']?.toString() ?? vendor?['icon_image']?.toString() ?? '');

    String cuisine = 'Multi-Cuisine';
    if (vendor?['cuisines'] is List && (vendor?['cuisines'] as List).isNotEmpty) {
      cuisine = (vendor?['cuisines'] as List).join(' · ');
    } else if (vendor?['category']?.toString().isNotEmpty == true) {
      cuisine = vendor!['category'].toString();
    }

    final rating = double.tryParse(vendor?['rating']?.toString() ?? vendor?['average_rating']?.toString() ?? '') ?? 4.8;
    final reviews = int.tryParse(vendor?['review_count']?.toString() ?? vendor?['rating_count']?.toString() ?? '') ?? 140;
    final dist = vendor?['distance_km'] != null ? '${vendor!['distance_km']} km' : '1.2 km';

    DateTime? endsAt;
    String timeLeft = 'Limited Time';
    if (offer['ends_at'] != null) {
      endsAt = DateTime.tryParse(offer['ends_at'].toString())?.toLocal();
      if (endsAt != null) {
        final diff = endsAt.difference(DateTime.now());
        if (diff.isNegative) {
          timeLeft = 'Ending soon';
        } else if (diff.inDays > 0) {
          timeLeft = '${diff.inDays}d left';
        } else if (diff.inHours > 0) {
          timeLeft = '${diff.inHours}h ${diff.inMinutes % 60}m left';
        } else {
          timeLeft = '${diff.inMinutes.clamp(1, 59)}m left';
        }
      }
    }

    String img = fallbackImage ?? '';
    if (vImg.isNotEmpty && img.isEmpty) {
      img = vImg;
    }
    if (img.isEmpty) {
      img = 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600';
    }

    final discountLabel = discountPct > 0
        ? '${discountPct.toStringAsFixed(discountPct % 1 == 0 ? 0 : 1)}% OFF'
        : 'SPECIAL DEAL';

    return Deal(
      id: id,
      vendorId: vendorId.isNotEmpty ? vendorId : null,
      title: title,
      description: desc,
      restaurant: vName,
      restaurantImage: vImg.isNotEmpty ? vImg : null,
      cuisine: cuisine,
      rating: rating,
      reviewCount: reviews,
      distance: dist,
      discount: discountLabel,
      discountPercent: discountPct,
      scopeType: scopeType,
      itemIds: itemIds,
      categoryIds: categoryIds,
      timeLeft: timeLeft,
      imageUrl: img,
      isFlash: discountPct >= 30 || timeLeft.contains('m left') || timeLeft.contains('h left'),
      isMega: discountPct >= 25,
      endsAt: endsAt,
    );
  }
}

String _resolveImageUrl(String path) {
  if (path.isEmpty) return '';
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  return '${ApiConfig.baseUrl}${path.startsWith('/') ? '' : '/'}$path';
}

/// Fallback sample deals
const deals = [
  Deal(
    title: 'Golden Hour Feast — 40% Off',
    restaurant: 'Saffron Gourmet House',
    distance: '1.2 km',
    discount: '40% OFF',
    discountPercent: 40,
    timeLeft: '2h 15m left',
    imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=600',
    cuisine: 'North Indian · Biryani',
    isFlash: true,
    isMega: true,
  ),
  Deal(
    title: 'Double Smash Burgers Combo',
    restaurant: 'Urban Burger Grill',
    distance: '0.8 km',
    discount: '50% OFF',
    discountPercent: 50,
    timeLeft: '45m left',
    imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600',
    cuisine: 'American · Fast Food',
    isFlash: true,
    isMega: true,
  ),
  Deal(
    title: 'Fresh Berry Bowls & Juices',
    restaurant: 'The Salad Project',
    distance: '2.5 km',
    discount: '20% OFF',
    discountPercent: 20,
    timeLeft: '5h left',
    imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600',
    cuisine: 'Healthy · Salads · Bowls',
  ),
];

Future<List<Deal>> dealsFromOffers(List<Map<String, dynamic>> offers) async {
  final vendors = await RestaurantService.fetchRestaurants();
  final vMap = {for (var v in vendors) v['id']?.toString() ?? '': v};

  final list = <Deal>[];
  for (int i = 0; i < offers.length; i++) {
    final offer = offers[i];
    final vId = offer['vendor']?.toString() ?? '';
    final vendor = vMap[vId];
    list.add(
      Deal.fromBackend(
        offer: offer,
        vendor: vendor,
        fallbackImage: i < deals.length ? deals[i].imageUrl : null,
      ),
    );
  }
  return list.isNotEmpty ? list : deals;
}

List<Deal> dashboardDeals(List<Deal> liveDeals) {
  if (liveDeals.length >= 3) return liveDeals.take(3).toList();
  return [...liveDeals, ...deals.skip(liveDeals.length)].take(3).toList();
}

/// ---------------------------------------------------------------------
/// Main DealsScreen Page
/// ---------------------------------------------------------------------
class DealsScreen extends StatefulWidget {
  final VoidCallback? onOpenCart;

  const DealsScreen({super.key, this.onOpenCart});

  @override
  State<DealsScreen> createState() => _DealsScreenState();
}

typedef HotDealsScreen = DealsScreen;

class _DealsScreenState extends State<DealsScreen> {
  bool _isLoading = true;
  List<Deal> _allDeals = [];
  String _selectedFilter = 'All Deals';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  final List<String> _filters = [
    'All Deals',
    '⚡ Mega Deals (25%+)',
    '🍕 Whole Menu',
    '🍱 Category Specials',
    '⏰ Ending Soon',
    '⭐ Top Rated',
  ];

  @override
  void initState() {
    super.initState();
    _loadDeals();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDeals() async {
    setState(() => _isLoading = true);
    try {
      final rawOffers = await OfferService.fetchOffers();
      if (rawOffers.isNotEmpty) {
        final parsed = await dealsFromOffers(rawOffers);
        if (mounted) {
          setState(() {
            _allDeals = parsed;
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _allDeals = deals;
        _isLoading = false;
      });
    }
  }

  List<Deal> get _filteredDeals {
    var list = List<Deal>.from(_allDeals);

    // Apply Filter Tab
    if (_selectedFilter == '⚡ Mega Deals (25%+)') {
      list = list.where((d) => d.discountPercent >= 25 || d.isMega).toList();
    } else if (_selectedFilter == '🍕 Whole Menu') {
      list = list.where((d) => d.scopeType == 'all_menu').toList();
    } else if (_selectedFilter == '🍱 Category Specials') {
      list = list.where((d) => d.scopeType == 'category_set' || d.scopeType == 'item_set').toList();
    } else if (_selectedFilter == '⏰ Ending Soon') {
      list = list.where((d) => d.timeLeft.contains('m left') || d.timeLeft.contains('h left') || d.timeLeft.contains('soon')).toList();
    } else if (_selectedFilter == '⭐ Top Rated') {
      list = list.where((d) => d.rating >= 4.8).toList();
    }

    // Apply Search Query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((d) {
        return d.title.toLowerCase().contains(q) ||
            d.restaurant.toLowerCase().contains(q) ||
            d.cuisine.toLowerCase().contains(q) ||
            d.discount.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }

  void _navigateToMenu(Deal deal) {
    if (deal.vendorId != null && deal.vendorId!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RestaurantMenuScreen(
            vendorId: deal.vendorId,
            restaurantName: deal.restaurant,
            heroImageUrl: deal.imageUrl,
            cuisine: deal.cuisine,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgDark : AppColors.bgLight;

    final spotlightDeals = _allDeals.where((d) => d.discountPercent >= 20 || d.isMega).take(4).toList();
    final flashDeals = _allDeals.where((d) => d.isFlash || d.timeLeft.contains('m left') || d.timeLeft.contains('h left')).toList();

    return Scaffold(
      backgroundColor: bgColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: AppColors.transparent,
          systemStatusBarContrastEnforced: false,
        ),
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _loadDeals,
            child: CustomScrollView(
              slivers: [
                // Top Bar (Location, Notifications, Cart)
                SliverToBoxAdapter(
                  child: AppTopBar(
                    onOpenCart: widget.onOpenCart,
                  ),
                ),

                // Deals Header (Explore Top Deals)
                SliverToBoxAdapter(
                  child: _DealsHeader(
                    isDark: isDark,
                  ),
                ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: DiscoverySearchBar.editable(
                    isDark: isDark,
                    hintText: 'Search deals, dishes or restaurants...',
                    selectedFilterLabel: _selectedFilter,
                    shellKey: const ValueKey('deals-search-field'),
                    searchKey: const ValueKey('deals-search'),
                    filterKey: const ValueKey('deals-selected-filter'),
                    controller: _searchCtrl,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    onClear: () {
                      _searchCtrl.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
                ),
              ),

              // Filter Tabs
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 42,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final filter = _filters[i];
                      final isSelected = filter == _selectedFilter;
                      return _FilterPill(
                        label: filter,
                        isSelected: isSelected,
                        isDark: isDark,
                        onTap: () => setState(() => _selectedFilter = filter),
                      );
                    },
                  ),
                ),
              ),

              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else ...[
                // Spotlight Hero Section (only when no search query active)
                if (_searchQuery.isEmpty && _selectedFilter == 'All Deals' && spotlightDeals.isNotEmpty) ...[
                  const SliverToBoxAdapter(child: SizedBox(height: 18)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _SectionTitle(
                        title: '🔥 Spotlight Deals',
                        subtitle: 'Top handpicked discounts right now',
                        isDark: isDark,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: _SpotlightCarousel(
                      deals: spotlightDeals.isNotEmpty ? spotlightDeals : deals,
                      onDealTap: _navigateToMenu,
                      isDark: isDark,
                    ),
                  ),
                ],

                // Flash Sales Section
                if (_searchQuery.isEmpty && _selectedFilter == 'All Deals' && flashDeals.isNotEmpty) ...[
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _SectionTitle(
                        title: '⚡ Flash Sales & Happy Hours',
                        subtitle: 'Expiring soon • Auto-applied at checkout',
                        isDark: isDark,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 190,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: flashDeals.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 14),
                        itemBuilder: (context, i) {
                          return _FlashDealCard(
                            deal: flashDeals[i],
                            isDark: isDark,
                            onTap: () => _navigateToMenu(flashDeals[i]),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                // All Deals List / Filtered Results
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _SectionTitle(
                      title: _selectedFilter == 'All Deals' ? '🏷️ All Offers Near You' : '🏷️ $_selectedFilter',
                      subtitle: '${_filteredDeals.length} deals available around you',
                      isDark: isDark,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                if (_filteredDeals.isEmpty)
                  SliverToBoxAdapter(
                    child: _EmptyDealsView(
                      isDark: isDark,
                      onReset: () {
                        _searchCtrl.clear();
                        setState(() {
                          _searchQuery = '';
                          _selectedFilter = 'All Deals';
                        });
                      },
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final deal = _filteredDeals[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _ModernDealCard(
                              deal: deal,
                              isDark: isDark,
                              onTap: () => _navigateToMenu(deal),
                            ),
                          );
                        },
                        childCount: _filteredDeals.length,
                      ),
                    ),
                  ),
              ],
            ],
          ),
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Top Header
/// ---------------------------------------------------------------------
class _DealsHeader extends StatelessWidget {
  final bool isDark;

  const _DealsHeader({
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? AppColors.white : AppColors.textPrimary;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.toneFF8E8E93;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore Top Deals',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Automatic discounts • No promo codes required',
            style: TextStyle(
              fontSize: 12.5,
              color: textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Filter Pill
/// ---------------------------------------------------------------------
class _FilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.cardDark : AppColors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? AppColors.white
                  : (isDark ? AppColors.white70 : AppColors.toneFF4B5563),
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Section Title
/// ---------------------------------------------------------------------
class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDark;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: isDark ? AppColors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------
/// Spotlight Hero Carousel
/// ---------------------------------------------------------------------
class _SpotlightCarousel extends StatefulWidget {
  final List<Deal> deals;
  final ValueChanged<Deal> onDealTap;
  final bool isDark;

  const _SpotlightCarousel({
    required this.deals,
    required this.onDealTap,
    required this.isDark,
  });

  @override
  State<_SpotlightCarousel> createState() => _SpotlightCarouselState();
}

class _SpotlightCarouselState extends State<_SpotlightCarousel> {
  int _activePage = 0;
  late final PageController _pageController;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoTimer?.cancel();
    if (widget.deals.length <= 1) return;
    _autoTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final next = (_activePage + 1) % widget.deals.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 215,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.deals.length,
        onPageChanged: (i) => setState(() => _activePage = i),
        itemBuilder: (context, i) {
          final deal = widget.deals[i];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _SpotlightCard(
              deal: deal,
              isDark: widget.isDark,
              onTap: () => widget.onDealTap(deal),
            ),
          );
        },
      ),
    );
  }
}

class _SpotlightCard extends StatelessWidget {
  final Deal deal;
  final bool isDark;
  final VoidCallback onTap;

  const _SpotlightCard({
    required this.deal,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                deal.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.cardDark,
                  child: const Center(
                    child: Icon(Icons.restaurant_rounded, color: AppColors.primary, size: 48),
                  ),
                ),
              ),
              // Gradient Shade
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.black.withValues(alpha: 0.95),
                      AppColors.black.withValues(alpha: 0.55),
                      AppColors.black.withValues(alpha: 0.1),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
              // Top Badges
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    deal.discount,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, size: 12, color: AppColors.materialAmberAccent),
                      const SizedBox(width: 4),
                      Text(
                        deal.timeLeft,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom Details
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            deal.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  deal.restaurant,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (deal.distance.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                const Text('•', style: TextStyle(color: AppColors.white60)),
                                const SizedBox(width: 6),
                                Text(
                                  deal.distance,
                                  style: const TextStyle(
                                    color: AppColors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Claim',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
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

/// ---------------------------------------------------------------------
/// Flash Sales Mini Card
/// ---------------------------------------------------------------------
class _FlashDealCard extends StatelessWidget {
  final Deal deal;
  final bool isDark;
  final VoidCallback onTap;

  const _FlashDealCard({
    required this.deal,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.cardDark : AppColors.white;
    final cardBorder = isDark ? AppColors.borderDark : AppColors.borderLight;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cardBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Header
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: Image.network(
                    deal.imageUrl,
                    width: 240,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 240,
                      height: 100,
                      color: AppColors.redeemSurfaceDark,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.nonVegRed,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department_rounded, size: 12, color: AppColors.white),
                        const SizedBox(width: 3),
                        Text(
                          deal.discount,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      deal.timeLeft,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Info Body
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deal.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          deal.restaurant,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? AppColors.textMutedDark : AppColors.toneFF6B7280,
                          ),
                        ),
                      ),
                      Text(
                        deal.distance,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
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

/// ---------------------------------------------------------------------
/// Modern Horizontal Deal Card
/// ---------------------------------------------------------------------
class _ModernDealCard extends StatelessWidget {
  final Deal deal;
  final bool isDark;
  final VoidCallback onTap;

  const _ModernDealCard({
    required this.deal,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.cardDark : AppColors.white;
    final cardBorder = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textPrimary = isDark ? AppColors.white : AppColors.textPrimary;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.toneFF6B7280;

    final isAllMenu = deal.scopeType == 'all_menu';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cardBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food / Restaurant Thumbnail
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 96,
                      height: 96,
                      color: isDark ? AppColors.redeemSurfaceDark : AppColors.surfaceRaised,
                      child: Image.network(
                        deal.imageUrl,
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.restaurant_rounded,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        deal.discount,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Content details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            deal.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deal.restaurant,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.white70 : AppColors.toneFF374151,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isAllMenu
                                ? AppColors.green.withValues(alpha: 0.12)
                                : AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isAllMenu ? 'Whole Menu' : 'Category Special',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isAllMenu ? AppColors.green : AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          deal.distance,
                          style: TextStyle(fontSize: 11, color: textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, size: 12, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              deal.timeLeft,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          'Auto-applied',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.green,
                          ),
                        ),
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

/// ---------------------------------------------------------------------
/// Empty State View
/// ---------------------------------------------------------------------
class _EmptyDealsView extends StatelessWidget {
  final bool isDark;
  final VoidCallback onReset;

  const _EmptyDealsView({required this.isDark, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              color: AppColors.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No matching deals found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try searching for another dish or restaurant name, or clear active filters.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? AppColors.textMutedDark : AppColors.toneFF6B7280,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Show All Deals', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Backward Compatibility for HotDealsRow
/// ---------------------------------------------------------------------
class HotDealsRow extends StatefulWidget {
  final List<Deal> previewDeals;
  const HotDealsRow({super.key, this.previewDeals = deals});

  @override
  State<HotDealsRow> createState() => _HotDealsRowState();
}

class _HotDealsRowState extends State<HotDealsRow> {
  static const _interval = Duration(seconds: 4);
  Timer? _timer;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    final total = widget.previewDeals.take(3).length;
    if (total <= 1) return;
    _timer = Timer.periodic(_interval, (_) {
      if (!mounted) return;
      setState(() => _activeIndex = (_activeIndex + 1) % total);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final featuredDeals = widget.previewDeals.take(3).toList();
    if (featuredDeals.isEmpty) return const SizedBox.shrink();
    final index = _activeIndex.clamp(0, featuredDeals.length - 1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: SizedBox(
        height: 220,
        child: _SpotlightCard(
          deal: featuredDeals[index],
          isDark: Theme.of(context).brightness == Brightness.dark,
          onTap: () {
            final deal = featuredDeals[index];
            if (deal.vendorId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RestaurantMenuScreen(
                    vendorId: deal.vendorId,
                    restaurantName: deal.restaurant,
                    heroImageUrl: deal.imageUrl,
                    cuisine: deal.cuisine,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

import '../app_colors.dart';
import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../services/cart_service.dart';
import '../services/offer_service.dart';
import '../services/restaurant_service.dart';
import '../widgets/offer_widgets.dart';
import '../widgets/shimmer_loading.dart';
import 'FoodItemPage.dart';
import 'MainCartScreen.dart';
import 'RestuarantMenuScreen.dart' show RestaurantMenuScreen;

class OfferApplicableItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final double discountedPrice;
  final String imageUrl;
  final String? badge;
  final String? tag; // 'VEG', 'NON-VEG'
  final String categoryName;

  const OfferApplicableItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.discountedPrice,
    required this.imageUrl,
    this.badge,
    this.tag,
    this.categoryName = '',
  });

  bool get hasDiscount => discountedPrice < (price - 0.009);
}

class OfferExplanationScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? code;
  final String badge;
  final String expiry;
  final String scopeDescription;
  final List<Color>? gradientColors;
  final List<String>? terms;
  final List<OfferApplicableItem> applicableItems;
  final String restaurantName;
  final Map<String, int>? initialCart;
  final ValueChanged<String>? onAdd;
  final ValueChanged<String>? onRemove;
  final OfferCardData? offerCardData;
  final String? vendorId;
  final String? dealId;
  final double? discountPercent;
  final String scopeType;
  final List<String> itemIds;
  final List<String> categoryIds;

  const OfferExplanationScreen({
    super.key,
    required this.title,
    required this.subtitle,
    this.code,
    this.badge = 'SPECIAL OFFER',
    this.expiry = 'Limited Time',
    this.scopeDescription = 'Eligible menu items',
    this.gradientColors,
    this.terms,
    this.applicableItems = const [],
    this.restaurantName = 'Restaurant',
    this.initialCart,
    this.onAdd,
    this.onRemove,
    this.offerCardData,
    this.vendorId,
    this.dealId,
    this.discountPercent,
    this.scopeType = 'all_menu',
    this.itemIds = const [],
    this.categoryIds = const [],
  });

  @override
  State<OfferExplanationScreen> createState() => _OfferExplanationScreenState();
}

class _OfferExplanationScreenState extends State<OfferExplanationScreen> {
  late Map<String, int> _cart;
  List<OfferApplicableItem> _items = [];
  bool _isLoadingItems = false;
  String _selectedCategory = 'All Items';

  @override
  void initState() {
    super.initState();
    _cart = Map<String, int>.from(widget.initialCart ?? {});
    _items = List.from(widget.applicableItems);
    _syncWithCartService(notify: false);
    CartService.cartNotifier.addListener(_syncWithCartService);
    CartService.basketsNotifier.addListener(_syncWithCartService);

    if (_items.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadMenuItems();
      });
    }
  }

  @override
  void dispose() {
    CartService.cartNotifier.removeListener(_syncWithCartService);
    CartService.basketsNotifier.removeListener(_syncWithCartService);
    super.dispose();
  }

  void _syncWithCartService({bool notify = true}) {
    final vendorId = widget.vendorId;
    if (vendorId != null && vendorId.isNotEmpty) {
      final basket = CartService.getBasket(vendorId);
      if (basket != null && basket.isNotEmpty) {
        final updated = <String, int>{};
        for (final item in basket.items) {
          final key = item.menuItemId.isNotEmpty ? item.menuItemId : item.id;
          updated[key] = item.quantity;
        }
        if (notify && mounted) {
          setState(() => _cart = updated);
        } else {
          _cart = updated;
        }
        return;
      }
    }

    final current = CartService.currentCart;
    if (current != null && (vendorId == null || current.vendor?.id == vendorId) && current.isNotEmpty) {
      final updated = <String, int>{};
      for (final item in current.items) {
        final key = item.menuItemId.isNotEmpty ? item.menuItemId : item.id;
        updated[key] = item.quantity;
      }
      if (notify && mounted) {
        setState(() => _cart = updated);
      } else {
        _cart = updated;
      }
    }
  }

  Future<void> _loadMenuItems() async {
    final vendorId = widget.vendorId;
    if (vendorId == null || vendorId.isEmpty) return;

    setState(() => _isLoadingItems = true);

    try {
      var menuData = RestaurantService.getCachedMenu(vendorId);
      if (menuData == null || menuData.isEmpty) {
        menuData = await OfferService.fetchVendorMenu(vendorId);
      }

      if (menuData.isNotEmpty && mounted) {
        final loaded = <OfferApplicableItem>[];
        for (final cat in menuData) {
          final catId = cat['id']?.toString() ?? '';
          final catName = cat['name']?.toString() ?? 'Menu';
          final menuItems = cat['menu_items'];
          if (menuItems is List) {
            for (final raw in menuItems.whereType<Map>()) {
              final id = raw['id']?.toString() ?? '';

              // Check if dish qualifies for this offer
              bool qualifies = false;
              if (widget.itemIds.isNotEmpty) {
                qualifies = widget.itemIds.contains(id);
              } else if (widget.categoryIds.isNotEmpty) {
                qualifies = widget.categoryIds.contains(catId);
              } else if (widget.scopeType == 'item_set' || widget.scopeType == 'category_set') {
                qualifies = false;
              } else if (widget.dealId != null && widget.dealId!.isNotEmpty) {
                final bestOffer = raw['best_offer'];
                if (bestOffer is Map && bestOffer['id']?.toString() == widget.dealId) {
                  qualifies = true;
                } else if (raw['offers'] is List) {
                  qualifies = (raw['offers'] as List).any(
                    (o) => o is Map && o['id']?.toString() == widget.dealId,
                  );
                } else if (widget.scopeType == 'all_menu') {
                  qualifies = true;
                }
              } else {
                qualifies = widget.scopeType == 'all_menu';
              }

              if (!qualifies) continue;

              final name = raw['name']?.toString().trim() ?? 'Dish';
              final desc = raw['description']?.toString().trim() ?? '';
              final rawPrice = double.tryParse(raw['price']?.toString() ?? '') ?? 0.0;
              final img = _resolveImageUrl(raw['image']?.toString() ?? '');

              final foodTags = <String>[];
              if (raw['food_tags'] is List) {
                for (final t in (raw['food_tags'] as List).whereType<Map>()) {
                  final tn = t['name']?.toString() ?? '';
                  if (tn.isNotEmpty) foodTags.add(tn.toLowerCase());
                }
              }

              final isVeg = foodTags.any((t) => t.contains('veg') && !t.contains('non-veg')) ||
                  name.toLowerCase().contains('veg') ||
                  name.toLowerCase().contains('paneer') ||
                  name.toLowerCase().contains('salad');

              double discPrice = rawPrice;
              if (raw['discounted_price'] != null) {
                discPrice = double.tryParse(raw['discounted_price'].toString()) ?? rawPrice;
              } else if (widget.discountPercent != null && widget.discountPercent! > 0) {
                discPrice = rawPrice * (1.0 - (widget.discountPercent! / 100.0));
              } else {
                final match = RegExp(r'(\d+)%').firstMatch(widget.badge);
                if (match != null) {
                  final pct = double.tryParse(match.group(1) ?? '') ?? 0.0;
                  if (pct > 0) discPrice = rawPrice * (1.0 - (pct / 100.0));
                }
              }

              loaded.add(
                OfferApplicableItem(
                  id: id,
                  name: name,
                  description: desc,
                  price: rawPrice,
                  discountedPrice: discPrice,
                  imageUrl: img,
                  badge: widget.badge,
                  tag: isVeg ? 'VEG' : 'NON-VEG',
                  categoryName: catName,
                ),
              );
            }
          }
        }

        setState(() {
          _items = loaded;
          _isLoadingItems = false;
        });
      } else {
        setState(() => _isLoadingItems = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingItems = false);
    }
  }

  void _handleAddItem(String itemId) async {
    setState(() {
      _cart[itemId] = (_cart[itemId] ?? 0) + 1;
    });
    widget.onAdd?.call(itemId);
    await CartService.addItem(
      menuItemId: itemId,
      quantity: 1,
      vendorId: widget.vendorId,
      vendorName: widget.restaurantName,
    );
  }

  void _handleRemoveItem(String itemId) async {
    if ((_cart[itemId] ?? 0) > 0) {
      setState(() {
        final current = _cart[itemId]!;
        if (current <= 1) {
          _cart.remove(itemId);
        } else {
          _cart[itemId] = current - 1;
        }
      });
      widget.onRemove?.call(itemId);
      await CartService.removeItem(itemId, vendorId: widget.vendorId);
    }
  }

  void _handleSetQuantity(String itemId, int targetQty) async {
    setState(() {
      if (targetQty <= 0) {
        _cart.remove(itemId);
      } else {
        _cart[itemId] = targetQty;
      }
    });
    if (widget.vendorId != null && widget.vendorId!.isNotEmpty) {
      await CartService.setItemQuantity(
        vendorId: widget.vendorId!,
        menuItemId: itemId,
        targetQuantity: targetQty,
      );
    }
  }

  List<String> get _categories {
    final set = <String>{};
    for (final item in _items) {
      final cat = item.categoryName.trim();
      if (cat.isNotEmpty) {
        set.add(cat);
      }
    }
    return set.toList();
  }

  List<OfferApplicableItem> get _filteredItems {
    if (_selectedCategory == 'All Items') {
      return _items;
    }
    return _items.where((i) => i.categoryName.trim() == _selectedCategory).toList();
  }

  int get _totalCartItems => _cart.values.fold(0, (sum, count) => sum + count);

  double get _totalPrice {
    double sum = 0.0;
    for (final item in _items) {
      final qty = _cart[item.id] ?? 0;
      if (qty > 0) {
        sum += item.discountedPrice * qty;
      }
    }
    return sum;
  }

  OfferCardData _resolveCardData() {
    if (widget.offerCardData != null) {
      return widget.offerCardData!;
    }
    return OfferCardData(
      id: widget.dealId ?? widget.title,
      title: widget.title,
      restaurant: widget.restaurantName,
      distance: '1.2 km',
      category: 'Special Offer',
      discount: widget.badge,
      timeLeft: widget.expiry,
      subtitle: widget.subtitle,
      savings: 'Save ${widget.badge}',
      option: OfferCardOption.dark,
    );
  }

  void _navigateToRestaurantMenu(BuildContext context) {
    if (widget.vendorId != null && widget.vendorId!.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RestaurantMenuScreen(
            vendorId: widget.vendorId,
            restaurantName: widget.restaurantName,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgDark : AppColors.bgLight;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final cardBorder = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.white : AppColors.textPrimary;
    final subColor = isDark ? AppColors.textMutedDark : AppColors.materialGrey[600]!;
    final cardData = _resolveCardData();
    final categories = _categories;

    final defaultTerms = widget.terms ?? [
      'Discount is automatically applied to all eligible food items.',
      'When multiple offers exist for the same item, the highest discount is automatically selected.',
      'No manual voucher codes or coupon redemptions required.',
      'Prices shown on the menu and checkout already reflect the best discount.',
      'Offer valid during vendor business hours and availability.',
    ];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left_rounded, color: textColor, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.restaurantName.isNotEmpty ? widget.restaurantName : 'Offer Details',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (widget.vendorId != null && widget.vendorId!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.storefront_rounded, color: AppColors.primary),
              tooltip: 'Explore Restaurant Menu',
              onPressed: () => _navigateToRestaurantMenu(context),
            ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 110),
            children: [
              // Top Offer Card with Hero transition
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
                child: OfferCard(
                  heroTag: 'offer-card-${widget.dealId ?? cardData.id}',
                  offer: cardData,
                  onTap: null,
                ),
              ),

              // Auto-applied discount highlight pill
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AUTOMATIC DISCOUNT APPLIED',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'No coupon code needed. Discount is already applied to eligible prices below.',
                              style: TextStyle(
                                fontSize: 12,
                                color: subColor,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Applicable Food Items Section Header ───────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Eligible Dishes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (_items.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${_items.length}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (widget.vendorId != null && widget.vendorId!.isNotEmpty)
                      InkWell(
                        onTap: () => _navigateToRestaurantMenu(context),
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Full Menu',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(width: 3),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 12,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Category Filter Pills ─────────────────────────────────────
              if (categories.length > 1) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      itemCount: categories.length + 1,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final isAll = index == 0;
                        final catName = isAll ? 'All Items' : categories[index - 1];
                        final isSelected = _selectedCategory == catName;
                        final count = isAll
                            ? _items.length
                            : _items.where((e) => e.categoryName.trim() == catName).length;

                        return InkWell(
                          onTap: () => setState(() => _selectedCategory = catName),
                          borderRadius: BorderRadius.circular(999),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark ? AppColors.cardDark : AppColors.white),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark ? AppColors.borderDark : AppColors.border),
                                width: 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.28),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  catName,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected
                                        ? AppColors.white
                                        : (isDark ? AppColors.white : AppColors.textPrimary),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.white.withValues(alpha: 0.25)
                                        : (isDark
                                            ? AppColors.white.withValues(alpha: 0.1)
                                            : AppColors.black.withValues(alpha: 0.06)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? AppColors.white
                                          : (isDark
                                              ? AppColors.textMutedDark
                                              : AppColors.materialGrey[600]),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],

              // ── Dishes Content / Loading / Empty ───────────────────────────
              if (_isLoadingItems)
                _OfferDishesShimmerSkeleton(isDark: isDark)
              else if (_items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cardBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_outline_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Applies to Restaurant Menu',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'This offer automatically applies to all qualifying dishes from ${widget.restaurantName}.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: subColor,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                _buildDishesSection(isDark, textColor, subColor),

              // ── Explore Full Restaurant Menu Banner Card ───────────────────
              if (widget.vendorId != null && widget.vendorId!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
                  child: InkWell(
                    onTap: () => _navigateToRestaurantMenu(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.restaurant_menu_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Explore Restaurant Menu',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'See full menu & all dishes from ${widget.restaurantName}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: subColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'See Menu',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.white,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: AppColors.white,
                                  size: 13,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 10),

              // How Discounts Work Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'How it Works',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _StepItem(
                        step: '1',
                        text: 'Vendor publishes offers to discount selected menu items or categories.',
                        isDark: isDark,
                      ),
                      _StepItem(
                        step: '2',
                        text: 'When multiple offers overlap for the same dish, the maximum discount is automatically applied.',
                        isDark: isDark,
                      ),
                      _StepItem(
                        step: '3',
                        text: 'You don’t need to apply or redeem codes manually — the prices reflect the best deal directly.',
                        isDark: isDark,
                      ),
                      _StepItem(
                        step: '4',
                        text: 'Add items to your cart and enjoy direct savings on checkout.',
                        isDark: isDark,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Terms & Conditions Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.gavel_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Offer Terms',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      for (final term in defaultTerms)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  term,
                                  style: TextStyle(fontSize: 12.5, color: subColor, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating Bottom Cart Bar
          if (_totalCartItems > 0)
            Positioned(
              bottom: 20,
              left: 18,
              right: 18,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MainCartScreenPage(showBottomNav: false),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$_totalCartItems ${_totalCartItems == 1 ? "ITEM" : "ITEMS"}',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            if (_totalPrice > 0) ...[
                              const SizedBox(width: 10),
                              Text(
                                '₹${_totalPrice.toStringAsFixed(_totalPrice.truncateToDouble() == _totalPrice ? 0 : 2)}',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const Row(
                          children: [
                            Text(
                              'VIEW CART',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward_rounded, color: AppColors.white, size: 18),
                          ],
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

  Widget _buildDishesSection(bool isDark, Color textColor, Color subColor) {
    final categories = _categories;

    if (categories.length > 1 && _selectedCategory == 'All Items') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final cat in categories) ...[
            Builder(
              builder: (context) {
                final catItems = _items.where((e) => e.categoryName.trim() == cat).toList();
                if (catItems.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                      child: Row(
                        children: [
                          Container(
                            width: 3.5,
                            height: 15,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            cat,
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardDark : AppColors.surfaceRaised,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark ? AppColors.borderDark : AppColors.border,
                              ),
                            ),
                            child: Text(
                              '${catItems.length}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.textMutedDark : AppColors.materialGrey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        children: catItems.map((item) {
                          final qty = _cart[item.id] ?? 0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _OfferMenuItemCard(
                              item: item,
                              quantity: qty,
                              isDark: isDark,
                              onAdd: () => _handleAddItem(item.id),
                              onRemove: () => _handleRemoveItem(item.id),
                              onSetQuantity: (q) => _handleSetQuantity(item.id, q),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      );
    }

    final items = _filteredItems;
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Center(
          child: Text(
            'No items found in this category',
            style: TextStyle(
              fontSize: 13,
              color: subColor,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: items.map((item) {
          final qty = _cart[item.id] ?? 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _OfferMenuItemCard(
              item: item,
              quantity: qty,
              isDark: isDark,
              onAdd: () => _handleAddItem(item.id),
              onRemove: () => _handleRemoveItem(item.id),
              onSetQuantity: (q) => _handleSetQuantity(item.id, q),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _OfferMenuItemCard extends StatelessWidget {
  final OfferApplicableItem item;
  final int quantity;
  final bool isDark;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final ValueChanged<int> onSetQuantity;

  const _OfferMenuItemCard({
    required this.item,
    required this.quantity,
    required this.isDark,
    required this.onAdd,
    required this.onRemove,
    required this.onSetQuantity,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.cardDark : AppColors.white;
    final cardBorder = isDark ? AppColors.borderDark : AppColors.border;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FoodItemPage(
              id: item.id,
              name: item.name,
              category: item.categoryName,
              price: item.discountedPrice,
              originalPrice: item.hasDiscount ? item.price : null,
              description: item.description,
              isVeg: item.tag == 'VEG',
              isBestseller: item.badge != null || item.hasDiscount,
              rating: '4.8',
              photos: item.imageUrl.isNotEmpty ? [item.imageUrl] : const [],
              initialQuantity: quantity > 0 ? quantity : 1,
              onAddToCart: (targetQty) async {
                onSetQuantity(targetQty);
              },
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? AppColors.black.withValues(alpha: 0.2)
                  : AppColors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          border: Border.all(
                            color: item.tag == 'VEG'
                                ? AppColors.materialGreen
                                : AppColors.toneFFB91C1C,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Center(
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: item.tag == 'VEG'
                                  ? AppColors.materialGreen
                                  : AppColors.toneFFB91C1C,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      if (item.badge != null && item.badge!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.badge!,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      color: isDark ? AppColors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '₹${item.discountedPrice.toStringAsFixed(item.discountedPrice.truncateToDouble() == item.discountedPrice ? 0 : 2)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                      if (item.hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(
                          '₹${item.price.toStringAsFixed(item.price.truncateToDouble() == item.price ? 0 : 2)}',
                          style: TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                            color: isDark ? AppColors.textMutedDark : AppColors.materialGrey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textMutedDark : AppColors.materialGrey[600],
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Right Food Thumbnail with + ADD / Stepper Button overlay
            SizedBox(
              width: 104,
              height: 104,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: item.imageUrl.isNotEmpty
                          ? Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _foodPlaceholder(isDark),
                            )
                          : _foodPlaceholder(isDark),
                    ),
                  ),
                  Positioned(
                    bottom: -6,
                    child: quantity == 0
                        ? InkWell(
                            onTap: onAdd,
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: AppColors.primary, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.black.withValues(alpha: 0.12),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Text(
                                '+ ADD',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: onRemove,
                                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(999)),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Icon(Icons.remove_rounded, size: 14, color: AppColors.white),
                                  ),
                                ),
                                Text(
                                  '$quantity',
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                                InkWell(
                                  onTap: onAdd,
                                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(999)),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Icon(Icons.add_rounded, size: 14, color: AppColors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _foodPlaceholder(bool isDark) {
    return Container(
      color: isDark ? AppColors.black26 : AppColors.toneFFEEEEEE,
      child: const Center(
        child: Icon(
          Icons.fastfood_rounded,
          color: AppColors.materialGrey,
          size: 28,
        ),
      ),
    );
  }
}

String _resolveImageUrl(String path) {
  if (path.isEmpty) return '';
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  return '${ApiConfig.baseUrl}${path.startsWith('/') ? '' : '/'}$path';
}

class _StepItem extends StatelessWidget {
  final String step;
  final String text;
  final bool isDark;
  final bool isLast;

  const _StepItem({
    required this.step,
    required this.text,
    required this.isDark,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.white : AppColors.textPrimary;
    final subColor = isDark ? AppColors.textMutedDark : AppColors.materialGrey[600]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              step,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: isLast ? textColor : subColor, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferDishesShimmerSkeleton extends StatelessWidget {
  final bool isDark;

  const _OfferDishesShimmerSkeleton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.cardDark : AppColors.white;
    final cardBorder = isDark ? AppColors.borderDark : AppColors.border;
    final baseColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFEBEBF0);
    final highlightColor = isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF7F7FA);

    return ShimmerLoading(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          children: List.generate(
            3,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder, width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ShimmerBox(
                              width: 14,
                              height: 14,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            const SizedBox(width: 6),
                            ShimmerBox(
                              width: 50,
                              height: 12,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ShimmerBox(
                          width: double.infinity,
                          height: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 6),
                        ShimmerBox(
                          width: 140,
                          height: 12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ShimmerBox(
                              width: 60,
                              height: 16,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            const SizedBox(width: 8),
                            ShimmerBox(
                              width: 45,
                              height: 14,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    children: [
                      ShimmerBox(
                        width: 90,
                        height: 90,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      const SizedBox(height: 8),
                      ShimmerBox(
                        width: 80,
                        height: 30,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

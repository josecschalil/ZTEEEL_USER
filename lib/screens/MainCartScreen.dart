import '../app_colors.dart';
import 'package:flutter/material.dart';
import 'CheckOutScreen.dart';
import 'RestuarantMenuScreen.dart';
import '../config/api_config.dart';
import '../services/cart_service.dart';
import '../services/restaurant_service.dart';


class RecentVisit {
  final String id;
  final String name;
  final String imageUrl;
  final bool highlighted;
  const RecentVisit({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.highlighted = false,
  });
}

/// Main screen wrapper
class MainCartScreenPage extends StatelessWidget {
  final bool showBottomNav;
  const MainCartScreenPage({super.key, this.showBottomNav = true});

  @override
  Widget build(BuildContext context) {
    return MySelectionsScreen(showBottomNav: showBottomNav);
  }
}

class MySelectionsScreen extends StatefulWidget {
  final bool showBottomNav;
  const MySelectionsScreen({super.key, this.showBottomNav = true});

  @override
  State<MySelectionsScreen> createState() => _MySelectionsScreenState();
}

class _MySelectionsScreenState extends State<MySelectionsScreen> {
  int _navIndex = 3;
  List<RecentVisit> _recentVisits = const [];

  @override
  void initState() {
    super.initState();
    CartService.fetchCart();
    CartService.basketsNotifier.addListener(_onCartUpdated);
    CartService.cartNotifier.addListener(_onCartUpdated);
    _loadRecentVendors();
  }

  @override
  void dispose() {
    CartService.basketsNotifier.removeListener(_onCartUpdated);
    CartService.cartNotifier.removeListener(_onCartUpdated);
    super.dispose();
  }

  void _onCartUpdated() {
    if (mounted) setState(() {});
  }

  Future<void> _loadRecentVendors() async {
    final vendors = await RestaurantService.fetchRestaurants();
    if (!mounted || vendors.isEmpty) return;

    final visits = <RecentVisit>[];
    for (int i = 0; i < vendors.length && i < 6; i++) {
      final v = vendors[i];
      final id = v['id']?.toString() ?? '';
      final name = v['business_name']?.toString() ?? 'Restaurant';
      final rawImage = v['cover_image']?.toString() ?? v['icon_image']?.toString() ?? '';
      final imgUrl = rawImage.isNotEmpty
          ? (rawImage.startsWith('http://') || rawImage.startsWith('https://')
              ? rawImage
              : '${ApiConfig.baseUrl}${rawImage.startsWith('/') ? '' : '/'}$rawImage')
          : 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=200';

      visits.add(
        RecentVisit(
          id: id,
          name: name,
          imageUrl: imgUrl,
          highlighted: i == 0,
        ),
      );
    }

    if (mounted && visits.isNotEmpty) {
      setState(() => _recentVisits = visits);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    final baskets = CartService.allBaskets;
    final hasItems = baskets.isNotEmpty;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(isDark: isDark),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  await Future.wait([
                    CartService.fetchCart(),
                    _loadRecentVendors(),
                  ]);
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    _SectionHeader(
                      title: 'Active Baskets',
                      count: baskets.length,
                      isDark: isDark,
                    ),
                  const SizedBox(height: 14),
                  if (hasItems) ...[
                    for (final basket in baskets) ...[
                      _ShopBasketCard(
                        basket: basket,
                        isDark: isDark,
                        onIncrement: (item) => CartService.updateQuantity(
                          cartItemId: item.id,
                          quantity: item.quantity + 1,
                          vendorId: basket.vendor?.id,
                        ),
                        onDecrement: (item) => CartService.updateQuantity(
                          cartItemId: item.id,
                          quantity: item.quantity - 1,
                          vendorId: basket.vendor?.id,
                        ),
                        onRemoveItem: (item) => CartService.removeItem(
                          item.id,
                          vendorId: basket.vendor?.id,
                        ),
                        onClearBasket: () {
                          if (basket.vendor?.id.isNotEmpty == true) {
                            CartService.clearBasket(basket.vendor!.id);
                          }
                        },
                        onCheckout: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CheckoutScreen(
                                vendorId: basket.vendor?.id,
                              ),
                            ),
                          );
                        },
                        onTapShop: () {
                          if (basket.vendor?.id.isNotEmpty == true) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RestaurantMenuScreen(
                                  vendorId: basket.vendor!.id,
                                  restaurantName: basket.vendor?.businessName,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 8),
                    _CartTotalFooter(
                      isDark: isDark,
                      basketsCount: baskets.length,
                      itemCount: CartService.grandTotalItemCount,
                      subtotal: CartService.grandSubtotal,
                      savings: CartService.grandSavings,
                      total: CartService.grandTotal,
                      onCheckoutAll: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CheckoutScreen(checkoutAll: true),
                          ),
                        );
                      },
                    ),
                  ] else ...[
                    _EmptyBasketCard(isDark: isDark),
                  ],
                  const SizedBox(height: 24),
                  if (_recentVisits.isNotEmpty) ...[
                    _RecentlyVisitedSection(
                      isDark: isDark,
                      visits: _recentVisits,
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
        ],
        ),
      ),
      bottomNavigationBar: widget.showBottomNav
          ? _BottomNavBar(
              currentIndex: _navIndex,
              onTap: (i) => setState(() => _navIndex = i),
            )
          : null,
    );
  }
}

/// ---------------------------------------------------------------------
/// Sticky header
/// ---------------------------------------------------------------------
class _Header extends StatelessWidget {
  final bool isDark;
  const _Header({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final textPrimary = isDark ? AppColors.white : AppColors.textPrimary;
    final textMuted = isDark
        ? AppColors.textMutedDark
        : AppColors.toneFF8E8E93;
    final borderColor = isDark
        ? AppColors.borderDark
        : AppColors.border;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.black.withValues(alpha: 0.15)
                : AppColors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (canPop) ...[
                _RoundIconButton(
                  icon: Icons.chevron_left_rounded,
                  size: 18,
                  isDark: isDark,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(width: 12),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(
                      alpha: isDark ? 0.2 : 0.1,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_bag_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SHOPPING BASKETS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Your Selections',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 8),
              _RoundIconButton(
                icon: Icons.refresh_rounded,
                size: 18,
                isDark: isDark,
                onTap: () => CartService.fetchCart(),
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
  final double size;
  final bool isDark;
  final VoidCallback? onTap;

  const _RoundIconButton({
    required this.icon,
    required this.isDark,
    this.size = 16,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark
              ? AppColors.black.withValues(alpha: 0.6)
              : AppColors.white.withValues(alpha: 0.9),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.toneFFEEEEEE,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isDark ? AppColors.white : AppColors.textPrimary,
          size: size,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final bool isDark;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? AppColors.white : AppColors.textPrimary;

    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.toneFFEEEEEE,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textMutedDark : AppColors.materialGrey[600],
            ),
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------
/// Empty Basket Card
/// ---------------------------------------------------------------------
class _EmptyBasketCard extends StatelessWidget {
  final bool isDark;
  const _EmptyBasketCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.cardDark : AppColors.white;
    final cardBorder = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textPrimary = isDark ? AppColors.white : AppColors.textPrimary;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.black.withValues(alpha: 0.2) : AppColors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
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
              Icons.shopping_cart_outlined,
              color: AppColors.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your Cart is Empty',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select delicious dishes from your favorite restaurants. You can maintain multiple baskets simultaneously.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: textMuted),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Shop Basket Card (Renders an entire shop's basket with line items & steppers)
/// ---------------------------------------------------------------------
class _ShopBasketCard extends StatelessWidget {
  final CartData basket;
  final bool isDark;
  final ValueChanged<CartItemModel> onIncrement;
  final ValueChanged<CartItemModel> onDecrement;
  final ValueChanged<CartItemModel> onRemoveItem;
  final VoidCallback onClearBasket;
  final VoidCallback onCheckout;
  final VoidCallback onTapShop;

  const _ShopBasketCard({
    required this.basket,
    required this.isDark,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemoveItem,
    required this.onClearBasket,
    required this.onCheckout,
    required this.onTapShop,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.cardDark : AppColors.white;
    final cardBorder = isDark
        ? AppColors.borderDark
        : AppColors.borderLight;
    final textPrimary = isDark ? AppColors.white : AppColors.textPrimary;
    final textMuted = isDark
        ? AppColors.textMutedDark
        : AppColors.textMuted;

    final shopName = basket.vendor?.businessName ?? 'Restaurant';
    final coverImage = basket.vendor?.coverImage;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.black.withValues(alpha: 0.25)
                : AppColors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Shop Header ─────────────────────────────────────────
          InkWell(
            onTap: onTapShop,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 44,
                      height: 44,
                      color: isDark ? AppColors.toneFF3A2820 : AppColors.surfaceRaised,
                      child: coverImage != null && coverImage.isNotEmpty
                          ? Image.network(
                              coverImage,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.storefront_rounded,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            )
                          : const Icon(
                              Icons.storefront_rounded,
                              color: AppColors.primary,
                              size: 24,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                shopName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: textMuted,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${basket.totalItemCount} item${basket.totalItemCount == 1 ? '' : 's'} in basket',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Clear Basket?'),
                          content: Text('Remove all items from $shopName?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                onClearBasket();
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.materialRed,
                              ),
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: textMuted,
                    ),
                    tooltip: 'Clear Basket',
                  ),
                ],
              ),
            ),
          ),

          Divider(height: 1, color: cardBorder),

          // ── Basket Item List ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                for (int i = 0; i < basket.items.length; i++) ...[
                  _BasketItemRow(
                    item: basket.items[i],
                    isDark: isDark,
                    onIncrement: () => onIncrement(basket.items[i]),
                    onDecrement: () => onDecrement(basket.items[i]),
                    onRemove: () => onRemoveItem(basket.items[i]),
                  ),
                  if (i < basket.items.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Divider(
                        height: 1,
                        color: isDark
                            ? AppColors.toneFF35261F
                            : AppColors.surfaceRaised,
                      ),
                    ),
                ],
              ],
            ),
          ),

          Divider(height: 1, color: cardBorder),

          // ── Shop Subtotal & Action Bar ──────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Shop Subtotal',
                      style: TextStyle(
                        fontSize: 13,
                        color: textMuted,
                      ),
                    ),
                    Text(
                      '\$${basket.subtotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                if (basket.totalDiscount > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Offers & Savings',
                        style: TextStyle(
                          fontSize: 13,
                          color: textMuted,
                        ),
                      ),
                      Text(
                        '-\$${basket.totalDiscount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Basket Total',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    Text(
                      '\$${basket.finalTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: onCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Checkout from $shopName',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: AppColors.white,
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
    );
  }
}

class _BasketItemRow extends StatelessWidget {
  final CartItemModel item;
  final bool isDark;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _BasketItemRow({
    required this.item,
    required this.isDark,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? AppColors.white : AppColors.textPrimary;
    final textMuted = isDark
        ? AppColors.textMutedDark
        : AppColors.textMuted;

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 48,
            height: 48,
            color: isDark ? AppColors.redeemSurfaceDark : AppColors.surfaceRaised,
            child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                ? Image.network(
                    item.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.restaurant_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  )
                : const Icon(
                    Icons.restaurant_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    '\$${item.lineTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  if (item.lineDiscount > 0) ...[
                    const SizedBox(width: 6),
                    Text(
                      '\$${item.subtotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 11,
                        decoration: TextDecoration.lineThrough,
                        color: textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: isDark ? AppColors.toneFF35261F : AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MiniIconButton(
                icon: item.quantity <= 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
                isDark: isDark,
                onTap: onDecrement,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${item.quantity}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
              _MiniIconButton(
                icon: Icons.add_rounded,
                isDark: isDark,
                onTap: onIncrement,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniIconButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _MiniIconButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? AppColors.toneFF453026 : AppColors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 2,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 14,
          color: isDark ? AppColors.white : AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Total Cart Value & Checkout All Summary Card
/// ---------------------------------------------------------------------
class _CartTotalFooter extends StatelessWidget {
  final bool isDark;
  final int basketsCount;
  final int itemCount;
  final double subtotal;
  final double savings;
  final double total;
  final VoidCallback onCheckoutAll;

  const _CartTotalFooter({
    required this.isDark,
    required this.basketsCount,
    required this.itemCount,
    required this.subtotal,
    required this.savings,
    required this.total,
    required this.onCheckoutAll,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.cardDark : AppColors.white;
    final borderColor = isDark
        ? AppColors.borderDark
        : AppColors.borderLight;
    final textPrimary = isDark ? AppColors.white : AppColors.textPrimary;
    final textMuted = isDark
        ? AppColors.textMutedDark
        : AppColors.textMuted;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.black.withValues(alpha: 0.25)
                : AppColors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(
                          alpha: isDark ? 0.2 : 0.1,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'All Baskets Summary',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.toneFF3A2820
                        : AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$basketsCount Basket${basketsCount == 1 ? '' : 's'} • $itemCount Items',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Grand Subtotal',
                  style: TextStyle(fontSize: 13, color: textMuted),
                ),
                Text(
                  '\$${subtotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
            if (savings > 0) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Savings',
                    style: TextStyle(fontSize: 13, color: textMuted),
                  ),
                  Text(
                    '-\$${savings.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green,
                    ),
                  ),
                ],
              ),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(
                height: 1,
                color: isDark
                    ? AppColors.borderDark
                    : AppColors.toneFFE5E7EB,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GRAND TOTAL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: onCheckoutAll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        basketsCount > 1 ? 'Checkout All Baskets' : 'Proceed to Checkout',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// "Recently Visited" horizontal avatar row
/// ---------------------------------------------------------------------
class _RecentlyVisitedSection extends StatelessWidget {
  final bool isDark;
  final List<RecentVisit> visits;

  const _RecentlyVisitedSection({
    required this.isDark,
    required this.visits,
  });

  @override
  Widget build(BuildContext context) {
    final textMuted = isDark
        ? AppColors.textMutedDark
        : AppColors.textMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'EXPLORE RESTAURANTS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textMuted,
              letterSpacing: 1.2,
            ),
          ),
        ),
        SizedBox(
          height: 94,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: visits.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, i) {
              final visit = visits[i];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RestaurantMenuScreen(
                        vendorId: visit.id,
                        restaurantName: visit.name,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 64,
                  child: Column(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: visit.highlighted
                                ? AppColors.primary
                                : (isDark
                                    ? AppColors.borderDark
                                    : AppColors.toneFFE5E7EB),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            visit.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.restaurant_rounded,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        visit.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.white70
                              : AppColors.toneFF4B5563,
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

/// ---------------------------------------------------------------------
/// Bottom navigation bar
/// ---------------------------------------------------------------------
class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final borderColor = isDark
        ? AppColors.borderDark
        : AppColors.border;
    final mutedText = isDark
        ? AppColors.textMutedDark
        : AppColors.materialGrey[400]!;

    final items = [
      (Icons.home_rounded, 'Home'),
      (Icons.local_offer_rounded, 'Deals'),
      (Icons.receipt_long_rounded, 'My Orders'),
      (Icons.shopping_cart_rounded, 'My Cart'),
      (Icons.person_rounded, 'Profile'),
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        10 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: navBg,
        border: Border(top: BorderSide(color: borderColor, width: 1)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.black.withValues(alpha: 0.3)
                : AppColors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (i) {
          final (icon, label) = items[i];
          final selected = i == currentIndex;

          return Expanded(
            child: InkWell(
              onTap: () => onTap(i),
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 22,
                    color: selected ? AppColors.primary : mutedText,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? AppColors.primary : mutedText,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

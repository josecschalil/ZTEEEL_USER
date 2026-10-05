import '../app_colors.dart';
import 'package:flutter/material.dart';
import 'QrScreen.dart';
import 'RecentOrderScreen.dart';
import '../services/cart_service.dart';
import '../services/redemption_service.dart';


class CheckoutScreen extends StatefulWidget {
  final String? vendorId;
  final bool checkoutAll;

  const CheckoutScreen({
    super.key,
    this.vendorId,
    this.checkoutAll = false,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLoading = false;
  bool _isGeneratingQr = false;
  String? _selectedRewardOptionId;

  @override
  void initState() {
    super.initState();
    _loadCart();
    CartService.cartNotifier.addListener(_onCartChanged);
    CartService.basketsNotifier.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    CartService.cartNotifier.removeListener(_onCartChanged);
    CartService.basketsNotifier.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadCart() async {
    setState(() => _isLoading = true);
    await CartService.fetchCart();
    if (mounted) {
      final cart = _getActiveCart();
      _selectedRewardOptionId = cart?.reward?.selectedOption?.id;
      setState(() => _isLoading = false);
    }
  }

  CartData? _getActiveCart() {
    if (widget.vendorId != null && widget.vendorId!.isNotEmpty) {
      return CartService.getBasket(widget.vendorId) ?? CartService.currentCart;
    }
    return CartService.currentCart;
  }

  Future<void> _increment(CartItemModel item, {String? vendorId}) async {
    await CartService.updateQuantity(
      cartItemId: item.id,
      quantity: item.quantity + 1,
      vendorId: vendorId,
    );
  }

  Future<void> _decrement(CartItemModel item, {String? vendorId}) async {
    await CartService.updateQuantity(
      cartItemId: item.id,
      quantity: item.quantity - 1,
      vendorId: vendorId,
    );
  }

  Future<void> _selectRewardOption(String optionId) async {
    setState(() => _selectedRewardOptionId = optionId);
    final targetVendor = widget.vendorId ?? _getActiveCart()?.vendor?.id;
    await CartService.selectRewardOption(optionId, vendorId: targetVendor);
  }

  Future<void> _onGenerateQr() async {
    if (widget.checkoutAll) {
      final baskets = CartService.allBaskets;
      if (baskets.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your cart is empty.'),
            backgroundColor: AppColors.primary,
          ),
        );
        return;
      }

      setState(() => _isGeneratingQr = true);
      final result = await RedemptionService.generateAllRedemptions();
      if (!mounted) return;
      setState(() => _isGeneratingQr = false);

      if (result['success'] == true && result['sessions'] is List) {
        final sessions = result['sessions'] as List<RedemptionSessionData>;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${sessions.length} separate shop orders created! QR codes are active.'),
            backgroundColor: AppColors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const OrdersScreen(),
          ),
        );
      } else {
        final errorMsg = result['error']?.toString() ?? 'Unable to generate redemption sessions.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppColors.materialRed.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final cart = _getActiveCart();
    if (cart == null || cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty.'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    final hasFreeItemMilestone = cart.reward?.milestone?.hasFreeItem == true ||
        cart.appliedMilestone?.hasFreeItem == true;
    final hasRewardOptions = (cart.reward?.availableOptions.isNotEmpty ?? false) ||
        (cart.appliedMilestone?.rewardOptions.isNotEmpty ?? false);

    if (hasFreeItemMilestone && hasRewardOptions && cart.reward?.selectedOption == null && _selectedRewardOptionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your free milestone reward item above!'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    setState(() => _isGeneratingQr = true);
    final result = await RedemptionService.generateRedemption(vendorId: widget.vendorId ?? cart.vendor?.id);
    if (!mounted) return;
    setState(() => _isGeneratingQr = false);

    if (result['success'] == true && result['data'] is RedemptionSessionData) {
      final session = result['data'] as RedemptionSessionData;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RedeemQrScreen(session: session),
        ),
      );
    } else {
      final errorMsg = result['error']?.toString() ?? 'Unable to generate redemption session.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.materialRed.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.checkoutAll) {
      return _buildCheckoutAllView(isDark);
    }

    final cart = _getActiveCart() ?? const CartData();
    final subtotal = cart.subtotal;
    final discount = cart.totalDiscount;
    final totalPayable = cart.finalTotal;

    // Calculate milestone progress
    final reward = cart.reward;
    final nextMilestone = cart.nextMilestone ?? reward?.nextMilestone;
    final appliedMilestone = cart.appliedMilestone ?? reward?.milestone;

    double amountToNext = reward?.amountToNext ?? 0.0;
    double progress = 1.0;
    if (nextMilestone != null && nextMilestone.thresholdAmount > 0) {
      final target = nextMilestone.thresholdAmount;
      if (amountToNext <= 0) {
        amountToNext = (target - cart.eligibleSubtotal).clamp(0.0, target);
      }
      progress = (cart.eligibleSubtotal / target).clamp(0.0, 1.0);
    } else if (appliedMilestone != null) {
      amountToNext = 0.0;
      progress = 1.0;
    }

    final availableRewards = reward?.availableOptions.isNotEmpty == true
        ? reward!.availableOptions
        : (appliedMilestone?.rewardOptions ?? const []);

    final hasMilestones = (cart.milestones.isNotEmpty) ||
        appliedMilestone != null ||
        nextMilestone != null ||
        (reward != null &&
            (reward.milestone != null ||
                reward.nextMilestone != null ||
                reward.availableOptions.isNotEmpty));

    return Scaffold(
      backgroundColor: isDark ? AppColors.checkoutBgDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              isDark: isDark,
              vendorName: cart.vendor?.businessName,
            ),
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (cart.isEmpty)
              _buildEmptyView(isDark)
            else
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  children: [
                    for (final item in cart.items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _SelectionItemCard(
                          item: item,
                          isDark: isDark,
                          onIncrement: () => _increment(item, vendorId: cart.vendor?.id),
                          onDecrement: () => _decrement(item, vendorId: cart.vendor?.id),
                        ),
                      ),
                    _AddMoreItemsButton(
                      isDark: isDark,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    if (hasMilestones) ...[
                      const SizedBox(height: 24),
                      _RewardsProgressCard(
                        isDark: isDark,
                        amountToFreeItem: amountToNext,
                        progress: progress,
                        milestoneName: nextMilestone?.name ?? appliedMilestone?.name,
                        isUnlocked: appliedMilestone != null,
                        availableRewards: availableRewards,
                        selectedRewardId: _selectedRewardOptionId ?? reward?.selectedOption?.id,
                        onSelectReward: _selectRewardOption,
                      ),
                    ],
                    const SizedBox(height: 16),
                    _PriceBreakdownCard(
                      isDark: isDark,
                      subtotal: subtotal,
                      discount: discount,
                      total: totalPayable,
                    ),
                    const SizedBox(height: 16),
                    _GenerateQrButton(
                      isDark: isDark,
                      isLoading: _isGeneratingQr,
                      onPressed: _onGenerateQr,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutAllView(bool isDark) {
    final baskets = CartService.allBaskets;
    final grandSubtotal = CartService.grandSubtotal;
    final grandSavings = CartService.grandSavings;
    final grandTotal = CartService.grandTotal;

    return Scaffold(
      backgroundColor: isDark ? AppColors.checkoutBgDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              isDark: isDark,
              vendorName: '${baskets.length} Separate Shop Orders',
            ),
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (baskets.isEmpty)
              _buildEmptyView(isDark)
            else
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  children: [
                    for (final basket in baskets) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.storefront_rounded,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              basket.vendor?.businessName ?? 'Restaurant',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.white : AppColors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      for (final item in basket.items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _SelectionItemCard(
                            item: item,
                            isDark: isDark,
                            onIncrement: () => _increment(item, vendorId: basket.vendor?.id),
                            onDecrement: () => _decrement(item, vendorId: basket.vendor?.id),
                          ),
                        ),
                      const SizedBox(height: 12),
                    ],
                    _AddMoreItemsButton(
                      isDark: isDark,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(height: 16),
                    _PriceBreakdownCard(
                      isDark: isDark,
                      subtotal: grandSubtotal,
                      discount: grandSavings,
                      total: grandTotal,
                    ),
                    const SizedBox(height: 16),
                    _GenerateQrButton(
                      isDark: isDark,
                      isLoading: _isGeneratingQr,
                      title: 'Generate All QR Codes (${baskets.length} Orders)',
                      subtitle: 'Generates separate QR redemption vouchers for each restaurant.',
                      onPressed: _onGenerateQr,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(bool isDark) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_basket_outlined,
              size: 64,
              color: isDark ? AppColors.materialGrey[600] : AppColors.materialGrey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.white : AppColors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add items from a restaurant menu to proceed.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.materialGrey[400] : AppColors.materialGrey[600],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Explore Menu',
                style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Sticky header
/// ---------------------------------------------------------------------
class _Header extends StatelessWidget {
  final bool isDark;
  final String? vendorName;
  const _Header({required this.isDark, this.vendorName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.checkoutBgDark : AppColors.backgroundLight)
            .withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.white.withValues(alpha: 0.1) : AppColors.materialGrey[200]!,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).maybePop(),
              icon: Icon(
                Icons.arrow_back,
                color: isDark ? AppColors.white : AppColors.black87,
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your Selection',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.white : AppColors.black,
                  ),
                ),
                if (vendorName != null && vendorName!.isNotEmpty)
                  Text(
                    vendorName!,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.materialGrey[400] : AppColors.materialGrey[600],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Selection item card with quantity stepper
/// ---------------------------------------------------------------------
class _SelectionItemCard extends StatelessWidget {
  final CartItemModel item;
  final bool isDark;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _SelectionItemCard({
    required this.item,
    required this.isDark,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final lineTotal = item.lineTotal;
    final hasDiscount = item.lineDiscount > 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.materialGrey[100]!,
        ),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: AppColors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 80,
              color: isDark ? AppColors.redeemSurfaceDark : AppColors.surfaceRaised,
              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? Image.network(
                      item.imageUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.restaurant_rounded,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    )
                  : const Icon(
                      Icons.restaurant_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.white : AppColors.black,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12, top: 2),
                  child: Text(
                    item.description?.isNotEmpty == true
                        ? item.description!
                        : '${item.itemType.toUpperCase()} • \$${item.unitPrice.toStringAsFixed(2)} each',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.materialGrey[400] : AppColors.materialGrey[500],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '\$${lineTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.primary,
                          ),
                        ),
                        if (hasDiscount) ...[
                          const SizedBox(width: 6),
                          Text(
                            '\$${item.subtotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              fontSize: 11,
                              color: isDark ? AppColors.materialGrey[500] : AppColors.materialGrey[400],
                            ),
                          ),
                        ],
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.white.withValues(alpha: 0.1)
                            : AppColors.materialGrey[100],
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _StepperButton(
                            icon: Icons.remove,
                            filled: false,
                            isDark: isDark,
                            onTap: onDecrement,
                          ),
                          SizedBox(
                            width: 24,
                            child: Text(
                              '${item.quantity}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.white : AppColors.black,
                              ),
                            ),
                          ),
                          _StepperButton(
                            icon: Icons.add,
                            filled: true,
                            isDark: isDark,
                            onTap: onIncrement,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final bool filled;
  final bool isDark;
  final VoidCallback onTap;
  const _StepperButton({
    required this.icon,
    required this.filled,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled
              ? AppColors.primary
              : (isDark ? AppColors.white.withValues(alpha: 0.2) : AppColors.white),
          boxShadow: filled
              ? null
              : const [BoxShadow(color: AppColors.black12, blurRadius: 2)],
        ),
        child: Icon(
          icon,
          size: 16,
          color: filled
              ? AppColors.white
              : (isDark ? AppColors.white : AppColors.black87),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// "Add more items" dashed prompt button
/// ---------------------------------------------------------------------
class _AddMoreItemsButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;
  const _AddMoreItemsButton({required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: DottedBorderBox(
        isDark: isDark,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle,
                color: isDark ? AppColors.materialGrey[300] : AppColors.materialGrey[700],
              ),
              const SizedBox(width: 8),
              Text(
                'Add more items',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.materialGrey[300] : AppColors.materialGrey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DottedBorderBox extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const DottedBorderBox({super.key, required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: isDark ? AppColors.white.withValues(alpha: 0.2) : AppColors.materialGrey[300]!,
        radius: 12,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const dashWidth = 5.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => false;
}

/// ---------------------------------------------------------------------
/// Rewards progress card
/// ---------------------------------------------------------------------
class _RewardsProgressCard extends StatelessWidget {
  final bool isDark;
  final double amountToFreeItem;
  final double progress;
  final String? milestoneName;
  final bool isUnlocked;
  final List<RewardOption> availableRewards;
  final String? selectedRewardId;
  final ValueChanged<String>? onSelectReward;

  const _RewardsProgressCard({
    required this.isDark,
    required this.amountToFreeItem,
    required this.progress,
    this.milestoneName,
    this.isUnlocked = false,
    this.availableRewards = const [],
    this.selectedRewardId,
    this.onSelectReward,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked
              ? AppColors.green.withValues(alpha: 0.5)
              : (isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.materialGrey[100]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isUnlocked ? Icons.stars_rounded : Icons.card_giftcard,
                color: isUnlocked ? AppColors.green : AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: isUnlocked
                    ? Text(
                        milestoneName != null ? '🎉 $milestoneName Unlocked!' : '🎉 Milestone Reward Unlocked!',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.green,
                        ),
                      )
                    : RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.materialGrey[200] : AppColors.materialGrey[700],
                          ),
                          children: [
                            const TextSpan(text: 'Spend '),
                            TextSpan(
                              text: '\$${amountToFreeItem.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: milestoneName != null
                                   ? ' more to unlock $milestoneName!'
                                  : ' more to unlock a FREE reward item!',
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                Container(
                  height: 8,
                  color: isDark
                      ? AppColors.white.withValues(alpha: 0.1)
                      : AppColors.materialGrey[200],
                ),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: isUnlocked ? AppColors.green : AppColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: (isUnlocked ? AppColors.green : AppColors.primary).withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ProgressMarker(
                label: 'Start',
                color: isDark ? AppColors.materialGrey[500]! : AppColors.materialGrey[400]!,
              ),
              _ProgressMarker(
                label: 'Discount',
                color: AppColors.primary,
              ),
              _ProgressMarker(
                label: isUnlocked ? 'Unlocked!' : 'Reward',
                color: isUnlocked ? AppColors.green : (isDark ? AppColors.materialGrey[500]! : AppColors.materialGrey[400]!),
              ),
            ],
          ),

          // Available reward gifts picker
          if (availableRewards.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Choose your Free Reward:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.materialGrey[300] : AppColors.materialGrey[800],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableRewards.map((opt) {
                final isSelected = opt.id == selectedRewardId;
                return InkWell(
                  onTap: () => onSelectReward?.call(opt.id),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.green.withValues(alpha: 0.15)
                          : (isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.materialGrey[100]),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.green : AppColors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                          size: 14,
                          color: isSelected ? AppColors.green : AppColors.materialGrey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          opt.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? AppColors.green
                                : (isDark ? AppColors.white : AppColors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProgressMarker extends StatelessWidget {
  final String label;
  final Color color;
  const _ProgressMarker({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------
/// Price breakdown card
/// ---------------------------------------------------------------------
class _PriceBreakdownCard extends StatelessWidget {
  final bool isDark;
  final double subtotal;
  final double discount;
  final double total;
  const _PriceBreakdownCard({
    required this.isDark,
    required this.subtotal,
    required this.discount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final discountPct = subtotal > 0 && discount > 0 ? ((discount / subtotal) * 100).toInt() : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.materialGrey[100]!,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.materialGrey[400] : AppColors.materialGrey[500],
                ),
              ),
              Text(
                '\$${subtotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.white : AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Discount',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.materialGrey[400] : AppColors.materialGrey[500],
                    ),
                  ),
                  if (discountPct > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.materialGreen.withValues(alpha: 0.2)
                            : AppColors.materialGreen[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$discountPct% OFF',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.materialGreen[300] : AppColors.materialGreen[700],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                '-\$${discount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.materialGreen[300] : AppColors.materialGreen[600],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              height: 1,
              color: isDark ? AppColors.white.withValues(alpha: 0.1) : AppColors.materialGrey[200],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Payable',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.white : AppColors.black,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// "Generate QR Code" action button
/// ---------------------------------------------------------------------
class _GenerateQrButton extends StatelessWidget {
  final bool isDark;
  final bool isLoading;
  final String? title;
  final String? subtitle;
  final VoidCallback onPressed;

  const _GenerateQrButton({
    required this.isDark,
    required this.isLoading,
    this.title,
    this.subtitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 6,
              shadowColor: AppColors.primary.withValues(alpha: 0.25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.qr_code_2, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        title ?? 'Generate QR Code',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          subtitle ?? 'Show the QR code at the counter to redeem your order.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.materialGrey[500] : AppColors.materialGrey[400],
          ),
        ),
      ],
    );
  }
}

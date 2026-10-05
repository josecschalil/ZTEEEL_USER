import '../app_colors.dart';
import 'package:flutter/material.dart';


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
  });

  @override
  State<OfferExplanationScreen> createState() => _OfferExplanationScreenState();
}

class _OfferExplanationScreenState extends State<OfferExplanationScreen> {
  late Map<String, int> _cart;

  @override
  void initState() {
    super.initState();
    _cart = Map<String, int>.from(widget.initialCart ?? {});
  }

  void _handleAddItem(String itemId) {
    setState(() {
      _cart[itemId] = (_cart[itemId] ?? 0) + 1;
    });
    widget.onAdd?.call(itemId);
  }

  void _handleRemoveItem(String itemId) {
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
    }
  }

  int get _totalCartItems => _cart.values.fold(0, (sum, count) => sum + count);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgDark : AppColors.bgLight;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final cardBorder = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.white : AppColors.textPrimary;
    final subColor = isDark ? AppColors.textMutedDark : AppColors.materialGrey[600]!;

    final defaultTerms = widget.terms ?? [
      'Discount is automatically applied to all eligible food items.',
      'When multiple offers exist for the same item, the highest discount is automatically selected.',
      'No manual voucher codes or coupon redemptions required.',
      'Prices shown on the menu and checkout already reflect the best discount.',
      'Offer valid during vendor business hours and availability.',
    ];

    final headerGradient = widget.gradientColors ?? [
      AppColors.primary,
      AppColors.toneFFEA580C,
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
          'Offer Details',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
            children: [
              // Hero Banner Card
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: headerGradient,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: headerGradient.first.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.badge.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppColors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, color: AppColors.white, size: 15),
                            const SizedBox(width: 4),
                            Text(
                              widget.expiry,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppColors.white.withValues(alpha: 0.9),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Auto-Applied Highlight Banner (No code redemption needed)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.25),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: AppColors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AUTOMATIC DISCOUNT',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.white,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Price is reduced automatically. No coupon code needed.',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.toneFFEDE7E2,
                                    fontWeight: FontWeight.w500,
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
              const SizedBox(height: 20),

              // Offer Key Stats / Details Grid
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.restaurant_menu_rounded,
                                color: AppColors.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text('Applies To', style: TextStyle(fontSize: 12, color: subColor)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.applicableItems.isNotEmpty
                                ? '${widget.applicableItems.length} Menu Items'
                                : widget.scopeDescription,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.savings_outlined,
                                color: AppColors.vegGreen,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text('Max Savings', style: TextStyle(fontSize: 12, color: subColor)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.badge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Applicable Food Items Section ──────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Applicable Dishes',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (widget.applicableItems.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${widget.applicableItems.length} items',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (widget.applicableItems.isEmpty)
                Container(
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
                )
              else
                Column(
                  children: widget.applicableItems.map((item) {
                    final qty = _cart[item.id] ?? 0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? AppColors.black.withValues(alpha: 0.2)
                                : AppColors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Food Thumbnail
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: item.imageUrl.isNotEmpty
                                  ? Image.network(
                                      item.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Container(
                                        color: isDark ? AppColors.black26 : AppColors.materialGrey[200],
                                        child: const Icon(
                                          Icons.fastfood_rounded,
                                          color: AppColors.materialGrey,
                                          size: 28,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: isDark ? AppColors.black26 : AppColors.materialGrey[200],
                                      child: const Icon(
                                        Icons.fastfood_rounded,
                                        color: AppColors.materialGrey,
                                        size: 28,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (item.tag != null) ...[
                                      Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: item.tag == 'VEG'
                                                ? AppColors.success
                                                : AppColors.toneFFDC2626,
                                            width: 1.2,
                                          ),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: item.tag == 'VEG'
                                                ? AppColors.success
                                                : AppColors.toneFFDC2626,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                    ],
                                    Expanded(
                                      child: Text(
                                        item.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (item.description.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    item.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: subColor,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
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
                                              color: subColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    // Add / Quantity Stepper Button
                                    qty == 0
                                        ? InkWell(
                                            onTap: () => _handleAddItem(item.id),
                                            borderRadius: BorderRadius.circular(20),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 14,
                                                vertical: 5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary,
                                                borderRadius: BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors.primary
                                                        .withValues(alpha: 0.35),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: const Text(
                                                '+ Add',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.white,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            height: 28,
                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                InkWell(
                                                  onTap: () => _handleRemoveItem(item.id),
                                                  child: const Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 6),
                                                    child: Icon(
                                                      Icons.remove_rounded,
                                                      size: 16,
                                                      color: AppColors.white,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  '$qty',
                                                  style: const TextStyle(
                                                    color: AppColors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () => _handleAddItem(item.id),
                                                  child: const Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 6),
                                                    child: Icon(
                                                      Icons.add_rounded,
                                                      size: 16,
                                                      color: AppColors.white,
                                                    ),
                                                  ),
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
                  }).toList(),
                ),
              const SizedBox(height: 20),

              // How Discounts Work Section
              Container(
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
              const SizedBox(height: 20),

              // Terms & Conditions Section
              Container(
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
            ],
          ),

          // Bottom Action Button
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 6,
                  shadowColor: AppColors.primary.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  _totalCartItems > 0
                      ? 'VIEW CART ($_totalCartItems ITEMS)'
                      : 'EXPLORE FULL MENU',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
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

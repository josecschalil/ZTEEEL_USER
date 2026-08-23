import 'package:flutter/material.dart';
import 'QrScreen.dart';

class CheckoutColors {
  static const primary = Color(0xFFEE5B2B);
  static const backgroundLight = Color(0xFFF8F6F6);
  static const backgroundDark = Color(0xFF221510);
  static const navBarDark = Color(0xFF1A100C);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'PlusJakartaSans',
    scaffoldBackgroundColor: backgroundLight,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    fontFamily: 'PlusJakartaSans',
    scaffoldBackgroundColor: backgroundDark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ),
  );
}

/// ---------------------------------------------------------------------
/// Data model
/// ---------------------------------------------------------------------
class SelectionItem {
  final String id;
  final String name;
  final String description;
  final double unitPrice;
  final String imageUrl;
  int quantity;
  SelectionItem({
    required this.id,
    required this.name,
    required this.description,
    required this.unitPrice,
    required this.imageUrl,
    required this.quantity,
  });
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final List<SelectionItem> _items = [
    SelectionItem(
      id: 'fries',
      name: 'Truffle Fries',
      description: 'Large size with garlic aioli',
      unitPrice: 12.00,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDdkzjMAvBHCfwRW6c8Z0PRDiECvHocxOxi_c7mQzkbyM1Hp8Bjalia5vtRppGwuanih6Mc5VELW-QN9xOnl9iZI4lEsCix4MECxUPaxKGCLxtBTavse6JuRJKa2dL0FWuckkntr-4Con3ZglO0mYRyoULvbFYX9AN3pksQS9WQi0YOnB0mh2G5VSG9hAjK1dIw6l7qPd-LrAu7mouA66Egm5dgQ7dyc1rh4WwFdGfb3nbwpL-SxRZ-TQbyfd3IQwV-cSY5SbCWmz16',
      quantity: 1,
    ),
    SelectionItem(
      id: 'burger_combo',
      name: 'Beef Burger Combo',
      description: 'Includes drink and sides',
      unitPrice: 13.00,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDBn2CcBKm9v3EMYD765j4K_BUS5odWdUdF-SNaW7KJa4OoU0He3o-A1x90LLNn6hUurctOhgnx1OdWBvbV4rRjQk256pVUGKYSuijyu0-MgnQa1eC6jTpmSqdkHxu6fWoQmUggA6vv6A6klfgiWmUkYXRKX-UH8wyGFGf3jqIz8Z_DvCSvJdl353AOFcBpeyZ7V6gPKxhy36BLB805UKKTFq8igR8IqZfGog0lDqWE6myfkMFUyHKiXw1zHAb__pLHOIS4YA1LAD1z',
      quantity: 2,
    ),
  ];

  static const double _discountRate = 0.25;
  static const double _freeItemTarget = 40.00;
  int _navIndex = 2;

  double get _subtotal =>
      _items.fold(0, (sum, item) => sum + item.unitPrice * item.quantity);
  double get _discount => _subtotal * _discountRate;
  double get _totalPayable => _subtotal - _discount;
  double get _amountToFreeItem =>
      (_freeItemTarget - _totalPayable).clamp(0, _freeItemTarget);
  double get _progress => (_totalPayable / _freeItemTarget).clamp(0, 1);

  void _increment(SelectionItem item) => setState(() => item.quantity++);
  void _decrement(SelectionItem item) => setState(() {
    if (item.quantity > 1) item.quantity--;
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(isDark: isDark),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                children: [
                  for (final item in _items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _SelectionItemCard(
                        item: item,
                        isDark: isDark,
                        onIncrement: () => _increment(item),
                        onDecrement: () => _decrement(item),
                      ),
                    ),
                  _AddMoreItemsButton(isDark: isDark),
                  const SizedBox(height: 24),
                  _RewardsProgressCard(
                    isDark: isDark,
                    amountToFreeItem: _amountToFreeItem,
                    progress: _progress,
                  ),
                  const SizedBox(height: 16),
                  _PriceBreakdownCard(
                    isDark: isDark,
                    subtotal: _subtotal,
                    discount: _discount,
                    total: _totalPayable,
                  ),
                  const SizedBox(height: 16),
                  _GenerateQrButton(isDark: isDark),
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
/// Sticky header
/// ---------------------------------------------------------------------
class _Header extends StatelessWidget {
  final bool isDark;
  const _Header({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            (isDark
                    ? CheckoutColors.backgroundDark
                    : CheckoutColors.backgroundLight)
                .withOpacity(0.95),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
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
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Your Selection',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
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
  final SelectionItem item;
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
    final lineTotal = item.unitPrice * item.quantity;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100]!,
        ),
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: Colors.black12,
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
            child: Image.network(
              item.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
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
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12, top: 2),
                  child: Text(
                    item.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${lineTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: CheckoutColors.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey[100],
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
                                color: isDark ? Colors.white : Colors.black,
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
              ? CheckoutColors.primary
              : (isDark ? Colors.white.withOpacity(0.2) : Colors.white),
          boxShadow: filled
              ? null
              : const [BoxShadow(color: Colors.black12, blurRadius: 2)],
        ),
        child: Icon(
          icon,
          size: 16,
          color: filled
              ? Colors.white
              : (isDark ? Colors.white : Colors.black87),
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
  const _AddMoreItemsButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
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
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
              const SizedBox(width: 8),
              Text(
                'Add more items',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple dashed-border container (CustomPaint) approximating the
/// `border-dashed` Tailwind utility used for "Add more items".
class DottedBorderBox extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const DottedBorderBox({super.key, required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: isDark ? Colors.white.withOpacity(0.2) : Colors.grey[300]!,
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
  const _RewardsProgressCard({
    required this.isDark,
    required this.amountToFreeItem,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.card_giftcard,
                color: CheckoutColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey[200] : Colors.grey[700],
                    ),
                    children: [
                      const TextSpan(text: 'Spend '),
                      TextSpan(
                        text: '\$${amountToFreeItem.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: CheckoutColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: ' more to unlock a FREE item!'),
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
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey[200],
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: CheckoutColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: CheckoutColors.primary.withOpacity(0.5),
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
                label: '\$0',
                color: isDark ? Colors.grey[500]! : Colors.grey[400]!,
              ),
              _ProgressMarker(label: 'Cashback', color: CheckoutColors.primary),
              _ProgressMarker(
                label: 'Free Item',
                color: isDark ? Colors.grey[500]! : Colors.grey[400]!,
              ),
            ],
          ),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100]!,
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
                  color: isDark ? Colors.grey[400] : Colors.grey[500],
                ),
              ),
              Text(
                '\$${subtotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black,
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
                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.green.withOpacity(0.2)
                          : Colors.green[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '25% OFF',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.green[300] : Colors.green[700],
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                '-\$${discount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.green[300] : Colors.green[600],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              height: 1,
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200],
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
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CheckoutColors.primary,
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
  const _GenerateQrButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QrScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CheckoutColors.primary,
              foregroundColor: Colors.white,
              elevation: 6,
              shadowColor: CheckoutColors.primary.withOpacity(0.25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_2, size: 22),
                SizedBox(width: 8),
                Text(
                  'Generate QR Code',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Show the QR code at the counter to redeem your offer.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey[500] : Colors.grey[400],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class FoodItemColors {
  static const primary = Color(0xFFEE5B2B);
  static const primaryDeep = Color(0xFFC2410C);
  static const bgLight = Color(0xFFFAFAFC);
  static const bgDark = Color(0xFF1E1714);
  static const cardLight = Colors.white;
  static const cardDark = Color(0xFF281E19);
  static const borderLight = Color(0xFFF0F0F3);
  static const borderDark = Color(0xFF3D2B23);
  static const textMutedDark = Color(0xFFC9A092);
  static const vegGreen = Color(0xFF22C55E);
  static const nonVegRed = Color(0xFFEF4444);
}

class FoodItemPage extends StatefulWidget {
  final String id;
  final String name;
  final String category;
  final double price;
  final double? originalPrice;
  final String description;
  final bool isVeg;
  final bool isSpicy;
  final bool isBestseller;
  final String rating;
  final List<String> photos; // 1-3 photos
  final int initialQuantity;
  final ValueChanged<int>? onQuantityChanged;

  const FoodItemPage({
    super.key,
    this.id = 'item_1',
    required this.name,
    required this.category,
    required this.price,
    this.originalPrice,
    required this.description,
    this.isVeg = true,
    this.isSpicy = false,
    this.isBestseller = false,
    this.rating = '4.8',
    required this.photos,
    this.initialQuantity = 1,
    this.onQuantityChanged,
  });

  @override
  State<FoodItemPage> createState() => _FoodItemPageState();
}

class _FoodItemPageState extends State<FoodItemPage> {
  late final PageController _photoPageController;
  int _activePhotoIndex = 0;
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _photoPageController = PageController();
    _quantity = widget.initialQuantity > 0 ? widget.initialQuantity : 1;
  }

  @override
  void dispose() {
    _photoPageController.dispose();
    super.dispose();
  }

  void _increment() {
    setState(() => _quantity++);
    widget.onQuantityChanged?.call(_quantity);
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() => _quantity--);
      widget.onQuantityChanged?.call(_quantity);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? FoodItemColors.bgDark : FoodItemColors.bgLight;
    final cardBg = isDark ? FoodItemColors.cardDark : FoodItemColors.cardLight;
    final cardBorder = isDark ? FoodItemColors.borderDark : FoodItemColors.borderLight;
    final textColor = isDark ? Colors.white : const Color(0xFF1D1E20);
    final subColor = isDark ? FoodItemColors.textMutedDark : Colors.grey[600]!;

    // Ensure 1-3 photos available
    final displayPhotos = widget.photos.isNotEmpty ? widget.photos.take(3).toList() : [
      'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600',
    ];

    final totalPrice = widget.price * _quantity;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Main Scrollable Body
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1-3 Photos Carousel Hero Section
                Stack(
                  children: [
                    SizedBox(
                      height: 320,
                      child: PageView.builder(
                        controller: _photoPageController,
                        itemCount: displayPhotos.length,
                        onPageChanged: (i) => setState(() => _activePhotoIndex = i),
                        itemBuilder: (context, index) {
                          return Image.network(
                            displayPhotos[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (ctx, _, __) => Container(
                              color: isDark ? FoodItemColors.cardDark : Colors.grey[300],
                              child: const Icon(Icons.fastfood_rounded, size: 60, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                    // Gradient overlay at top for back button visibility
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                    // Top Bar (Back button + Favorite icon)
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _CircularButton(
                            icon: Icons.chevron_left_rounded,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                          _CircularButton(
                            icon: Icons.favorite_border_rounded,
                            onTap: () {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Added "${widget.name}" to wishlist!'),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // Photo Indicator Badge / Dots (If > 1 photo)
                    if (displayPhotos.length > 1)
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_activePhotoIndex + 1} / ${displayPhotos.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                // Item Details Body Container
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Tag + Dietary Type (Veg / Non-Veg) Row
                      Row(
                        children: [
                          // Dietary Type Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: widget.isVeg
                                  ? FoodItemColors.vegGreen.withValues(alpha: 0.12)
                                  : FoodItemColors.nonVegRed.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: widget.isVeg ? FoodItemColors.vegGreen : FoodItemColors.nonVegRed,
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: widget.isVeg ? FoodItemColors.vegGreen : FoodItemColors.nonVegRed,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.isVeg ? 'VEG' : 'NON-VEG',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: widget.isVeg ? FoodItemColors.vegGreen : FoodItemColors.nonVegRed,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Category Chip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : const Color(0xFFF0F0F3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.category.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: subColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          if (widget.isBestseller) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: FoodItemColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '★ BESTSELLER',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: FoodItemColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Food Item Name
                      Text(
                        widget.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Rating & Delivery Time Row
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            widget.rating,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text('•', style: TextStyle(color: subColor)),
                          const SizedBox(width: 12),
                          Icon(Icons.timer_outlined, size: 15, color: subColor),
                          const SizedBox(width: 4),
                          Text(
                            '15-25 min prep',
                            style: TextStyle(fontSize: 12.5, color: subColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Price Section
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '\$${widget.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: FoodItemColors.primary,
                            ),
                          ),
                          if (widget.originalPrice != null && widget.originalPrice! > widget.price) ...[
                            const SizedBox(width: 10),
                            Text(
                              '\$${widget.originalPrice!.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                color: subColor,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Small Description Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: cardBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.description.isNotEmpty
                                  ? widget.description
                                  : 'Deliciously crafted with premium fresh ingredients, authentic spices, and prepared fresh upon order.',
                              style: TextStyle(
                                fontSize: 13,
                                color: subColor,
                                height: 1.5,
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

          // Bottom Fixed Action Bar (Quantity Stepper + Add to Cart Button)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              decoration: BoxDecoration(
                color: cardBg,
                border: Border(top: BorderSide(color: cardBorder, width: 1)),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Quantity Stepper (- 1 +)
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : const Color(0xFFF0F0F3),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          color: textColor,
                          onPressed: _decrement,
                        ),
                        Text(
                          '$_quantity',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          color: FoodItemColors.primary,
                          onPressed: _increment,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Add to Cart Button
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FoodItemColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added $_quantity x "${widget.name}" to cart!'),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'ADD TO CART • \$${totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircularButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 24),
        onPressed: onTap,
      ),
    );
  }
}

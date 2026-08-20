import 'package:flutter/material.dart';

class DealColors {
  static const primary = Color(0xFFEE5B2B);
  static const bgLight = Color(0xFFFAFAFC);
  static const bgDark = Color(0xFF1E1714);
  static const cardDark = Color(0xFF281E19);
  static const borderDark = Color(0xFF3D2B23);
  static const mutedTextDark = Color(0xFFC9A092);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    fontFamily: 'PlusJakartaSans',
    scaffoldBackgroundColor: bgLight,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
  );
}

/// ---------------------------------------------------------------------
/// Data models
/// ---------------------------------------------------------------------
class AddOn {
  final String name;
  final String price;
  final String imageUrl;
  const AddOn({
    required this.name,
    required this.price,
    required this.imageUrl,
  });
}

const _heroImageUrl =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBJSMfmwvvapG0ZHxYVePZV8uQK-WLKaOEBlNU9foogkBwzEY19ieziXMxOYMCX9IYuRqVLhcqWCTifN7QdZEEqEN8lDswHzWTC85QA716MmM_ZSZMnzW02rcdwwDJooMYoPnPnf3aPk-VikoWOdXQ20ZaHpC25Efb0cY9Ny4akg6_z0o_MckdyPF8P-9Pc5aqeflowj9BIXYHyx56_gOS9liUE9vu4vySXUoDz4bJZ3C_YHKPo8OqOLiFZ4ZtqCMc5fqX9v0UzPaKn';

const _addOns = [
  AddOn(
    name: 'Choco Lava Cake',
    price: '\$4.50',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBAGsiyOHEL9kzjdjLoPc_QluAtwODZqKLl4liX7Tv9-sS9XGsXOag1KuSG6zVWs1IeLvDfstM_7RExP1iHzVJ8RooE0bamngjI2G4FChCCwuKK55oMherhSS57eg8e-F2YM0v5zqITcDBcoEWQ_3EfufJIApRPVW7kEIkxb_mu-r5lvi4Rmrowc5_-QylgdHXPOzvfD0iFNCKLgPGry9UpIv8ymKw-fT_xognstAJYIk6gBISlMIVDptbqXIm96q1fiG72X1onNdRr',
  ),
  AddOn(
    name: 'Greek Salad',
    price: '\$6.00',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDmClsr1hF4KsV4W4twDAfsFrWFXTZ31Bxa7mfVfdUCs0mpEoYIEGCv2siSmQFAA152guFfymwnrdoD73-596E3g5ET8A_s3XsiWekws1PKpXu_IHHvfZgnoUZ_4BTvWRzK67yL2dYdaMZb-6JBAwZ4C_T0P7igosFRYybg9KUw_ce7vp3t_CwCBvgpGrpxBt2Eo9OFJJhmApuotN-C6r7ROpiEJzn8l2rrqapZchT_5Az54C7O7VGBsJUSlbkVLlf5DZx_ThzSrlpa',
  ),
];

/// ---------------------------------------------------------------------
/// Main screen
/// ---------------------------------------------------------------------
class FoodDetailsScreen extends StatelessWidget {
  const FoodDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? DealColors.bgDark : DealColors.bgLight;

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroImage(isDark: isDark),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TitleRow(isDark: isDark),
                      const SizedBox(height: 28),
                      _WhatYouGet(isDark: isDark),
                      const SizedBox(height: 28),
                      _FinePrint(isDark: isDark),
                      const SizedBox(height: 32),
                      _RecommendedAddOns(isDark: isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Fixed top action buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _RoundIconButton(
                  icon: Icons.chevron_left_rounded,
                  size: 26,
                  isDark: isDark,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                Row(
                  children: [
                    _RoundIconButton(
                      icon: Icons.favorite_border_rounded,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 10),
                    _RoundIconButton(icon: Icons.share_rounded, isDark: isDark),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _AddToCartBar(isDark: isDark),
    );
  }
}

/// ---------------------------------------------------------------------
/// Fixed top round icon buttons (back / favorite / share)
/// ---------------------------------------------------------------------
class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final bool isDark;
  final VoidCallback? onTap;

  const _RoundIconButton({
    required this.icon,
    required this.isDark,
    this.size = 22,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark
              ? Colors.black.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.9),
          border: Border.all(
            color: isDark ? const Color(0xFF3B2921) : const Color(0xFFEEEEEE),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white : const Color(0xFF1D1E20),
          size: size,
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Hero image with gradient overlay + HOT DEAL / timer badges
/// ---------------------------------------------------------------------
class _HeroImage extends StatelessWidget {
  final bool isDark;
  const _HeroImage({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? DealColors.bgDark : DealColors.bgLight;

    return SizedBox(
      width: double.infinity,
      height: 280,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(_heroImageUrl, fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  bgColor,
                  bgColor.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 20,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: DealColors.primary,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: DealColors.primary.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'HOT DEAL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.2)
                          : const Color(0xFFEEEEEE),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        color: DealColors.primary,
                        size: 15,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '1h 45m left',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1D1E20),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
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
    );
  }
}

/// ---------------------------------------------------------------------
/// Title & restaurant/distance line
/// ---------------------------------------------------------------------
class _TitleRow extends StatelessWidget {
  final bool isDark;
  const _TitleRow({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cheesy Delight Pizza',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1D1E20),
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              'Pizza Hut',
              style: TextStyle(
                color: isDark ? DealColors.mutedTextDark : Colors.grey[700],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.white30 : Colors.grey[400],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.near_me_outlined,
              size: 15,
              color: isDark ? DealColors.mutedTextDark : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              '1.2 km away',
              style: TextStyle(
                color: isDark ? DealColors.mutedTextDark : Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------
/// "What you get" description + checklist
/// ---------------------------------------------------------------------
class _WhatYouGet extends StatelessWidget {
  final bool isDark;
  const _WhatYouGet({required this.isDark});

  @override
  Widget build(BuildContext context) {
    const items = [
      '1x Large Signature Cheesy Pizza',
      'Free Garlic Dipping Sauce',
      '2x 330ml Soft Drinks of your choice',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What you get',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1D1E20),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Enjoy our signature large thin-crust pizza topped with premium mozzarella, aged parmesan, and our secret herb-infused tomato sauce. Perfect for sharing or a serious solo treat.',
          style: TextStyle(
            color: isDark ? DealColors.mutedTextDark : Colors.grey[600],
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        ...items.map(
          (text) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: DealColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isDark
                          ? Colors.grey[200]
                          : const Color(0xFF2D2D2D),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------
/// Fine print / terms box
/// ---------------------------------------------------------------------
class _FinePrint extends StatelessWidget {
  final bool isDark;
  const _FinePrint({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? DealColors.cardDark : Colors.white;
    final borderColor = isDark
        ? DealColors.borderDark
        : const Color(0xFFF0F0F3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FINE PRINT & TERMS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isDark ? DealColors.mutedTextDark : Colors.grey[500],
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            'Valid for dine-in or pickup only. Offer must be claimed through the ZTEEEL app. Limit 1 per customer. Redemption valid for 24 hours after claim.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? DealColors.mutedTextDark : Colors.grey[600],
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------
/// Recommended add-ons horizontal scroll
/// ---------------------------------------------------------------------
class _RecommendedAddOns extends StatelessWidget {
  final bool isDark;
  const _RecommendedAddOns({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended Add-ons',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1D1E20),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 215,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _addOns.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) =>
                _AddOnCard(addOn: _addOns[i], isDark: isDark),
          ),
        ),
      ],
    );
  }
}

class _AddOnCard extends StatelessWidget {
  final AddOn addOn;
  final bool isDark;
  const _AddOnCard({required this.addOn, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? DealColors.cardDark : Colors.white;
    final borderColor = isDark
        ? DealColors.borderDark
        : const Color(0xFFF0F0F3);

    return Container(
      width: 144,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(addOn.imageUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            addOn.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1D1E20),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            addOn.price,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: DealColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Fixed bottom bar: Total + Add to Cart / Claim Deal
/// ---------------------------------------------------------------------
class _AddToCartBar extends StatelessWidget {
  final bool isDark;
  const _AddToCartBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final barBg = isDark ? DealColors.bgDark : Colors.white;
    final borderTopColor = isDark
        ? DealColors.borderDark
        : const Color(0xFFF0F0F3);

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: barBg,
        border: Border(top: BorderSide(color: borderTopColor, width: 1)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'TOTAL PRICE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDark ? DealColors.mutedTextDark : Colors.grey[500],
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '\$12.50',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1D1E20),
                ),
              ),
            ],
          ),
          SizedBox(
            width: 170,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.white,
                size: 20,
              ),
              label: const Text(
                'Claim Deal',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: DealColors.primary,
                elevation: 4,
                shadowColor: DealColors.primary.withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'FoodDetailScreen.dart';

/// Shared color tokens (same as dashboard AppColorss)
class _DealsColors {
  static const primary = Color(0xFFEE5B2B);
}

/// Deal data model
class Deal {
  final String title;
  final String restaurant;
  final String distance;
  final String discount;
  final String timeLeft;
  final String imageUrl;
  const Deal({
    required this.title,
    required this.restaurant,
    required this.distance,
    required this.discount,
    required this.timeLeft,
    required this.imageUrl,
  });
}

/// Sample deals data
const deals = [
  Deal(
    title: 'Cheesy Delight Pizza',
    restaurant: 'Pizza Hut',
    distance: '1.2km away',
    discount: '20% OFF',
    timeLeft: '2h left',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBJSMfmwvvapG0ZHxYVePZV8uQK-WLKaOEBlNU9foogkBwzEY19ieziXMxOYMCX9IYuRqVLhcqWCTifN7QdZEEqEN8lDswHzWTC85QA716MmM_ZSZMnzW02rcdwwDJooMYoPnPnf3aPk-VikoWOdXQ20ZaHpC25Efb0cY9Ny4akg6_z0o_MckdyPF8P-9Pc5aqeflowj9BIXYHyx56_gOS9liUE9vu4vySXUoDz4bJZ3C_YHKPo8OqOLiFZ4ZtqCMc5fqX9v0UzPaKn',
  ),
  Deal(
    title: 'Double Beef Smash',
    restaurant: 'Burger King',
    distance: '0.8km away',
    discount: '50% OFF',
    timeLeft: '45m left',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAQajB08E40GIXc8XWyyyJMRfiC-vn1pldnjNsBeT4QKpDSVuRPNQiF_8Xk7LRwrIYXJxmOvomxzJt0g1Mb_vFTw03CabQfXbrnowLWkLGvTcQApK-VYIWfGXD-eU6-Mr2ZxcrCB1y52q3uNdCnHoOtbB4c0y3OXzn8IKuMQUNSr1UiZok0k27xh3YuHhZJLw9l1ZPXTbm4vGTIpX6ZbJuOTXN3CMD3aNLeddYUY_4mTJJjgQW83l3ZJlgse1qM9CR25MIsOBKXjG7p',
  ),
  Deal(
    title: 'Morning Berry Bowl',
    restaurant: 'Fresh & Green',
    distance: '2.5km away',
    discount: '15% OFF',
    timeLeft: '5h left',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuD4yhPin6dzd-0bzsMiqqxvvUt4eAfu6HTxkb3DYB2THXb5sagbjYSFDbkvCxjzxusQ5dWZfaRvXoq8qyJ8ACdiGbOtBoi4StQfmdpWtxfMDDOKxb_FfqRgdCmcx7tEt6Jg4w6nZRHbKit8KD9do6rpyv5ztqJla4UiiAJPNjRWxApaV0lYy8kQYFKgSmBBeW6U6yndkJdUiE4s9N6gPfR91oID-PtuospqsPqEOBlETl8irRRgka1_hH9yTIY8UvuntkKdc5zVoqO7',
  ),
];

/// ─────────────────────────────────────────────────────────────────────
/// DealsScreen — full-page view of all active deals.
/// Can be used as a standalone pushed screen OR embedded in the
/// dashboard's IndexedStack as the Deals tab (index 1).
/// ─────────────────────────────────────────────────────────────────────
class DealsScreen extends StatelessWidget {
  final bool isDark;
  const DealsScreen({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exclusive Deals 🔥',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: isDark ? Colors.white : const Color(0xFF1D1E20),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _DealsColors.primary.withAlpha(isDark ? 35 : 20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${deals.length} Active',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _DealsColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              itemCount: deals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, i) {
                final deal = deals[i];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FoodDetailsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(35),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(deal.imageUrl, fit: BoxFit.cover),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withAlpha(220),
                                  Colors.black.withAlpha(100),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.55, 1.0],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 14,
                            left: 14,
                            child: DealBadge(text: deal.discount, filled: true),
                          ),
                          Positioned(
                            top: 14,
                            right: 14,
                            child: DealBadge(
                              text: deal.timeLeft,
                              filled: false,
                              icon: Icons.timer_outlined,
                            ),
                          ),
                          Positioned(
                            bottom: 14,
                            left: 14,
                            right: 14,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  deal.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${deal.restaurant} • ${deal.distance}',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(210),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
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
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────
/// DealBadge — reusable pill badge for deal cards (discount / timer).
/// Used by both DealsScreen and the HotDealsRow on the dashboard.
/// ─────────────────────────────────────────────────────────────────────
class DealBadge extends StatelessWidget {
  final String text;
  final bool filled;
  final IconData? icon;
  const DealBadge({
    super.key,
    required this.text,
    required this.filled,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? _DealsColors.primary : Colors.black.withAlpha(120),
        borderRadius: BorderRadius.circular(8),
        border: filled
            ? null
            : Border.all(color: Colors.white.withAlpha(50), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────
/// HotDealsRow — horizontal scroll preview used on the dashboard home.
/// Extracted here so both dashboard and DealsScreen share the same
/// Deal model and data.
/// ─────────────────────────────────────────────────────────────────────
class HotDealsRow extends StatelessWidget {
  const HotDealsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 196,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: deals.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) => _DealCard(deal: deals[i]),
      ),
    );
  }
}

class _DealCard extends StatelessWidget {
  final Deal deal;
  const _DealCard({required this.deal});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const FoodDetailsScreen()));
      },
      child: Container(
        width: 285,
        height: 196,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(deal.imageUrl, fit: BoxFit.cover),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withAlpha(220),
                      Colors.black.withAlpha(100),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
              Positioned(
                top: 14,
                left: 14,
                child: DealBadge(text: deal.discount, filled: true),
              ),
              Positioned(
                top: 14,
                right: 14,
                child: DealBadge(
                  text: deal.timeLeft,
                  filled: false,
                  icon: Icons.timer_outlined,
                ),
              ),
              Positioned(
                bottom: 14,
                left: 14,
                right: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      deal.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        letterSpacing: -0.3,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${deal.restaurant} • ${deal.distance}',
                      style: TextStyle(
                        color: Colors.white.withAlpha(210),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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

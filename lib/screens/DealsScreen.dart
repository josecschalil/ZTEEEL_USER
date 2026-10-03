import 'package:flutter/material.dart';
import 'FoodDetailScreen.dart';
import '../config/api_config.dart';
import '../services/offer_service.dart';
import 'dart:async';

/// Shared color tokens (same as dashboard AppColorss)
class _DealsColors {
  static const primary = Color(0xFFEE5B2B);
}

/// Deal data model
class Deal {
  final String? vendorId;
  final String title;
  final String restaurant;
  final String distance;
  final String discount;
  final String timeLeft;
  final String imageUrl;
  const Deal({
    this.vendorId,
    required this.title,
    required this.restaurant,
    required this.distance,
    required this.discount,
    required this.timeLeft,
    required this.imageUrl,
  });
}

Future<List<Deal>> dealsFromOffers(List<Map<String, dynamic>> offers) async {
  final vendors = <String, Future<Map<String, dynamic>?>>{};
  final menus = <String, Future<List<Map<String, dynamic>>>>{};
  final hydrated = await Future.wait(
    offers.asMap().entries.map((entry) async {
      final offer = entry.value;
      final fallback = deals[entry.key % deals.length];
      final vendorId = offer['vendor']?.toString() ?? '';
      if (vendorId.isEmpty) return fallback;
      final vendor = await vendors.putIfAbsent(
        vendorId,
        () => OfferService.fetchVendor(vendorId),
      );
      final menu = await menus.putIfAbsent(
        vendorId,
        () => OfferService.fetchVendorMenu(vendorId),
      );
      final discount = double.tryParse(
        offer['discount_percentage']?.toString() ?? '',
      );
      return Deal(
        vendorId: vendorId.isEmpty ? null : vendorId,
        title: _offerText(offer['title'], fallback.title),
        restaurant: _offerText(vendor?['business_name'], fallback.restaurant),
        distance: fallback.distance,
        discount: discount == null
            ? fallback.discount
            : '${discount.toStringAsFixed(discount % 1 == 0 ? 0 : 1)}% OFF',
        timeLeft: _offerTimeLeft(offer['ends_at']) ?? fallback.timeLeft,
        imageUrl: _offerImage(offer, menu) ?? fallback.imageUrl,
      );
    }),
  );
  return hydrated;
}

String _offerText(Object? value, String fallback) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

String? _offerImage(
  Map<String, dynamic> offer,
  List<Map<String, dynamic>> menu,
) {
  final targets = offer['targets'];
  final itemIds = targets is Map ? targets['item_ids'] : null;
  final categoryIds = targets is Map ? targets['category_ids'] : null;
  for (final category in menu) {
    final categoryMatches =
        categoryIds is List && categoryIds.contains(category['id']?.toString());
    final items = category['menu_items'];
    if (items is! List) continue;
    for (final item in items.whereType<Map>()) {
      final matches =
          categoryMatches ||
          (itemIds is List && itemIds.contains(item['id']?.toString())) ||
          (itemIds is! List && categoryIds is! List);
      if (!matches) continue;
      final image = item['image']?.toString() ?? '';
      if (image.isEmpty) continue;
      return image.startsWith('http')
          ? image
          : '${ApiConfig.baseUrl}${image.startsWith('/') ? '' : '/'}$image';
    }
  }
  return null;
}

List<Deal> dashboardDeals(List<Deal> liveDeals) {
  if (liveDeals.length >= 3) return liveDeals.take(3).toList();
  return [...liveDeals, ...deals.skip(liveDeals.length)].take(3).toList();
}

String? _offerTimeLeft(Object? value) {
  final end = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
  if (end == null) return null;
  final difference = end.difference(DateTime.now());
  if (difference.isNegative) return 'Ending soon';
  if (difference.inDays > 0) return '${difference.inDays}d left';
  if (difference.inHours > 0) return '${difference.inHours}h left';
  return '${difference.inMinutes.clamp(1, 59)}m left';
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
// ─────────────────────────────────────────────────────────────────────
// REPLACEMENT for HotDealsRow and _FeaturedDealCard in DealsScreen.dart
// Drop these two classes in place of the old ones. Everything else
// (Deal model, DealsScreen, DealBadge, etc.) stays exactly the same.
// ─────────────────────────────────────────────────────────────────────

/// HotDealsRow — auto-advancing, non-swipeable featured deal carousel.
/// Cards transition in place inside a fixed-size container (fade + soft
/// scale), with a small page indicator overlaid in the card's
/// bottom-right corner instead of a separate dot row underneath.
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

  void _goTo(int index) {
    setState(() => _activeIndex = index);
    _startAutoPlay(); // reset the clock so it doesn't jump right after a tap
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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 550),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final fade = animation;
            final scale = Tween<double>(begin: 0.97, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );
            return FadeTransition(
              opacity: fade,
              child: ScaleTransition(scale: scale, child: child),
            );
          },
          layoutBuilder: (currentChild, previousChildren) => Stack(
            fit: StackFit.expand,
            children: [
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          ),
          child: _FeaturedDealCard(
            key: ValueKey(index),
            deal: featuredDeals[index],
            pageCount: featuredDeals.length,
            activeIndex: index,
            onDotTap: _goTo,
          ),
        ),
      ),
    );
  }
}

class _FeaturedDealCard extends StatelessWidget {
  final Deal deal;
  final int pageCount;
  final int activeIndex;
  final ValueChanged<int>? onDotTap;
  const _FeaturedDealCard({
    super.key,
    required this.deal,
    this.pageCount = 1,
    this.activeIndex = 0,
    this.onDotTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const FoodDetailsScreen()));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(45),
              blurRadius: 20,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
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
                      Colors.black.withAlpha(238),
                      Colors.black.withAlpha(150),
                      Colors.black.withAlpha(18),
                    ],
                    stops: const [0.0, 0.58, 1.0],
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Text(
                  deal.discount,
                  style: const TextStyle(
                    color: _DealsColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Text(
                  deal.timeLeft,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              Positioned(
                bottom: 18,
                left: 18,
                right: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'LIMITED-TIME OFFER',
                      style: TextStyle(
                        color: Colors.white.withAlpha(210),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deal.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            '${deal.restaurant} • ${deal.distance}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withAlpha(215),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (pageCount > 1) ...[
                              const SizedBox(height: 8),
                              _CornerPageDots(
                                count: pageCount,
                                activeIndex: activeIndex,
                                onDotTap: onDotTap,
                              ),
                            ],
                          ],
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

/// Tiny page-indicator dots meant to sit in a card's bottom-right corner.
class _CornerPageDots extends StatelessWidget {
  final int count;
  final int activeIndex;
  final ValueChanged<int>? onDotTap;
  const _CornerPageDots({
    required this.count,
    required this.activeIndex,
    this.onDotTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final active = i == activeIndex;
        return GestureDetector(
          onTap: onDotTap == null ? null : () => onDotTap!(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            margin: const EdgeInsets.only(left: 4),
            width: active ? 14 : 5,
            height: 5,
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.white.withAlpha(110),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}

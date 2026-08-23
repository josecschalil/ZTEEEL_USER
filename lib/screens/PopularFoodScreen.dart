// ---------------------------------------------------------------------
// POPULAR FOOD ITEMS SCREEN
// ---------------------------------------------------------------------
// Opens when the user taps "See All" on the dashboard's Popular Food
// Items section. Shows food *categories* (Pizza, Burger, Sushi, ...)
// ranked by popularity, laid out as an editorial-style masonry collage
// with a large featured hero tile up top — deliberately not a uniform
// grid of identical cards, so it reads as curated rather than generic.
//
// Tapping a tile is meant to push FoodTypeShopsScreen(foodType: ...)
// (the "shops selling this category" screen built earlier).
//
// Usage:
// Navigator.push(context, MaterialPageRoute(
//   builder: (_) => PopularFoodItemsScreen(
//     items: myRealPopularItems, // omit to preview with sample data
//     onItemSelected: (item) => Navigator.push(context, MaterialPageRoute(
//       builder: (_) => FoodTypeShopsScreen(foodType: item.name),
//     )),
//   ),
// ));
// ---------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'FoodTypeShopScreen.dart';

/// ---------------------------------------------------------------------
/// Shared palette (identical to the rest of the app)
/// ---------------------------------------------------------------------
class AppColors {
  static const primary = Color(0xFFEE5B2B);
  static const primarySoft = Color(0xFFFDECE4);
  static const backgroundLight = Color(0xFFF8F6F6);
  static const cardLight = Colors.white;
  static const borderLight = Color(0xFFE2E8F0);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textMuted = Color(0xFF94A3B8);
  static const success = Color(0xFF16A34A);
}

/// ---------------------------------------------------------------------
/// Model
/// ---------------------------------------------------------------------
class PopularFoodItem {
  final String id;
  final String name;
  final String? imageUrl;
  final IconData fallbackIcon;
  final double rating;
  final String orderCountLabel; // e.g. "12.4k"
  final bool isTrending;
  final bool isNew;

  const PopularFoodItem({
    required this.id,
    required this.name,
    required this.fallbackIcon,
    required this.rating,
    required this.orderCountLabel,
    this.imageUrl,
    this.isTrending = false,
    this.isNew = false,
  });
}

enum _QuickFilter { all, trending, topRated, newIn }

extension on _QuickFilter {
  String get label {
    switch (this) {
      case _QuickFilter.all:
        return 'All';
      case _QuickFilter.trending:
        return 'Trending now';
      case _QuickFilter.topRated:
        return 'Top rated';
      case _QuickFilter.newIn:
        return 'New in';
    }
  }
}

/// ---------------------------------------------------------------------
/// Screen
/// ---------------------------------------------------------------------
class PopularFoodItemsScreen extends StatefulWidget {
  final List<PopularFoodItem>? items;
  final ValueChanged<PopularFoodItem>? onItemSelected;

  const PopularFoodItemsScreen({super.key, this.items, this.onItemSelected});

  @override
  State<PopularFoodItemsScreen> createState() => _PopularFoodItemsScreenState();
}

typedef PopularFoodScreen = PopularFoodItemsScreen;

class _PopularFoodItemsScreenState extends State<PopularFoodItemsScreen> {
  late final List<PopularFoodItem> _all;
  _QuickFilter _filter = _QuickFilter.all;

  @override
  void initState() {
    super.initState();
    _all = widget.items ?? _sampleItems();
  }

  List<PopularFoodItem> get _filtered {
    switch (_filter) {
      case _QuickFilter.all:
        return _all;
      case _QuickFilter.trending:
        return _all.where((i) => i.isTrending).toList();
      case _QuickFilter.topRated:
        return [..._all]..sort((a, b) => b.rating.compareTo(a.rating));
      case _QuickFilter.newIn:
        return _all.where((i) => i.isNew).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;
    final featured = results.isNotEmpty ? results.first : null;
    final rest = results.length > 1 ? results.sublist(1) : <PopularFoodItem>[];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onBack: () => Navigator.of(context).maybePop()),
            _FilterRow(
              active: _filter,
              onSelected: (f) => setState(() => _filter = f),
            ),
            Expanded(
              child: results.isEmpty
                  ? const _EmptyState()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (featured != null) ...[
                            _FeaturedTile(
                              item: featured,
                              rank: 1,
                              onTap: () {
                                widget.onItemSelected?.call(featured);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FoodTypeShopsScreen(
                                      foodType: featured.name,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (rest.isNotEmpty)
                            _MasonryGrid(
                              items: rest,
                              rankOffset: 2,
                              onTapItem: (item) {
                                widget.onItemSelected?.call(item);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FoodTypeShopsScreen(
                                      foodType: item.name,
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Header
/// ---------------------------------------------------------------------
class _Header extends StatelessWidget {
  final VoidCallback onBack;
  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardLight,
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 14),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Popular Food Items',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ranked by what people are ordering this week',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
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
/// Filter chip row
/// ---------------------------------------------------------------------
class _FilterRow extends StatelessWidget {
  final _QuickFilter active;
  final ValueChanged<_QuickFilter> onSelected;
  const _FilterRow({required this.active, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardLight,
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _QuickFilter.values.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final f = _QuickFilter.values[i];
            final isActive = f == active;
            return InkWell(
              onTap: () => onSelected(f),
              borderRadius: BorderRadius.circular(999),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.borderLight,
                  ),
                ),
                child: Text(
                  f.label,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Featured hero tile — the #1 item, shown large and full-width
/// ---------------------------------------------------------------------
class _FeaturedTile extends StatelessWidget {
  final PopularFoodItem item;
  final int rank;
  final VoidCallback onTap;

  const _FeaturedTile({
    required this.item,
    required this.rank,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _ImageFrame(
      height: 220,
      borderRadius: 24,
      imageUrl: item.imageUrl,
      fallbackIcon: item.fallbackIcon,
      onTap: onTap,
      overlayChild: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '#$rank Most Ordered This Week',
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _StatPill(
                      icon: Icons.star_rounded,
                      iconColor: AppColors.primary,
                      label: item.rating.toStringAsFixed(1),
                    ),
                    const SizedBox(width: 8),
                    _StatPill(
                      icon: Icons.trending_up_rounded,
                      iconColor: Colors.white,
                      label: '${item.orderCountLabel} orders this week',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  const _StatPill({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Masonry-style grid for everything after the featured tile — two
/// columns with alternating tile heights, greedily packed so the
/// columns stay visually balanced (magazine collage, not a plain grid).
/// ---------------------------------------------------------------------
class _MasonryGrid extends StatelessWidget {
  final List<PopularFoodItem> items;
  final int rankOffset;
  final ValueChanged<PopularFoodItem> onTapItem;

  const _MasonryGrid({
    required this.items,
    required this.rankOffset,
    required this.onTapItem,
  });

  static const double _spacing = 12;
  static const List<double> _heightPattern = [200, 150, 150, 200];

  @override
  Widget build(BuildContext context) {
    final columnHeights = <double>[0, 0];
    final columns = <List<Widget>>[[], []];

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final height = _heightPattern[i % _heightPattern.length];
      final rank = i + rankOffset;

      final target = columnHeights[0] <= columnHeights[1] ? 0 : 1;
      columns[target].add(
        Padding(
          padding: const EdgeInsets.only(bottom: _spacing),
          child: _GridTile(
            item: item,
            rank: rank,
            height: height,
            onTap: () => onTapItem(item),
          ),
        ),
      );
      columnHeights[target] += height + _spacing;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Column(children: columns[0])),
        const SizedBox(width: _spacing),
        Expanded(child: Column(children: columns[1])),
      ],
    );
  }
}

class _GridTile extends StatelessWidget {
  final PopularFoodItem item;
  final int rank;
  final double height;
  final VoidCallback onTap;

  const _GridTile({
    required this.item,
    required this.rank,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _ImageFrame(
      height: height,
      borderRadius: 18,
      imageUrl: item.imageUrl,
      fallbackIcon: item.fallbackIcon,
      onTap: onTap,
      topLeftChild: _RankBadge(rank: rank),
      topRightChild: item.isTrending
          ? Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_fire_department,
                size: 13,
                color: AppColors.primary,
              ),
            )
          : null,
      overlayChild: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.star_rounded, size: 12, color: AppColors.primary),
                const SizedBox(width: 2),
                Text(
                  item.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '· ${item.orderCountLabel} orders',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10.5,
                    color: Colors.white.withOpacity(0.85),
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

class _RankBadge extends StatelessWidget {
  final int rank;
  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    final isTopThree = rank <= 3;
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isTopThree ? AppColors.primary : AppColors.borderLight,
          width: 1.4,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Text(
        '$rank',
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: isTopThree ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Shared image frame: cover image (or icon fallback) + bottom gradient
/// scrim + slots for top-left/top-right badges and a bottom overlay.
/// ---------------------------------------------------------------------
class _ImageFrame extends StatelessWidget {
  final double height;
  final double borderRadius;
  final String? imageUrl;
  final IconData fallbackIcon;
  final VoidCallback onTap;
  final Widget overlayChild;
  final Widget? topLeftChild;
  final Widget? topRightChild;

  const _ImageFrame({
    required this.height,
    required this.borderRadius,
    required this.imageUrl,
    required this.fallbackIcon,
    required this.onTap,
    required this.overlayChild,
    this.topLeftChild,
    this.topRightChild,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                imageUrl != null
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _FallbackBackground(icon: fallbackIcon),
                        loadingBuilder: (context, child, progress) =>
                            progress == null
                            ? child
                            : _FallbackBackground(icon: fallbackIcon),
                      )
                    : _FallbackBackground(icon: fallbackIcon),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.0),
                        Colors.black.withOpacity(0.05),
                        Colors.black.withOpacity(0.78),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
                if (topLeftChild != null)
                  Positioned(top: 10, left: 10, child: topLeftChild!),
                if (topRightChild != null)
                  Positioned(top: 10, right: 10, child: topRightChild!),
                Positioned(left: 0, right: 0, bottom: 0, child: overlayChild),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FallbackBackground extends StatelessWidget {
  final IconData icon;
  const _FallbackBackground({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.textPrimary.withOpacity(0.85),
            AppColors.textPrimary.withOpacity(0.65),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 42, color: Colors.white.withOpacity(0.35)),
    );
  }
}

/// ---------------------------------------------------------------------
/// Empty state
/// ---------------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.backgroundLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_fire_department_outlined,
                size: 28,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nothing trending here yet',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Check back soon or try a different filter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Sample data — used only when no `items` are passed in.
/// ---------------------------------------------------------------------
List<PopularFoodItem> _sampleItems() {
  return const [
    PopularFoodItem(
      id: 'pizza',
      name: 'Pizza',
      imageUrl:
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600&fit=crop',
      fallbackIcon: Icons.local_pizza,
      rating: 4.6,
      orderCountLabel: '12.4k',
      isTrending: true,
    ),
    PopularFoodItem(
      id: 'burger',
      name: 'Burger',
      imageUrl:
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600&fit=crop',
      fallbackIcon: Icons.lunch_dining,
      rating: 4.5,
      orderCountLabel: '9.8k',
      isTrending: true,
    ),
    PopularFoodItem(
      id: 'sushi',
      name: 'Sushi',
      imageUrl:
          'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=600&fit=crop',
      fallbackIcon: Icons.set_meal,
      rating: 4.7,
      orderCountLabel: '6.1k',
      isNew: true,
    ),
    PopularFoodItem(
      id: 'biryani',
      name: 'Biryani',
      imageUrl:
          'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=600&fit=crop',
      fallbackIcon: Icons.rice_bowl,
      rating: 4.4,
      orderCountLabel: '11.2k',
      isTrending: true,
    ),
    PopularFoodItem(
      id: 'pasta',
      name: 'Pasta',
      imageUrl:
          'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=600&fit=crop',
      fallbackIcon: Icons.ramen_dining,
      rating: 4.2,
      orderCountLabel: '5.4k',
    ),
    PopularFoodItem(
      id: 'tacos',
      name: 'Tacos',
      imageUrl:
          'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=600&fit=crop',
      fallbackIcon: Icons.tapas,
      rating: 4.3,
      orderCountLabel: '4.7k',
      isNew: true,
    ),
    PopularFoodItem(
      id: 'momos',
      name: 'Momos',
      imageUrl:
          'https://images.unsplash.com/photo-1534422298391-e4f8c172dddb?w=600&fit=crop',
      fallbackIcon: Icons.dinner_dining,
      rating: 4.5,
      orderCountLabel: '7.9k',
    ),
    PopularFoodItem(
      id: 'salad',
      name: 'Salad Bowls',
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&fit=crop',
      fallbackIcon: Icons.eco,
      rating: 4.1,
      orderCountLabel: '2.9k',
    ),
    PopularFoodItem(
      id: 'waffles',
      name: 'Waffles',
      imageUrl:
          'https://images.unsplash.com/photo-1562376552-0d160a2f238d?w=600&fit=crop',
      fallbackIcon: Icons.bakery_dining,
      rating: 4.6,
      orderCountLabel: '3.6k',
      isNew: true,
    ),
  ];
}

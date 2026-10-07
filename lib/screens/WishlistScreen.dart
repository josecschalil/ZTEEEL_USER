import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_typography.dart';
import '../services/cart_service.dart';
import '../services/wishlist_service.dart';
import 'CheckOutScreen.dart';
import 'FoodItemPage.dart';

// ─── Wishlist / Saved Items Screen ──────────────────────────────────────────
class Wishlistscreen extends StatefulWidget {
  const Wishlistscreen({super.key});

  @override
  State<Wishlistscreen> createState() => _WishlistscreenState();
}

class _WishlistscreenState extends State<Wishlistscreen> {
  String _activeFilter = 'all';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();
  final Set<String> _addingIds = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    if (mounted) setState(() => _isLoading = true);
    await WishlistService.loadWishlist(forceRefresh: forceRefresh);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<WishlistItem> _filterItems(List<WishlistItem> allItems) {
    return allItems.where((d) {
      final itemCategory = d.category.trim().toLowerCase();
      final filter = _activeFilter.trim().toLowerCase();
      final matchCat = filter == 'all' ||
          itemCategory == filter ||
          (filter.isNotEmpty && itemCategory.contains(filter));

      final q = _searchQuery.trim().toLowerCase();
      final matchSearch = q.isEmpty ||
          d.name.toLowerCase().contains(q) ||
          d.restaurant.toLowerCase().contains(q) ||
          d.tag.toLowerCase().contains(q) ||
          itemCategory.contains(q);

      return matchCat && matchSearch;
    }).toList();
  }

  List<(String, String)> _computeCategories(List<WishlistItem> allItems) {
    final catSet = <String>{};
    for (final item in allItems) {
      final c = item.category.trim().toLowerCase();
      if (c.isNotEmpty && c != 'all') {
        catSet.add(c);
      }
    }

    final sortedCats = catSet.toList()..sort();
    return [
      ('all', 'All (${allItems.length})'),
      ...sortedCats.map((c) {
        final count = allItems
            .where((i) => i.category.trim().toLowerCase() == c)
            .length;
        final title = c.length > 1
            ? '${c[0].toUpperCase()}${c.substring(1)}'
            : c.toUpperCase();
        return (c, '$title ($count)');
      }),
    ];
  }

  void _removeItem(WishlistItem item) async {
    await WishlistService.removeFromWishlist(item.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed "${item.name}" from wishlist'),
        backgroundColor: AppColors.textPrimary,
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.primary,
          onPressed: () {
            WishlistService.addToWishlist(item);
          },
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _handleAddToCart(WishlistItem item) async {
    if (_addingIds.contains(item.id)) return;
    setState(() => _addingIds.add(item.id));

    try {
      final res = await CartService.addItem(
        menuItemId: item.id,
        quantity: 1,
        vendorId: item.vendorId,
        vendorName: item.restaurant,
        itemName: item.name,
        unitPrice: item.originalPrice ?? item.price,
        discountedPrice: item.price,
        itemImage: item.imageUrl,
        itemDescription: item.description,
      );

      if (!mounted) return;

      if (res['conflict'] == true) {
        final shouldClear = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Start New Basket?',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            content: const Text(
              'Your cart currently contains items from another restaurant. Would you like to clear your cart and add this dish?',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Start New'),
              ),
            ],
          ),
        );

        if (shouldClear == true) {
          await CartService.clearCart();
          await CartService.addItem(
            menuItemId: item.id,
            quantity: 1,
            vendorId: item.vendorId,
            vendorName: item.restaurant,
            itemName: item.name,
            unitPrice: item.originalPrice ?? item.price,
            discountedPrice: item.price,
            itemImage: item.imageUrl,
            itemDescription: item.description,
          );
        } else {
          return;
        }
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added "${item.name}" to your basket!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to cart: $e'),
            backgroundColor: AppColors.nonVegRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _addingIds.remove(item.id));
      }
    }
  }

  void _openFoodItemDetails(WishlistItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoodItemPage(
          id: item.id,
          vendorId: item.vendorId,
          vendorName: item.restaurant,
          name: item.name,
          category: item.category,
          price: item.price,
          originalPrice: item.originalPrice,
          description: item.description ?? '',
          rating: item.rating.toStringAsFixed(1),
          photos: item.imageUrl.isNotEmpty ? [item.imageUrl] : const [],
          initialQuantity: 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<WishlistItem>>(
      valueListenable: WishlistService.wishlistNotifier,
      builder: (context, allWishlistItems, _) {
        final filteredItems = _filterItems(allWishlistItems);
        final dynamicCategories = _computeCategories(allWishlistItems);

        // Adjust active filter if it no longer exists
        if (_activeFilter != 'all' &&
            !dynamicCategories.any((c) => c.$1 == _activeFilter)) {
          _activeFilter = 'all';
        }

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: Stack(
            children: [
              // ── Scrollable content ─────────────────────────────────────
              RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                onRefresh: () => _loadData(forceRefresh: true),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // Status bar + Header spacer
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: MediaQuery.of(context).padding.top + 60,
                      ),
                    ),

                    // Search bar
                    SliverToBoxAdapter(
                      child: _SearchBar(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        onClear: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
                    ),

                    // Category pills
                    if (allWishlistItems.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _CategoryPills(
                          categories: dynamicCategories,
                          active: _activeFilter,
                          onSelect: (f) => setState(() => _activeFilter = f),
                        ),
                      ),

                    // Main Content / List or Empty State
                    if (filteredItems.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        sliver: SliverList.separated(
                          itemCount: filteredItems.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (ctx, i) {
                            final item = filteredItems[i];
                            return _DishCard(
                              key: ValueKey(item.id),
                              item: item,
                              isAdding: _addingIds.contains(item.id),
                              onTap: () => _openFoodItemDetails(item),
                              onRemove: () => _removeItem(item),
                              onAdd: () => _handleAddToCart(item),
                            );
                          },
                        ),
                      )
                    else
                      SliverToBoxAdapter(
                        child: _EmptyWishlistView(
                          isFiltered:
                              _searchQuery.isNotEmpty || _activeFilter != 'all',
                          onClearFilters: () {
                            setState(() {
                              _searchCtrl.clear();
                              _searchQuery = '';
                              _activeFilter = 'all';
                            });
                          },
                        ),
                      ),

                    // Bottom hint
                    if (filteredItems.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.favorite_rounded,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Tap heart to remove from wishlist',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                  fontFamily: AppTypography.fontFamily,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Space for floating cart dock + safe area
                    const SliverToBoxAdapter(child: SizedBox(height: 110)),
                  ],
                ),
              ),

              // ── Frosted Header with Back Button ───────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _Header(
                  count: filteredItems.length,
                  isLoading: _isLoading,
                ),
              ),

              // ── Floating cart dock (Visible when cart has items) ───────
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 12,
                left: 16,
                right: 16,
                child: const _CartDock(),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final int count;
  final bool isLoading;
  const _Header({required this.count, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        border: const Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (canPop) ...[
                  _IconBtn(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 12),
                ],
                const Text(
                  'Wishlist',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                    fontFamily: AppTypography.fontFamily,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDeep,
                      fontFamily: AppTypography.fontFamily,
                    ),
                  ),
                ),
                if (isLoading) ...[
                  const SizedBox(width: 10),
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ],
                const Spacer(),
                _IconBtn(
                  icon: Icons.refresh_rounded,
                  onTap: () => WishlistService.loadWishlist(forceRefresh: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderLight, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: AppColors.textSecondary),
      ),
    );
  }
}

// ─── Search bar ───────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
            fontFamily: AppTypography.fontFamily,
          ),
          decoration: InputDecoration(
            hintText: 'Search wishlisted dishes & spots...',
            hintStyle: const TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w400,
              fontSize: 14,
              fontFamily: AppTypography.fontFamily,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              size: 20,
              color: AppColors.textMuted,
            ),
            suffixIcon: controller.text.isNotEmpty
                ? GestureDetector(
                    onTap: onClear,
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
}

// ─── Category pills ───────────────────────────────────────────────────────────
class _CategoryPills extends StatelessWidget {
  final List<(String, String)> categories;
  final String active;
  final ValueChanged<String> onSelect;

  const _CategoryPills({
    required this.categories,
    required this.active,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final (key, label) = categories[i];
          final isActive = active == key;
          return GestureDetector(
            onTap: () => onSelect(key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: isActive ? AppColors.transparent : AppColors.borderLight,
                  width: 1,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? AppColors.white : AppColors.textSecondary,
                  fontFamily: AppTypography.fontFamily,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Dish Card ────────────────────────────────────────────────────────────────
class _DishCard extends StatelessWidget {
  final WishlistItem item;
  final bool isAdding;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onAdd;

  const _DishCard({
    super.key,
    required this.item,
    this.isAdding = false,
    required this.onTap,
    required this.onRemove,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.035),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Thumbnail + Heart
              _Thumbnail(imageUrl: item.imageUrl, onRemove: onRemove),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restaurant + distance
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.restaurant,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                              fontFamily: AppTypography.fontFamily,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            '•',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        Text(
                          '${item.distance.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            fontFamily: AppTypography.fontFamily,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    // Dish name
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.25,
                        fontFamily: AppTypography.fontFamily,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Rating + Tag
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceRaisedWarm,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.amber.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: AppColors.amber,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                item.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDeep,
                                  fontFamily: AppTypography.fontFamily,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceRaised,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.tag,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                                fontFamily: AppTypography.fontFamily,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Price + Add Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '₹${item.price.toStringAsFixed(item.price % 1 == 0 ? 0 : 2)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                fontFamily: AppTypography.fontFamily,
                              ),
                            ),
                            if (item.hasDiscount) ...[
                              const SizedBox(width: 6),
                              Text(
                                '₹${item.originalPrice!.toStringAsFixed(item.originalPrice! % 1 == 0 ? 0 : 2)}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textMuted,
                                  decoration: TextDecoration.lineThrough,
                                  fontFamily: AppTypography.fontFamily,
                                ),
                              ),
                            ],
                          ],
                        ),
                        _AddButton(
                          isAdding: isAdding,
                          onTap: onAdd,
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

// ─── Thumbnail ────────────────────────────────────────────────────────────────
class _Thumbnail extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onRemove;
  const _Thumbnail({required this.imageUrl, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 96,
                      height: 96,
                      color: AppColors.surfaceRaised,
                      child: const Icon(
                        Icons.fastfood_rounded,
                        color: AppColors.textMuted,
                        size: 28,
                      ),
                    ),
                  )
                : Container(
                    width: 96,
                    height: 96,
                    color: AppColors.surfaceRaised,
                    child: const Icon(
                      Icons.fastfood_rounded,
                      color: AppColors.textMuted,
                      size: 28,
                    ),
                  ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onRemove,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.94),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.12),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  size: 17,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Add Button ───────────────────────────────────────────────────────────────
class _AddButton extends StatelessWidget {
  final bool isAdding;
  final VoidCallback onTap;
  const _AddButton({required this.isAdding, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAdding ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(99),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAdding)
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            else
              const Icon(Icons.add_rounded, size: 15, color: AppColors.white),
            const SizedBox(width: 3),
            const Text(
              'Add',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
                fontFamily: AppTypography.fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty View ───────────────────────────────────────────────────────────────
class _EmptyWishlistView extends StatelessWidget {
  final bool isFiltered;
  final VoidCallback onClearFilters;

  const _EmptyWishlistView({
    required this.isFiltered,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceRaisedWarm,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 38,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isFiltered
                  ? 'No matching dishes found'
                  : 'Your wishlist is empty',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                fontFamily: AppTypography.fontFamily,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Try searching with a different keyword or resetting your category filter.'
                  : 'Save your favorite foods and dishes by tapping the heart icon on any menu!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
                fontFamily: AppTypography.fontFamily,
              ),
            ),
            const SizedBox(height: 24),
            if (isFiltered)
              OutlinedButton.icon(
                onPressed: onClearFilters,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.clear_all_rounded, size: 18),
                label: const Text(
                  'Reset Filters',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontFamily: AppTypography.fontFamily,
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.explore_rounded, size: 18),
                label: const Text(
                  'Explore Foods',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontFamily: AppTypography.fontFamily,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Floating Cart Dock ───────────────────────────────────────────────────────
class _CartDock extends StatelessWidget {
  const _CartDock();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CartData?>(
      valueListenable: CartService.cartNotifier,
      builder: (context, cart, _) {
        if (cart == null || cart.isEmpty) {
          return const SizedBox.shrink();
        }

        final vendorName = cart.vendor?.businessName ?? 'Restaurant Basket';
        final itemCount = cart.totalItemCount;
        final total = cart.finalTotal;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CheckoutScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.98),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.10),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        vendorName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          fontFamily: AppTypography.fontFamily,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '$itemCount ${itemCount == 1 ? "item" : "items"} • ₹${total.toStringAsFixed(total % 1 == 0 ? 0 : 2)}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontFamily: AppTypography.fontFamily,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // CTA Button
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View Cart',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                          fontFamily: AppTypography.fontFamily,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 13,
                        color: AppColors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

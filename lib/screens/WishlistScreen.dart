import 'package:flutter/material.dart';

/// Palette matches ProfileColors exactly (same field names, same values)
/// so this screen reads as part of the same app as the Profile screen.
class WishlistColors {
  static const primary = Color(0xFFEE5B2B);
  static const bgLight = Color(0xFFFAFAFC);
  static const bgDeep = Color(0xFF1E1714);
  static const cardLight = Colors.white;
  static const cardFill = Color(0xFF281E19);
  static const borderLight = Color(0xFFF0F0F3);
  static const cardBorder = Color(0xFF3D2B23);
  static const textDescription = Color(0xFFC9A092);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    fontFamily: 'PlusJakartaSans',
    scaffoldBackgroundColor: bgDeep,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ),
  );
}

class Shop {
  final String id;
  final String name;
  final Color color;
  const Shop({required this.id, required this.name, required this.color});
}

class WishlistItem {
  final String id;
  final String name;
  final String category;
  final Shop shop;
  final double price;
  final double? originalPrice; // null = no discount
  final String imageUrl;
  const WishlistItem({
    required this.id,
    required this.name,
    required this.category,
    required this.shop,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
  });

  bool get onSale => originalPrice != null && originalPrice! > price;
  int get discountPercent =>
      onSale ? (((originalPrice! - price) / originalPrice!) * 100).round() : 0;
}

enum SortMode { recent, priceLowHigh, priceHighLow, shopAz }

// Shop accent colors reuse the same hues as the icon badges on the
// Profile screen (blue / green / purple), plus primary for the
// flagship shop — same colorful-icon-badge vocabulary throughout the app.
const _shops = [
  Shop(
    id: 'golden_spoon',
    name: 'The Golden Spoon',
    color: WishlistColors.primary,
  ),
  Shop(id: 'urban_bites', name: 'Urban Bites & Co.', color: Color(0xFF3B82F6)),
  Shop(
    id: 'salad_project',
    name: 'The Salad Project',
    color: Color(0xFF22C55E),
  ),
  Shop(id: 'smokehouse', name: 'The Smokehouse', color: Color(0xFFA855F7)),
];

final List<WishlistItem> _seedItems = [
  WishlistItem(
    id: 'w1',
    name: 'Truffle Pasta',
    category: 'Main Course',
    shop: _shops[0],
    price: 18.00,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDE52O8N8mMKZbpP7xYKADq_Q7TB5iJZUJQEb80XS6VuNpTnmbweZFBt_-Js_qnBNx62GBZJraK2M2YYb0Uygrv1FJ43D5ei7V-HMyuWfXXa-Li61rNfSR20a4f_HYJD4W8rxMWnb89eeUqXl1v1ZUY6XrYE97ZD4nZXOSWAtLWB3-_uSryOq8T0smAyASpMPhI-loxjh8f0zSf1gd91h5NWeXBRJeuKH2ORm4-4htCJ5BcKPZHzkIsDb_e39cUR2PgHx5uQimvzL25',
  ),
  WishlistItem(
    id: 'w2',
    name: 'Cheesy Delight Pizza',
    category: 'Pizza',
    shop: _shops[0],
    price: 12.50,
    originalPrice: 24.99,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBJSMfmwvvapG0ZHxYVePZV8uQK-WLKaOEBlNU9foogkBwzEY19ieziXMxOYMCX9IYuRqVLhcqWCTifN7QdZEEqEN8lDswHzWTC85QA716MmM_ZSZMnzW02rcdwwDJooMYoPnPnf3aPk-VikoWOdXQ20ZaHpC25Efb0cY9Ny4akg6_z0o_MckdyPF8P-9Pc5aqeflowj9BIXYHyx56_gOS9liUE9vu4vySXUoDz4bJZ3C_YHKPo8OqOLiFZ4ZtqCMc5fqX9v0UzPaKn',
  ),
  WishlistItem(
    id: 'w3',
    name: 'Double Beef Smash',
    category: 'Burger',
    shop: _shops[1],
    price: 8.50,
    originalPrice: 17.00,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAQajB08E40GIXc8XWyyyJMRfiC-vn1pldnjNsBeT4QKpDSVuRPNQiF_8Xk7LRwrIYXJxmOvomxzJt0g1Mb_vFTw03CabQfXbrnowLWkLGvTcQApK-VYIWfGXD-eU6-Mr2ZxcrCB1y52q3uNdCnHoOtbB4c0y3OXzn8IKuMQUNSr1UiZok0k27xh3YuHhZJLw9l1ZPXTbm4vGTIpX6ZbJuOTXN3CMD3aNLeddYUY_4mTJJjgQW83l3ZJlgse1qM9CR25MIsOBKXjG7p',
  ),
  WishlistItem(
    id: 'w4',
    name: 'Morning Berry Bowl',
    category: 'Healthy',
    shop: _shops[2],
    price: 9.20,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuD4yhPin6dzd-0bzsMiqqxvvUt4eAfu6HTxkb3DYB2THXb5sagbjYSFDbkvCxjzxusQ5dWZfaRvXoq8qyJ8ACdiGbOtBoi4StQfmdpWtxfMDDOKxb_FfqRgdCmcx7tEt6Jg4w6nZRHbKit8KD9do6rpyv5ztqJla4UiiAJPNjRWxApaV0lYy8kQYFKgSmBBeW6U6yndkJdUiE4s9N6gPfR91oID-PtuospqsPqEOBlETl8irRRgka1_hH9yTIY8UvuntkKdc5zVoqO7',
  ),
  WishlistItem(
    id: 'w5',
    name: 'Classic Bruschetta',
    category: 'Starters',
    shop: _shops[0],
    price: 8.50,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuC0GC79J4Zm8F2EUKSyEXzxTAEI94jwQagtF87LSrYHNS7jvgGOaYmxPQjquEEH_VtxZ59iIN8c3kVmtvWyUk9rgoXJihR2mCIauaELYlJp7lm17q75uq4R2ycoIVSXG5Yy00xTKvmHEHTEHv9ZDo-j48R7KPwC5iQ6TEhzUcmMjJ4Kmf4WnFcMClT2gfowVEJA7l0OLe32RVEkQummZa6Gws-2B7CgQZrN640LwY6hxM1CK5_AW4J3zpffBHBwyxG7ICpgi1pJfaTr',
  ),
  WishlistItem(
    id: 'w6',
    name: 'Smoked Beef Ribs',
    category: 'BBQ',
    shop: _shops[3],
    price: 22.00,
    originalPrice: 27.50,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBYqdb8-9dmDhLNbRhUZwKxFHXjz7Y4vohYf_W8xFGxw9kTwBHveqIdCkrTHUQFaxTmEKqlWLgb-g07hckDwyvI3EPQVd3yfOyVhYftbNZTfrukzHIIF1mz8wheRiNmvKSKP5jfdisKF6Q9AqcHT4mQn639vumXdwgcHeA5Cwp-7jEXE5VN06kcFAgxiMEPHNL6fnBGJ-owFJCNfjFr7-zH4-urFCgqol1C4sA1vL_GrWomz0r_eUCrXltx83sxyhzUlNVuKq2S8fzN',
  ),
  WishlistItem(
    id: 'w7',
    name: 'Crispy Calamari',
    category: 'Starters',
    shop: _shops[0],
    price: 12.00,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCkI0TATJPsgwsaat2AW6Fap5fIXeLSNAnIX7OZlfqp2hzhoQonPI6Hkfnl8QbHHzA-6nLahdJ6ClTs8dVM691mkZV0RfJRWurapBWxEJoUSKmtuLvyXOcXQ9RuLZw293hRGe1qfO5dWyPPEpIHqFdtRfdXRTWKTE7VgyKsiAvKtxjxG7WvA9EkKTCpxvVkjkx1hCPFSruChrYmBq0cDYCH0DuavItlBGuUslw7atPUZHVPct__WQ8rD-oJ2MCl2Yrk9JE8ZuGIe4sU',
  ),
  WishlistItem(
    id: 'w8',
    name: 'Miso Soup',
    category: 'Starters',
    shop: _shops[1],
    price: 3.50,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAzVwyx5UJyBlkILUTxyC6woyMOJdGQHNMZcrQZyLzdU1ZwSyW5Jn5OVdi-uUtezcHjo-q5BdB43aCAB44bO4_UQ40vqMg2rUbeDPfRAdks1b6UQermDb6MH5iF0geKrfMudwQBLHCL5NWn_qvRofQtdWGB1L3wLZtFsotLQpa6fXwqYUcbRay34zGjrX0-6whqyIZFqo1R1Wv5IocBTySU6TtrMk2FTmjJrYlB-FqX8aoQZoWN1y6rAJFaFIro74FBs8WaSnT6opxK',
  ),
];

/// ---------------------------------------------------------------------
/// Main screen
/// ---------------------------------------------------------------------
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late List<WishlistItem> _items;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _selectedShopId; // null = All Shops
  SortMode _sortMode = SortMode.recent;

  @override
  void initState() {
    super.initState();
    _items = List.of(_seedItems);
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<WishlistItem> get _visibleItems {
    var list = _items.where((item) {
      final matchesQuery =
          _query.isEmpty ||
          item.name.toLowerCase().contains(_query) ||
          item.shop.name.toLowerCase().contains(_query) ||
          item.category.toLowerCase().contains(_query);
      final matchesShop =
          _selectedShopId == null || item.shop.id == _selectedShopId;
      return matchesQuery && matchesShop;
    }).toList();

    switch (_sortMode) {
      case SortMode.recent:
        break; // keep insertion order
      case SortMode.priceLowHigh:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortMode.priceHighLow:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortMode.shopAz:
        list.sort((a, b) => a.shop.name.compareTo(b.shop.name));
        break;
    }
    return list;
  }

  void _removeItem(WishlistItem item, bool isDark) {
    setState(() => _items.removeWhere((i) => i.id == item.id));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark
            ? WishlistColors.cardFill
            : WishlistColors.cardLight,
        content: Text(
          'Removed "${item.name}" from wishlist',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1D1E20),
            fontWeight: FontWeight.w500,
          ),
        ),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: WishlistColors.primary,
          onPressed: () => setState(() => _items.add(item)),
        ),
      ),
    );
  }

  void _openSortSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark
          ? WishlistColors.cardFill
          : WishlistColors.cardLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _SortSheet(
        isDark: isDark,
        selected: _sortMode,
        onSelect: (mode) {
          setState(() => _sortMode = mode);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleItems;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? WishlistColors.bgDeep : WishlistColors.bgLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(isDark: isDark, itemCount: _items.length),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SearchBar(
                                isDark: isDark,
                                controller: _searchController,
                                onFilterTap: () => _openSortSheet(isDark),
                              ),
                              const SizedBox(height: 16),
                              _ShopFilterRow(
                                isDark: isDark,
                                selectedShopId: _selectedShopId,
                                onSelect: (id) =>
                                    setState(() => _selectedShopId = id),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (visible.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(
                        isDark: isDark,
                        hasQuery: _query.isNotEmpty,
                      ),
                    )
                  else
                    SliverToBoxAdapter(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                            child: Column(
                              children: [
                                for (final item in visible)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _WishlistCard(
                                      isDark: isDark,
                                      item: item,
                                      onRemove: () => _removeItem(item, isDark),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
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
/// Top bar — matches ProfileScreen's _TopBar exactly (chevron + title)
/// ---------------------------------------------------------------------
class _TopBar extends StatelessWidget {
  final bool isDark;
  final int itemCount;
  const _TopBar({required this.isDark, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF1D1E20);
    final subtitleColor = isDark
        ? WishlistColors.textDescription
        : Colors.grey[600];

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      color: isDark ? WishlistColors.bgDeep : WishlistColors.bgLight,
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).maybePop(),
              icon: Icon(
                Icons.chevron_left_rounded,
                color: textColor,
                size: 28,
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'My Wishlist',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                Text(
                  '$itemCount item${itemCount == 1 ? '' : 's'} saved',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: subtitleColor,
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

class _SearchBar extends StatelessWidget {
  final bool isDark;
  final TextEditingController controller;
  final VoidCallback onFilterTap;
  const _SearchBar({
    required this.isDark,
    required this.controller,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final fieldBg = isDark ? WishlistColors.cardFill : WishlistColors.cardLight;
    final fieldBorder = isDark
        ? WishlistColors.cardBorder
        : WishlistColors.borderLight;
    final textColor = isDark ? Colors.white : const Color(0xFF1D1E20);
    final hintColor = isDark
        ? WishlistColors.textDescription
        : Colors.grey[500];

    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: fieldBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: fieldBorder),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search saved items or shops',
                hintStyle: TextStyle(color: hintColor),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: hintColor,
                  size: 22,
                ),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, _) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: hintColor,
                        size: 18,
                      ),
                      onPressed: controller.clear,
                    );
                  },
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: onFilterTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: WishlistColors.primary.withValues(
                alpha: isDark ? 0.2 : 0.1,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: WishlistColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: WishlistColors.primary,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------
/// Shop filter — same pill treatment as the "GOLD MEMBER" badge on
/// ProfileScreen (tinted fill + soft border when selected).
/// ---------------------------------------------------------------------
class _ShopFilterRow extends StatelessWidget {
  final bool isDark;
  final String? selectedShopId;
  final ValueChanged<String?> onSelect;
  const _ShopFilterRow({
    required this.isDark,
    required this.selectedShopId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _ShopChip(
            isDark: isDark,
            label: 'All Shops',
            accent: WishlistColors.primary,
            selected: selectedShopId == null,
            onTap: () => onSelect(null),
          ),
          const SizedBox(width: 10),
          for (final shop in _shops) ...[
            _ShopChip(
              isDark: isDark,
              label: shop.name,
              accent: shop.color,
              selected: selectedShopId == shop.id,
              onTap: () => onSelect(shop.id),
            ),
            const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _ShopChip extends StatelessWidget {
  final bool isDark;
  final String label;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;
  const _ShopChip({
    required this.isDark,
    required this.label,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unselectedBg = isDark
        ? WishlistColors.cardFill
        : WishlistColors.cardLight;
    final unselectedBorder = isDark
        ? WishlistColors.cardBorder
        : WishlistColors.borderLight;
    final unselectedText = isDark ? Colors.white70 : Colors.grey[700];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? accent.withValues(alpha: isDark ? 0.2 : 0.1)
              : unselectedBg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? accent.withValues(alpha: 0.35) : unselectedBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? accent : unselectedText,
            letterSpacing: selected ? 0.2 : 0,
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Wishlist item card — same card shell as ProfileScreen's _MenuRow:
/// rounded 16, soft border + shadow, colored icon-badge language reused
/// for the quick-action buttons, and a small pill for the sale tag
/// instead of a diagonal ribbon.
/// ---------------------------------------------------------------------
class _WishlistCard extends StatefulWidget {
  final bool isDark;
  final WishlistItem item;
  final VoidCallback onRemove;
  const _WishlistCard({
    required this.isDark,
    required this.item,
    required this.onRemove,
  });

  @override
  State<_WishlistCard> createState() => _WishlistCardState();
}

class _WishlistCardState extends State<_WishlistCard> {
  bool _removing = false;

  void _handleRemove() {
    setState(() => _removing = true);
    Future.delayed(const Duration(milliseconds: 140), widget.onRemove);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isDark = widget.isDark;
    final cardBg = isDark ? WishlistColors.cardFill : WishlistColors.cardLight;
    final cardBorderColor = isDark
        ? WishlistColors.cardBorder
        : WishlistColors.borderLight;
    final titleColor = isDark ? Colors.white : const Color(0xFF1D1E20);
    final subtitleColor = isDark
        ? WishlistColors.textDescription
        : Colors.grey[600];

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => widget.onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Color(0xFFEF4444),
        ),
      ),
      child: AnimatedOpacity(
        opacity: _removing ? 0 : 1,
        duration: const Duration(milliseconds: 140),
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 76,
                      height: 76,
                      child: Image.network(item.imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                  if (item.onSale)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: WishlistColors.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '-${item.discountPercent}%',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: item.shop.color,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.shop.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: item.shop.color,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.category,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: subtitleColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '\$${item.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: WishlistColors.primary,
                              ),
                            ),
                            if (item.onSale) ...[
                              const SizedBox(width: 6),
                              Text(
                                '\$${item.originalPrice!.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: subtitleColor,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                        Row(
                          children: [
                            _IconBadgeButton(
                              isDark: isDark,
                              icon: Icons.add_shopping_cart_rounded,
                              color: const Color(0xFF3B82F6),
                              onTap: () {},
                            ),
                            const SizedBox(width: 8),
                            _IconBadgeButton(
                              isDark: isDark,
                              icon: Icons.favorite_rounded,
                              color: WishlistColors.primary,
                              onTap: _handleRemove,
                            ),
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

/// Small square icon badge — the same visual language as the 42x42
/// colored icon badges on ProfileScreen's menu rows, sized down for
/// inline card actions.
class _IconBadgeButton extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconBadgeButton({
    required this.isDark,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 15, color: color),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Sort bottom sheet — rows styled like ProfileScreen's menu items
/// ---------------------------------------------------------------------
class _SortSheet extends StatelessWidget {
  final bool isDark;
  final SortMode selected;
  final ValueChanged<SortMode> onSelect;
  const _SortSheet({
    required this.isDark,
    required this.selected,
    required this.onSelect,
  });

  static const _options = [
    (SortMode.recent, 'Recently Added', Icons.schedule_rounded),
    (SortMode.priceLowHigh, 'Price: Low to High', Icons.arrow_upward_rounded),
    (SortMode.priceHighLow, 'Price: High to Low', Icons.arrow_downward_rounded),
    (SortMode.shopAz, 'Shop Name (A–Z)', Icons.storefront_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark ? Colors.white : const Color(0xFF1D1E20);
    final handleColor = isDark
        ? WishlistColors.cardBorder
        : WishlistColors.borderLight;
    final subtitleColor = isDark
        ? WishlistColors.textDescription
        : Colors.grey[600];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: handleColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Text(
              'Sort by',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 12),
            for (final (mode, label, icon) in _options)
              InkWell(
                onTap: () => onSelect(mode),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: WishlistColors.primary.withValues(
                            alpha: mode == selected ? (isDark ? 0.2 : 0.1) : 0,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          icon,
                          size: 18,
                          color: mode == selected
                              ? WishlistColors.primary
                              : subtitleColor,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: mode == selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: mode == selected
                                ? titleColor
                                : subtitleColor,
                          ),
                        ),
                      ),
                      if (mode == selected)
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: WishlistColors.primary,
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
/// Empty state — same circular icon treatment as the avatar edit badge
/// on ProfileScreen
/// ---------------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  final bool isDark;
  final bool hasQuery;
  const _EmptyState({required this.isDark, required this.hasQuery});

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark ? Colors.white : const Color(0xFF1D1E20);
    final subtextColor = isDark
        ? WishlistColors.textDescription
        : Colors.grey[600];

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: WishlistColors.primary.withValues(
                  alpha: isDark ? 0.2 : 0.1,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                hasQuery
                    ? Icons.search_off_rounded
                    : Icons.favorite_border_rounded,
                color: WishlistColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasQuery ? 'No matches found' : 'Your wishlist is empty',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasQuery
                  ? 'Try a different search term or clear your filters.'
                  : 'Tap the heart on any dish to save it here for later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: subtextColor,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

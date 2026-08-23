import 'package:flutter/material.dart';
import 'OfferExplanationScreen.dart';
import 'FoodItemPage.dart';

class MenuColors {
  static const primary = Color(0xFFEE5B2B);
  static const bgLight = Color(0xFFFAFAFC);
  static const bgDark = Color(0xFF1E1714);
  static const cardLight = Colors.white;
  static const cardDark = Color(0xFF281E19);
  static const borderLight = Color(0xFFF0F0F3);
  static const borderDark = Color(0xFF3D2B23);
  static const textMutedDark = Color(0xFFC9A092);

  static ThemeData get lightTheme => ThemeData(
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
class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String? badge; // e.g. "BESTSELLER"
  final String? tag; // e.g. "VEG"
  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.badge,
    this.tag,
  });
}

class MenuCategory {
  final String title;
  final List<MenuItem> items;
  const MenuCategory({required this.title, required this.items});
}

class OfferCard {
  final String badgeLabel;
  final String timer;
  final String headline;
  final String subline;
  final String fineprint;
  final List<Color> gradient;
  const OfferCard({
    required this.badgeLabel,
    required this.timer,
    required this.headline,
    required this.subline,
    required this.fineprint,
    required this.gradient,
  });
}

const _heroImageUrl =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBC4rVbFwoGXjLht7kVnBqIRzwWvs4Zjs9MXRO9KcTo0jtfVSf_7cntQUcOWZMo9w16aPaHimQ761pXteNZ6bWmgD-Z9MhZGuIBDnB1i3QsScDX33zWUZClf1BWVGbLlBU8z2XBgGXGN6lFJ7gaJxCoQ3np7fwv88HuUnvC-khsITpGFIaTnWeiWUwdhVuaMheHbMtARJ5UW2ZFT1zRRFniyyZQhpVu3y8V4_c3tp18JfzXF_Bf5JCHU5HWwrbdb3lkL9ySfGgKfVc5';

const _offers = [
  OfferCard(
    badgeLabel: 'PROMO',
    timer: '02:15:30',
    headline: '50% OFF',
    subline: 'On all Pasta dishes',
    fineprint: 'Min. order \$30',
    gradient: [MenuColors.primary, Color(0xFFEA580C)],
  ),
  OfferCard(
    badgeLabel: 'COMBO',
    timer: '05:00:00',
    headline: 'FREE DRINK',
    subline: 'With any large pizza',
    fineprint: 'Valid today only',
    gradient: [Color(0xFF9333EA), Color(0xFF4F46E5)],
  ),
];

const _categories = [
  MenuCategory(
    title: 'Starters',
    items: [
      MenuItem(
        id: 'bruschetta',
        name: 'Classic Bruschetta',
        description:
            'Toasted bread topped with fresh tomatoes, basil, garlic, and extra virgin olive oil.',
        price: 8.50,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuC0GC79J4Zm8F2EUKSyEXzxTAEI94jwQagtF87LSrYHNS7jvgGOaYmxPQjquEEH_VtxZ59iIN8c3kVmtvWyUk9rgoXJihR2mCIauaELYlJp7lm17q75uq4R2ycoIVSXG5Yy00xTKvmHEHTEHv9ZDo-j48R7KPwC5iQ6TEhzUcmMjJ4Kmf4WnFcMClT2gfowVEJA7l0OLe32RVEkQummZa6Gws-2B7CgQZrN640LwY6hxM1CK5_AW4J3zpffBHBwyxG7ICpgi1pJfaTr',
        badge: 'BESTSELLER',
      ),
      MenuItem(
        id: 'calamari',
        name: 'Crispy Calamari',
        description:
            'Golden fried squid rings served with tartare sauce and lemon wedge.',
        price: 12.00,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCkI0TATJPsgwsaat2AW6Fap5fIXeLSNAnIX7OZlfqp2hzhoQonPI6Hkfnl8QbHHzA-6nLahdJ6ClTs8dVM691mkZV0RfJRWurapBWxEJoUSKmtuLvyXOcXQ9RuLZw293hRGe1qfO5dWyPPEpIHqFdtRfdXRTWKTE7VgyKsiAvKtxjxG7WvA9EkKTCpxvVkjkx1hCPFSruChrYmBq0cDYCH0DuavItlBGuUslw7atPUZHVPct__WQ8rD-oJ2MCl2Yrk9JE8ZuGIe4sU',
      ),
    ],
  ),
  MenuCategory(
    title: 'Main Course',
    items: [
      MenuItem(
        id: 'margherita',
        name: 'Margherita Pizza',
        description:
            'San Marzano tomato sauce, fresh mozzarella di bufala, basil.',
        price: 14.50,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuC_YRGus2PCgcyztPZQvwGeLwPHYRvyM-dUBc5hfxSoZbmcuU9r22mwMR4U8k856S-2g6uVw_Bs_p9HtDzWMu_eCVwv-9Jz7yZcSEPbQYsiA69iplJtKR9m8NNT4NNbkwHDQ4BlrnI4E19_Ua0IMfjPF9dz0CxQ840GZpAOzo83btj-Q0Xn95qYmzcNMAMKGWn-FbJETu1K4mulbRPdBUrbgD3MM2EVAuhxxl0yX-FR_mB7t_u_2a_lWagWPKMq8iuPoZV1drMe-9xT',
      ),
      MenuItem(
        id: 'truffle_pasta',
        name: 'Truffle Pasta',
        description:
            'Tagliatelle with creamy black truffle sauce and parmesan.',
        price: 18.00,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDE52O8N8mMKZbpP7xYKADq_Q7TB5iJZUJQEb80XS6VuNpTnmbweZFBt_-Js_qnBNx62GBZJraK2M2YYb0Uygrv1FJ43D5ei7V-HMyuWfXXa-Li61rNfSR20a4f_HYJD4W8rxMWnb89eeUqXl1v1ZUY6XrYE97ZD4nZXOSWAtLWB3-_uSryOq8T0smAyASpMPhI-loxjh8f0zSf1gd91h5NWeXBRJeuKH2ORm4-4htCJ5BcKPZHzkIsDb_e39cUR2PgHx5uQimvzL25',
        tag: 'VEG',
      ),
    ],
  ),
];

const _categoryPills = [
  'All Items',
  'Starters',
  'Main Course',
  'Beverages',
  'Desserts',
];

/// ---------------------------------------------------------------------
/// Main screen
/// ---------------------------------------------------------------------
class RestaurantMenuScreen extends StatefulWidget {
  const RestaurantMenuScreen({super.key});

  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  final Map<String, int> _cart = {}; // itemId -> quantity
  int _tabIndex = 0; // Menu / Offers / Reviews / Info
  String _selectedPill = 'All Items';
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _tabIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  double get _cartTotal {
    double total = 0;
    for (final category in _categories) {
      for (final item in category.items) {
        final qty = _cart[item.id] ?? 0;
        total += qty * item.price;
      }
    }
    return total;
  }

  int get _cartCount => _cart.values.fold(0, (sum, q) => sum + q);

  void _addItem(String id) {
    setState(() => _cart[id] = (_cart[id] ?? 0) + 1);
  }

  void _removeItem(String id) {
    setState(() {
      final current = _cart[id] ?? 0;
      if (current <= 1) {
        _cart.remove(id);
      } else {
        _cart[id] = current - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? MenuColors.bgDark : MenuColors.bgLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(child: _HeroSection(isDark: isDark)),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabsHeaderDelegate(
                    selectedIndex: _tabIndex,
                    isDark: isDark,
                    onSelect: (i) {
                      setState(() => _tabIndex = i);
                      _pageController.animateToPage(
                        i,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ];
            },
            body: PageView(
              controller: _pageController,
              onPageChanged: (i) {
                setState(() => _tabIndex = i);
              },
              children: [
                _MenuView(
                  selectedPill: _selectedPill,
                  onSelectPill: (p) => setState(() => _selectedPill = p),
                  categories: _categories,
                  cart: _cart,
                  isDark: isDark,
                  onAdd: _addItem,
                  onRemove: _removeItem,
                ),
                _OffersView(isDark: isDark),
                _ReviewsView(isDark: isDark),
                _InfoView(isDark: isDark),
              ],
            ),
          ),
          // Fixed top action buttons over the hero image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _TopActionBar(isDark: isDark),
          ),
          // Floating "View Cart" button bar
          if (_cartCount > 0)
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: _ViewCartButton(count: _cartCount, total: _cartTotal),
            ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Fixed top bar: back / search / share
/// ---------------------------------------------------------------------
class _TopActionBar extends StatelessWidget {
  final bool isDark;
  const _TopActionBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 12,
        20,
        16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _RoundIconButton(
            icon: Icons.chevron_left_rounded,
            size: 16,
            isDark: isDark,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          Row(
            children: [
              _RoundIconButton(icon: Icons.search_rounded, isDark: isDark),
              const SizedBox(width: 10),
              _RoundIconButton(icon: Icons.share_rounded, isDark: isDark),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final bool isDark;
  final VoidCallback? onTap;

  const _RoundIconButton({
    required this.icon,
    required this.isDark,
    this.size = 16,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark
              ? Colors.black.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.9),
          border: Border.all(
            color: isDark ? const Color(0xFF3D2B23) : const Color(0xFFEEEEEE),
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
/// Hero image + restaurant info
/// ---------------------------------------------------------------------
class _HeroSection extends StatelessWidget {
  final bool isDark;
  const _HeroSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? MenuColors.bgDark : MenuColors.bgLight;

    return SizedBox(
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
                  bgColor.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          'The Golden Spoon',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1D1E20),
                            letterSpacing: -0.4,
                            height: 1.1,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF22C55E,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: const Color(
                              0xFF22C55E,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Text(
                          'OPEN NOW',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF22C55E),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: MenuColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '4.5',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1D1E20),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        ' (128)',
                        style: TextStyle(
                          color: isDark
                              ? MenuColors.textMutedDark
                              : Colors.grey[500],
                          fontSize: 13,
                        ),
                      ),
                      _Dot(isDark: isDark),
                      Text(
                        'Italian, Pizza',
                        style: TextStyle(
                          color: isDark
                              ? MenuColors.textMutedDark
                              : Colors.grey[700],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      _Dot(isDark: isDark),
                      Text(
                        '2.4 km',
                        style: const TextStyle(
                          color: MenuColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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

class _Dot extends StatelessWidget {
  final bool isDark;
  const _Dot({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? Colors.white30 : Colors.grey[400],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Sticky tabs header: Menu / Offers / Reviews / Info
/// ---------------------------------------------------------------------
class _TabsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final int selectedIndex;
  final bool isDark;
  final ValueChanged<int> onSelect;
  static const _tabs = ['Menu', 'Offers', 'Reviews', 'Info'];

  _TabsHeaderDelegate({
    required this.selectedIndex,
    required this.isDark,
    required this.onSelect,
  });

  @override
  double get minExtent => 46;

  @override
  double get maxExtent => 46;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final bgColor = isDark ? MenuColors.bgDark : MenuColors.bgLight;
    final borderColor = isDark
        ? MenuColors.borderDark
        : const Color(0xFFF0F0F3);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final selected = i == selectedIndex;
          return Expanded(
            child: InkWell(
              onTap: () => onSelect(i),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected ? MenuColors.primary : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _tabs[i],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selected
                            ? MenuColors.primary
                            : (isDark
                                  ? MenuColors.textMutedDark
                                  : Colors.grey[500]),
                      ),
                    ),
                    if (_tabs[i] == 'Offers') ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: MenuColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '2',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabsHeaderDelegate oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.isDark != isDark;
  }
}

/// ---------------------------------------------------------------------
/// Category filter pills (All Items / Starters / Main Course / ...)
/// ---------------------------------------------------------------------
class _CategoryPills extends StatelessWidget {
  final String selected;
  final bool isDark;
  final ValueChanged<String> onSelect;
  const _CategoryPills({
    required this.selected,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: _categoryPills.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final label = _categoryPills[i];
          final isSelected = label == selected;
          return InkWell(
            onTap: () => onSelect(label),
            borderRadius: BorderRadius.circular(999),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? MenuColors.primary
                    : (isDark ? MenuColors.cardDark : Colors.white),
                borderRadius: BorderRadius.circular(999),
                border: isSelected
                    ? null
                    : Border.all(
                        color: isDark
                            ? MenuColors.borderDark
                            : const Color(0xFFF0F0F3),
                      ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: MenuColors.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                            ? MenuColors.textMutedDark
                            : const Color(0xFF2D2D2D)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// "Today's Offers" horizontal scroll
/// ---------------------------------------------------------------------
class _TodaysOffers extends StatelessWidget {
  final bool isDark;
  const _TodaysOffers({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Offers 🔥",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1D1E20),
                  letterSpacing: -0.3,
                ),
              ),
              const Text(
                'View All',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: MenuColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 136,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _offers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, i) => _OfferCardWidget(offer: _offers[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferCardWidget extends StatelessWidget {
  final OfferCard offer;
  const _OfferCardWidget({required this.offer});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OfferExplanationScreen(
              title: offer.headline,
              subtitle: offer.subline,
              code: offer.badgeLabel == 'PROMO' ? 'ZTEEEL50' : 'BOGOCOMBO',
              badge: offer.badgeLabel,
              expiry: offer.timer,
              gradientColors: offer.gradient,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: offer.gradient,
            ),
            boxShadow: [
              BoxShadow(
                color: offer.gradient.first.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -24,
                bottom: -24,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          offer.badgeLabel,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              color: Colors.white,
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              offer.timer,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
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
                        offer.headline,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        offer.subline,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Menu category section + item cards
/// ---------------------------------------------------------------------
class _CategorySection extends StatelessWidget {
  final MenuCategory category;
  final Map<String, int> cart;
  final bool isDark;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  const _CategorySection({
    required this.category,
    required this.cart,
    required this.isDark,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                category.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1D1E20),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? MenuColors.cardDark : const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${category.items.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? MenuColors.textMutedDark : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Column(
            children: category.items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 26),
                    child: _MenuItemCard(
                      item: item,
                      quantity: cart[item.id] ?? 0,
                      isDark: isDark,
                      onAdd: () => onAdd(item.id),
                      onRemove: () => onRemove(item.id),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final int quantity;
  final bool isDark;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _MenuItemCard({
    required this.item,
    required this.quantity,
    required this.isDark,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? MenuColors.cardDark : Colors.white;
    final cardBorder = isDark ? MenuColors.borderDark : const Color(0xFFF0F0F3);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FoodItemPage(
              id: item.id,
              name: item.name,
              category: item.tag == 'VEG' ? 'Vegetarian' : 'Non-Veg',
              price: item.price,
              description: item.description,
              isVeg: item.tag == 'VEG',
              isBestseller: item.badge == 'BESTSELLER',
              rating: '4.8',
              photos: [
                item.imageUrl,
                'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600',
                'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=600',
              ],
              initialQuantity: quantity,
              onQuantityChanged: (q) {
                if (q > quantity) {
                  onAdd();
                } else if (q < quantity) {
                  onRemove();
                }
              },
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left: text content ──────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // VEG / NON-VEG dot indicator
                Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        border: Border.all(
                          color: item.tag == 'VEG'
                              ? Colors.green
                              : const Color(0xFFB91C1C),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Center(
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: item.tag == 'VEG'
                                ? Colors.green
                                : const Color(0xFFB91C1C),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    if (item.badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: MenuColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.badge!,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: MenuColors.primary,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                // Name
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    color: isDark ? Colors.white : const Color(0xFF1D1E20),
                  ),
                ),
                const SizedBox(height: 5),
                // Description
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: isDark
                        ? MenuColors.textMutedDark
                        : const Color(0xFF8A8A9A),
                  ),
                ),
                const SizedBox(height: 12),
                // Price
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: MenuColors.primary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // ── Right: image + add/stepper ──────────────────────────
          SizedBox(
            width: 96,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Food image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item.imageUrl,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
                ),
                // Add / Stepper button — overlaps bottom centre of image
                Positioned(
                  bottom: -14,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: quantity == 0
                        ? _AddButton(onAdd: onAdd)
                        : _StepperButton(
                            quantity: quantity,
                            onAdd: onAdd,
                            onRemove: onRemove,
                          ),
                  ),
                ),
              ],
            ),
          ),
          // Space so the bottom of the card accommodates the overlapping button
          const SizedBox(height: 14),
        ],
      ),
    ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Add button (pill style)
/// ---------------------------------------------------------------------
class _AddButton extends StatelessWidget {
  final VoidCallback onAdd;
  const _AddButton({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: MenuColors.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: MenuColors.primary.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Text(
          '+ Add',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Quantity stepper (pill style)
/// ---------------------------------------------------------------------
class _StepperButton extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  const _StepperButton({
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: MenuColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: MenuColors.primary.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onRemove,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Icon(Icons.remove, color: Colors.white, size: 14),
            ),
          ),
          Text(
            '$quantity',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Icon(Icons.add, color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Floating "View Cart" button bar
/// ---------------------------------------------------------------------
class _ViewCartButton extends StatelessWidget {
  final int count;
  final double total;
  const _ViewCartButton({required this.count, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: MenuColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: MenuColors.primary.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'VIEW CART',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Row(
            children: [
              Text(
                'Checkout',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Swappable Tab Views (Menu, Offers, Reviews, Info)
/// ---------------------------------------------------------------------
class _MenuView extends StatelessWidget {
  final String selectedPill;
  final ValueChanged<String> onSelectPill;
  final List<MenuCategory> categories;
  final Map<String, int> cart;
  final bool isDark;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  const _MenuView({
    required this.selectedPill,
    required this.onSelectPill,
    required this.categories,
    required this.cart,
    required this.isDark,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final filteredCategories = selectedPill == 'All Items'
        ? categories
        : categories.where((c) => c.title == selectedPill).toList();

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _CategoryPills(
          selected: selectedPill,
          isDark: isDark,
          onSelect: onSelectPill,
        ),
        _TodaysOffers(isDark: isDark),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              for (final category in filteredCategories)
                _CategorySection(
                  category: category,
                  cart: cart,
                  isDark: isDark,
                  onAdd: onAdd,
                  onRemove: onRemove,
                ),
            ],
          ),
        ),
        const SizedBox(height: 120),
      ],
    );
  }
}

class _OffersView extends StatelessWidget {
  final bool isDark;
  const _OffersView({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? MenuColors.cardDark : Colors.white;
    final cardBorder = isDark ? MenuColors.borderDark : const Color(0xFFF0F0F3);
    final textColor = isDark ? Colors.white : const Color(0xFF1D1E20);
    final subColor = isDark ? MenuColors.textMutedDark : Colors.grey[600]!;

    final offers = [
      {
        'title': 'FLAT 50% OFF',
        'subtitle': 'Use code ZTEEEL50 on orders above \$25',
        'code': 'ZTEEEL50',
        'badge': 'BESTSELLER',
        'expiry': 'Valid till 31st Dec',
        'color': MenuColors.primary,
      },
      {
        'title': 'FREE DELIVERY',
        'subtitle': 'Enjoy zero delivery fees on orders above \$15',
        'code': 'FREEDEL',
        'badge': 'POPULAR',
        'expiry': 'Valid on all items',
        'color': const Color(0xFF22C55E),
      },
      {
        'title': '15% STEELPAY CASHBACK',
        'subtitle': 'Get up to \$10 cashback when paying with SteelPay',
        'code': 'STEELPAY15',
        'badge': 'PAYMENT OFFER',
        'expiry': 'Valid once per user',
        'color': const Color(0xFF3B82F6),
      },
      {
        'title': 'BUY 1 GET 1 FREE',
        'subtitle': 'Buy any Artisan Pizza and get a Classic Pizza free',
        'code': 'BOGOPIZZA',
        'badge': 'WEEKDAY SPECIAL',
        'expiry': 'Valid Tue & Thu',
        'color': const Color(0xFFA855F7),
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final offer = offers[index];
        final accentColor = offer['color'] as Color;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OfferExplanationScreen(
                  title: offer['title'] as String,
                  subtitle: offer['subtitle'] as String,
                  code: offer['code'] as String,
                  badge: offer['badge'] as String,
                  expiry: offer['expiry'] as String,
                  gradientColors: [
                    accentColor,
                    accentColor.withValues(alpha: 0.8),
                  ],
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cardBorder, width: 1),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.25)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(
                            alpha: isDark ? 0.2 : 0.1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.local_offer_rounded,
                          color: accentColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    offer['badge'] as String,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: accentColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              offer['title'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              offer['subtitle'] as String,
                              style: TextStyle(fontSize: 12, color: subColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : const Color(0xFFF9FAFB),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                    border: Border(
                      top: BorderSide(color: cardBorder, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: subColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            offer['expiry'] as String,
                            style: TextStyle(fontSize: 11, color: subColor),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Coupon "${offer['code']}" copied to clipboard!',
                              ),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: MenuColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'COPY ${offer['code']}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
      },
    );
  }
}

class _ReviewsView extends StatelessWidget {
  final bool isDark;
  const _ReviewsView({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? MenuColors.cardDark : Colors.white;
    final cardBorder = isDark ? MenuColors.borderDark : const Color(0xFFF0F0F3);
    final textColor = isDark ? Colors.white : const Color(0xFF1D1E20);
    final subColor = isDark ? MenuColors.textMutedDark : Colors.grey[600]!;

    final reviews = [
      {
        'name': 'Sarah Jenkins',
        'rating': 5.0,
        'date': '2 days ago',
        'comment':
            'The Truffle Mushroom Pizza is absolutely out of this world! Super fresh ingredients, hot delivery, and crispy crust.',
        'likes': 18,
        'avatar':
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
      },
      {
        'name': 'Michael Chen',
        'rating': 4.5,
        'date': '1 week ago',
        'comment':
            'Great food quality and fast delivery. The Artisan Pepperoni was delicious. Will definitely order again.',
        'likes': 12,
        'avatar':
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
      },
      {
        'name': 'Emily Rodriguez',
        'rating': 5.0,
        'date': '2 weeks ago',
        'comment':
            'Love the packaging and hygiene standards! Food arrived piping hot within 25 minutes.',
        'likes': 24,
        'avatar':
            'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100',
      },
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorder),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Text(
                    '4.8',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const Row(
                    children: [
                      Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                      Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                      Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                      Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                      Icon(
                        Icons.star_half_rounded,
                        color: Colors.amber,
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '2,450 ratings',
                    style: TextStyle(fontSize: 12, color: subColor),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _RatingBar(stars: '5 ★', percent: 0.85, isDark: isDark),
                    _RatingBar(stars: '4 ★', percent: 0.10, isDark: isDark),
                    _RatingBar(stars: '3 ★', percent: 0.03, isDark: isDark),
                    _RatingBar(stars: '2 ★', percent: 0.01, isDark: isDark),
                    _RatingBar(stars: '1 ★', percent: 0.01, isDark: isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Customer Reviews',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Text(
              'Verified Orders Only',
              style: TextStyle(fontSize: 12, color: subColor),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final r in reviews) ...[
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 14),
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
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(r['avatar'] as String),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r['name'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            r['date'] as String,
                            style: TextStyle(fontSize: 11, color: subColor),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${r['rating']}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  r['comment'] as String,
                  style: TextStyle(fontSize: 13, color: textColor, height: 1.4),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.thumb_up_alt_outlined,
                      size: 14,
                      color: subColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Helpful (${r['likes']})',
                      style: TextStyle(fontSize: 12, color: subColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _RatingBar extends StatelessWidget {
  final String stars;
  final double percent;
  final bool isDark;
  const _RatingBar({
    required this.stars,
    required this.percent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              stars,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? MenuColors.textMutedDark : Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 6,
                backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoView extends StatelessWidget {
  final bool isDark;
  const _InfoView({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? MenuColors.cardDark : Colors.white;
    final cardBorder = isDark ? MenuColors.borderDark : const Color(0xFFF0F0F3);
    final textColor = isDark ? Colors.white : const Color(0xFF1D1E20);
    final subColor = isDark ? MenuColors.textMutedDark : Colors.grey[600]!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: MenuColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: MenuColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location & Address',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '221B Baker Street, Gourmet Quarter, City Center (1.2 km away)',
                          style: TextStyle(fontSize: 12, color: subColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorder),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.access_time_filled_rounded,
                    color: Color(0xFF22C55E),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Opening Hours',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          'Open Now • 10:00 AM – 11:30 PM (Mon - Sun)',
                          style: TextStyle(fontSize: 12, color: subColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(
                    Icons.phone_in_talk_rounded,
                    color: Color(0xFF3B82F6),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phone & Contact',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          '+1 (555) 382-9102',
                          style: TextStyle(fontSize: 12, color: subColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
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
                    Icons.verified_user_rounded,
                    color: MenuColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Hygiene & Safety Certified',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '100% sanitized kitchen, daily staff temperature checks, and contactless delivery packaging.',
                style: TextStyle(fontSize: 12, color: subColor, height: 1.4),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FeatureChip(
                    label: 'AC Dining',
                    icon: Icons.ac_unit,
                    isDark: isDark,
                  ),
                  _FeatureChip(
                    label: 'Takeaway Available',
                    icon: Icons.takeout_dining,
                    isDark: isDark,
                  ),
                  _FeatureChip(
                    label: 'Outdoor Seating',
                    icon: Icons.deck,
                    isDark: isDark,
                  ),
                  _FeatureChip(
                    label: 'Pure Veg Options',
                    icon: Icons.eco,
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;
  const _FeatureChip({
    required this.label,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : const Color(0xFFF0F0F3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: MenuColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1D1E20),
            ),
          ),
        ],
      ),
    );
  }
}

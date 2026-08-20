import 'package:flutter/material.dart';
import 'RestuarantMenuScreen.dart';
import 'CheckOutScreen.dart';

class SelectionsColors {
  static const primary = Color(0xFFEE5B2B);
  static const backgroundLight = Color(0xFFFAFAFC);
  static const backgroundDark = Color(0xFF1E1714);
  static const cardLight = Colors.white;
  static const cardDark = Color(0xFF281E19);
  static const borderLight = Color(0xFFF0F0F3);
  static const borderDark = Color(0xFF3D2B23);
  static const textMutedDark = Color(0xFFC9A092);
  static const textMutedLight = Color(0xFF8A8A9A);

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
/// Data models
/// ---------------------------------------------------------------------
class SelectionEntry {
  final String name;
  final String? imageUrl; // null → placeholder icon tile
  final bool active;
  final int itemCount;
  final double savings;
  final String itemsSummary;

  const SelectionEntry({
    required this.name,
    this.imageUrl,
    this.active = false,
    required this.itemCount,
    required this.savings,
    required this.itemsSummary,
  });
}

class RecentVisit {
  final String name;
  final String imageUrl;
  final bool highlighted;
  const RecentVisit({
    required this.name,
    required this.imageUrl,
    this.highlighted = false,
  });
}

const _selections = [
  SelectionEntry(
    name: 'The Gourmet Grill',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDdkzjMAvBHCfwRW6c8Z0PRDiECvHocxOxi_c7mQzkbyM1Hp8Bjalia5vtRppGwuanih6Mc5VELW-QN9xOnl9iZI4lEsCix4MECxUPaxKGCLxtBTavse6JuRJKa2dL0FWuckkntr-4Con3ZglO0mYRyoULvbFYX9AN3pksQS9WQi0YOnB0mh2G5VSG9hAjK1dIw6l7qPd-LrAu7mouA66Egm5dgQ7dyc1rh4WwFdGfb3nbwpL-SxRZ-TQbyfd3IQwV-cSY5SbCWmz16',
    active: true,
    itemCount: 3,
    savings: 12.50,
    itemsSummary: 'Truffle Pasta, Bruschetta + 1 more',
  ),
  SelectionEntry(
    name: 'Urban Bites & Co.',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDBn2CcBKm9v3EMYD765j4K_BUS5odWdUdF-SNaW7KJa4OoU0He3o-A1x90LLNn6hUurctOhgnx1OdWBvbV4rRjQk256pVUGKYSuijyu0-MgnQa1eC6jTpmSqdkHxu6fWoQmUggA6vv6A6klfgiWmUkYXRKX-UH8wyGFGf3jqIz8Z_DvCSvJdl353AOFcBpeyZ7V6gPKxhy36BLB805UKKTFq8igR8IqZfGog0lDqWE6myfkMFUyHKiXw1zHAb__pLHOIS4YA1LAD1z',
    itemCount: 1,
    savings: 4.20,
    itemsSummary: 'Double Beef Smash Burger',
  ),
  SelectionEntry(
    name: 'The Salad Project',
    imageUrl: null,
    itemCount: 5,
    savings: 18.90,
    itemsSummary: 'Morning Berry Bowl, Fresh Juice + 3 more',
  ),
];

const _recentVisits = [
  RecentVisit(
    name: 'Grill House',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDdkzjMAvBHCfwRW6c8Z0PRDiECvHocxOxi_c7mQzkbyM1Hp8Bjalia5vtRppGwuanih6Mc5VELW-QN9xOnl9iZI4lEsCix4MECxUPaxKGCLxtBTavse6JuRJKa2dL0FWuckkntr-4Con3ZglO0mYRyoULvbFYX9AN3pksQS9WQi0YOnB0mh2G5VSG9hAjK1dIw6l7qPd-LrAu7mouA66Egm5dgQ7dyc1rh4WwFdGfb3nbwpL-SxRZ-TQbyfd3IQwV-cSY5SbCWmz16',
    highlighted: true,
  ),
  RecentVisit(
    name: 'Burger Hub',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDBn2CcBKm9v3EMYD765j4K_BUS5odWdUdF-SNaW7KJa4OoU0He3o-A1x90LLNn6hUurctOhgnx1OdWBvbV4rRjQk256pVUGKYSuijyu0-MgnQa1eC6jTpmSqdkHxu6fWoQmUggA6vv6A6klfgiWmUkYXRKX-UH8wyGFGf3jqIz8Z_DvCSvJdl353AOFcBpeyZ7V6gPKxhy36BLB805UKKTFq8igR8IqZfGog0lDqWE6myfkMFUyHKiXw1zHAb__pLHOIS4YA1LAD1z',
  ),
];

/// Main screen wrapper
class MainCartScreenPage extends StatelessWidget {
  final bool showBottomNav;
  const MainCartScreenPage({super.key, this.showBottomNav = true});

  @override
  Widget build(BuildContext context) {
    return MySelectionsScreen(showBottomNav: showBottomNav);
  }
}

class MySelectionsScreen extends StatefulWidget {
  final bool showBottomNav;
  const MySelectionsScreen({super.key, this.showBottomNav = true});

  @override
  State<MySelectionsScreen> createState() => _MySelectionsScreenState();
}

class _MySelectionsScreenState extends State<MySelectionsScreen> {
  int _navIndex = 3; // "My Cart" active by default
  String _selectedFilter = 'All Baskets (3)';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? SelectionsColors.backgroundDark
        : SelectionsColors.backgroundLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(isDark: isDark),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  _SectionHeader(
                    title: 'Active Baskets',
                    count: _selections.length,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 14),
                  for (final entry in _selections)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _SelectionCard(entry: entry, isDark: isDark),
                    ),
                  const SizedBox(height: 8),
                  _CartTotalFooter(isDark: isDark),
                  const SizedBox(height: 24),
                  _RecentlyVisitedSection(isDark: isDark),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.showBottomNav
          ? _BottomNavBar(
              currentIndex: _navIndex,
              onTap: (i) => setState(() => _navIndex = i),
            )
          : null,
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
    final canPop = Navigator.of(context).canPop();
    final textPrimary = isDark ? Colors.white : const Color(0xFF1D1E20);
    final textMuted = isDark
        ? SelectionsColors.textMutedDark
        : const Color(0xFF8E8E93);
    final borderColor = isDark
        ? SelectionsColors.borderDark
        : const Color(0xFFF0F0F3);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: isDark
            ? SelectionsColors.backgroundDark
            : SelectionsColors.backgroundLight,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (canPop) ...[
                _RoundIconButton(
                  icon: Icons.chevron_left_rounded,
                  size: 18,
                  isDark: isDark,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(width: 12),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: SelectionsColors.primary.withValues(
                      alpha: isDark ? 0.2 : 0.1,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_bag_rounded,
                    color: SelectionsColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'MY SELECTIONS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Your Cart',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              const SizedBox(width: 8),
              _RoundIconButton(
                icon: Icons.more_vert_rounded,
                size: 18,
                isDark: isDark,
                onTap: () {},
              ),
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
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
/// Filter Pills Row
/// ---------------------------------------------------------------------
class _FilterPillsRow extends StatelessWidget {
  final String selected;
  final bool isDark;
  final ValueChanged<String> onSelect;

  static const _pills = ['All Baskets (3)', 'Active (1)', 'Saved (2)'];

  const _FilterPillsRow({
    required this.selected,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _pills.map((pill) {
          final isSelected = pill == selected;
          final pillBg = isSelected
              ? SelectionsColors.primary
              : (isDark ? SelectionsColors.cardDark : Colors.white);
          final pillText = isSelected
              ? Colors.white
              : (isDark
                    ? SelectionsColors.textMutedDark
                    : const Color(0xFF4B5563));
          final pillBorder = isSelected
              ? SelectionsColors.primary
              : (isDark
                    ? SelectionsColors.borderDark
                    : const Color(0xFFE5E7EB));

          return GestureDetector(
            onTap: () => onSelect(pill),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: pillBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: pillBorder, width: 1),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: SelectionsColors.primary.withValues(
                            alpha: 0.3,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                pill,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: pillText,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Section Header with Badge
/// ---------------------------------------------------------------------
class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final bool isDark;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? Colors.white : const Color(0xFF1D1E20);

    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isDark ? SelectionsColors.cardDark : const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? SelectionsColors.textMutedDark : Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------
/// Selection card (restaurant with saved basket)
/// ---------------------------------------------------------------------
class _SelectionCard extends StatelessWidget {
  final SelectionEntry entry;
  final bool isDark;

  const _SelectionCard({required this.entry, required this.isDark});

  void _openCheckout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? SelectionsColors.cardDark : Colors.white;
    final cardBorder = isDark
        ? SelectionsColors.borderDark
        : SelectionsColors.borderLight;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1D1E20);
    final textMuted = isDark
        ? SelectionsColors.textMutedDark
        : const Color(0xFF8A8A9A);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openCheckout(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          width: 88,
                          height: 88,
                          child: entry.imageUrl != null
                              ? Image.network(
                                  entry.imageUrl!,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: isDark
                                      ? const Color(0xFF3A2820)
                                      : const Color(0xFFF3F4F6),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.restaurant_rounded,
                                    color: textMuted,
                                    size: 28,
                                  ),
                                ),
                        ),
                      ),
                      if (entry.active)
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: SelectionsColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'ACTIVE',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.4,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                entry.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: textMuted,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.itemsSummary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: textMuted),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.shopping_basket_rounded,
                              color: SelectionsColors.primary,
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${entry.itemCount} ITEM${entry.itemCount == 1 ? '' : 'S'} SELECTED',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: SelectionsColors.primary,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.savings_rounded,
                              color: Color(0xFF10B981),
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Save \$${entry.savings.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
/// Total Cart Value & Checkout All Summary Card
/// ---------------------------------------------------------------------
class _CartTotalFooter extends StatelessWidget {
  final bool isDark;

  const _CartTotalFooter({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? SelectionsColors.cardDark : Colors.white;
    final borderColor = isDark
        ? SelectionsColors.borderDark
        : SelectionsColors.borderLight;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1D1E20);
    final textMuted = isDark
        ? SelectionsColors.textMutedDark
        : const Color(0xFF8A8A9A);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: SelectionsColors.primary.withValues(
                          alpha: isDark ? 0.2 : 0.1,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: SelectionsColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Cart Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF3A2820)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '3 Baskets • 9 Items',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal',
                  style: TextStyle(fontSize: 13, color: textMuted),
                ),
                Text(
                  '\$110.20',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Savings',
                  style: TextStyle(fontSize: 13, color: textMuted),
                ),
                const Text(
                  '-\$35.60',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(
                height: 1,
                color: isDark
                    ? SelectionsColors.borderDark
                    : const Color(0xFFE5E7EB),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GRAND TOTAL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '\$74.60',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: SelectionsColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'Checkout All',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
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

/// ---------------------------------------------------------------------
/// "Recently Visited" horizontal avatar row
/// ---------------------------------------------------------------------
class _RecentlyVisitedSection extends StatelessWidget {
  final bool isDark;

  const _RecentlyVisitedSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textMuted = isDark
        ? SelectionsColors.textMutedDark
        : const Color(0xFF8A8A9A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'RECENTLY VISITED',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textMuted,
              letterSpacing: 1.2,
            ),
          ),
        ),
        SizedBox(
          height: 94,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _recentVisits.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, i) {
              final visit = _recentVisits[i];
              return SizedBox(
                width: 64,
                child: Column(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: visit.highlighted
                              ? SelectionsColors.primary
                              : (isDark
                                    ? SelectionsColors.borderDark
                                    : const Color(0xFFE5E7EB)),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(visit.imageUrl, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      visit.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------
/// Bottom navigation bar
/// ---------------------------------------------------------------------
class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark
        ? SelectionsColors.backgroundDark
        : SelectionsColors.backgroundLight;
    final borderColor = isDark
        ? SelectionsColors.borderDark
        : const Color(0xFFF0F0F3);
    final mutedText = isDark
        ? SelectionsColors.textMutedDark
        : Colors.grey[400]!;

    final items = [
      (Icons.home_rounded, 'Home'),
      (Icons.local_offer_rounded, 'Deals'),
      (Icons.confirmation_number_rounded, 'My Order'),
      (Icons.shopping_cart_rounded, 'My Cart'),
      (Icons.person_rounded, 'Profile'),
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        10 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: navBg,
        border: Border(top: BorderSide(color: borderColor, width: 1)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (i) {
          final (icon, label) = items[i];
          final selected = i == currentIndex;

          return Expanded(
            child: InkWell(
              onTap: () => onTap(i),
              borderRadius: BorderRadius.circular(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 22,
                    color: selected ? SelectionsColors.primary : mutedText,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? SelectionsColors.primary : mutedText,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

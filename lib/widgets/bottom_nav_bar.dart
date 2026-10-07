import 'package:flutter/material.dart';

import '../app_colors.dart';

/// Minimal floating navigation dock.
///
/// Place it over page content in a [Stack] (e.g. `Align(alignment:
/// Alignment.bottomCenter)`), and use [overlayClearance] to reserve space
/// behind it in scrollable bodies.
///
/// Design: a solid rounded dock with one soft shadow. Every tab shows its
/// icon with the label below, evenly spaced. The selected tab is highlighted
/// with a soft tinted background and the primary color.
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const Color primaryColor = AppColors.orange;
  static const Color inactiveColor = AppColors.textMuted;

  static const double _dockHeight = 68;
  static const double _bottomGap = 4;
  static const double _sideMargin = 20;
  static const double _innerPadding = 6;

  static const _items = [
    (Icons.home_rounded, 'Home'),
    (Icons.local_offer_rounded, 'Deals'),
    (Icons.restaurant_rounded, 'Restaurants'),
    (Icons.receipt_long_rounded, 'Orders'),
    (Icons.person_rounded, 'Profile'),
  ];

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  /// Space dashboard tab bodies should reserve when this dock overlays them.
  static double overlayClearance(BuildContext context) =>
      _dockHeight + _bottomGap + 16 + MediaQuery.paddingOf(context).bottom;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        _sideMargin,
        0,
        _sideMargin,
        _bottomGap + bottomInset,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          height: _dockHeight,
          padding: const EdgeInsets.all(_innerPadding),
          decoration: BoxDecoration(
            color: AppColors.navBg,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.10),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_items.length, (index) {
              final (icon, label) = _items[index];
              return Expanded(
                child: _NavItem(
                  key: ValueKey('bottom-nav-$index'),
                  icon: icon,
                  label: label,
                  selected: index == currentIndex,
                  onTap: () => onTap(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppBottomNavBar.primaryColor
        : AppBottomNavBar.inactiveColor;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: selected ? AppColors.primarySoft : AppColors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            splashColor: AppBottomNavBar.primaryColor.withValues(alpha: 0.08),
            highlightColor: AppColors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 24, color: color),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      softWrap: false,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../app_colors.dart';

/// Clean, modular Bottom Navigation Bar widget for ZTEEL application.
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const Color primaryColor = AppColors.orange;
  static const Color inactiveColor = AppColors.textMuted;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_rounded, 'Home'),
      (Icons.local_offer_rounded, 'Deals'),
      (Icons.receipt_long_rounded, 'My Orders'),
      (Icons.shopping_cart_rounded, 'Cart'),
      (Icons.person_rounded, 'Profile'),
    ];

    return Material(
      color: AppColors.navBg,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(items.length, (i) {
                final item = items[i];
                final (icon, label) = item;
                final selected = i == currentIndex;
                return Expanded(
                  child: Semantics(
                    selected: selected,
                    button: true,
                    child: InkWell(
                      key: ValueKey('bottom-nav-$i'),
                      onTap: () => onTap(i),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icon,
                              size: 22,
                              color: selected ? primaryColor : inactiveColor,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    fontSize: 11,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    letterSpacing: 0.1,
                                    color: selected
                                        ? primaryColor
                                        : inactiveColor,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Clean, modular Bottom Navigation Bar widget for ZTEEL application.
class AppBottomNavBar extends StatelessWidget {
  final bool isDark;
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const Color primaryColor = Color(0xFFEE5B2B);
  static const Color navBarDarkColor = Color(0xFF2E201B);
  static const Color borderDarkColor = Color(0xFF3D2B23);
  static const Color mutedTextDarkColor = Color(0xFFC9A092);

  const AppBottomNavBar({
    super.key,
    required this.isDark,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_rounded, 'Home'),
      (Icons.local_offer_rounded, 'Deals'),
      null, // reserved space for center FAB
      (Icons.shopping_cart_rounded, 'My Cart'),
      (Icons.person_rounded, 'Profile'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 22),
      decoration: BoxDecoration(
        color: isDark ? navBarDarkColor : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? borderDarkColor : const Color(0xFFF0F0F3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.39) : Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (i) {
          final item = items[i];
          if (item == null) {
            return const SizedBox(width: 58); // reserved space for the FAB
          }
          final (icon, label) = item;
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
                    color: selected
                        ? primaryColor
                        : (isDark
                              ? mutedTextDarkColor
                              : Colors.grey[400]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      letterSpacing: 0.1,
                      color: selected
                          ? primaryColor
                          : (isDark
                                ? mutedTextDarkColor
                                : Colors.grey[400]),
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

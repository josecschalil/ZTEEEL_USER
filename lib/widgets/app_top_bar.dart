import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../screens/LocationPageScreen.dart';
import '../screens/NotificationScreen.dart';
import '../services/cart_service.dart';
import '../services/location_service.dart';

class AppTopBar extends StatefulWidget {
  final VoidCallback? onOpenCart;
  final EdgeInsetsGeometry padding;

  const AppTopBar({
    super.key,
    this.onOpenCart,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 10, 4),
  });

  @override
  State<AppTopBar> createState() => _AppTopBarState();
}

class _AppTopBarState extends State<AppTopBar> {
  String _address = 'Choose your location';

  @override
  void initState() {
    super.initState();
    _restoreLocation();
  }

  Future<void> _restoreLocation() async {
    final saved = await LocationService.load();
    if (!mounted || saved == null) return;
    setState(() {
      _address = saved.address.isEmpty ? 'Selected location' : saved.address;
    });
  }

  Future<void> _openLocationPicker() async {
    final result = await Navigator.of(context).push<PickedLocation>(
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
    if (!mounted || result == null) return;
    setState(() {
      _address = result.address.isEmpty ? 'Selected location' : result.address;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              key: const ValueKey('app-top-bar-location'),
              onTap: _openLocationPicker,
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 44,
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        _address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            key: const ValueKey('app-top-bar-notifications'),
            tooltip: 'Notifications',
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            icon: const Icon(Icons.notifications_none_rounded, size: 22),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
          ValueListenableBuilder<Map<String, CartData>>(
            valueListenable: CartService.basketsNotifier,
            builder: (context, baskets, child) {
              final cartItemCount = CartService.grandTotalItemCount;
              return Semantics(
                label: 'Cart, $cartItemCount items',
                child: IconButton(
                  key: const ValueKey('app-top-bar-cart'),
                  tooltip: 'Cart',
                  constraints:
                      const BoxConstraints(minWidth: 44, minHeight: 44),
                  onPressed: widget.onOpenCart,
                  icon: Badge(
                    key: const ValueKey('app-top-bar-cart-badge'),
                    isLabelVisible: cartItemCount > 0,
                    backgroundColor: AppColors.orange,
                    textColor: AppColors.textOnAccent,
                    label: Text(cartItemCount > 99 ? '99+' : '$cartItemCount'),
                    child: const Icon(Icons.shopping_cart_outlined, size: 22),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

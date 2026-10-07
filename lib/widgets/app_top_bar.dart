import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../screens/LocationPageScreen.dart';
import '../screens/MainCartScreen.dart';
import '../screens/NotificationScreen.dart';
import '../services/cart_service.dart';
import '../services/location_service.dart';
import 'exploring_location.dart';

class AppTopBar extends StatefulWidget {
  final bool showBackButton;
  final VoidCallback? onBack;
  final VoidCallback? onOpenCart;
  final EdgeInsetsGeometry padding;
  final Key? locationKey;
  final Key? notificationsKey;
  final Key? cartKey;

  const AppTopBar({
    super.key,
    this.showBackButton = false,
    this.onBack,
    this.onOpenCart,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 14, 4),
    this.locationKey,
    this.notificationsKey,
    this.cartKey,
  });

  @override
  State<AppTopBar> createState() => _AppTopBarState();
}

class _AppTopBarState extends State<AppTopBar> {
  String _address = 'Choose your location';

  @override
  void initState() {
    super.initState();
    LocationService.addressNotifier.addListener(_onAddressChanged);
    _restoreLocation();
  }

  @override
  void dispose() {
    LocationService.addressNotifier.removeListener(_onAddressChanged);
    super.dispose();
  }

  void _onAddressChanged() {
    if (!mounted) return;
    final live = LocationService.addressNotifier.value;
    if (_address != live) {
      setState(() => _address = live);
    }
  }

  Future<void> _restoreLocation() async {
    final saved = await LocationService.load();
    if (!mounted || saved == null) return;
    final newAddress = saved.address.isEmpty ? 'Selected location' : saved.address;
    LocationService.addressNotifier.value = newAddress;
    setState(() {
      _address = newAddress;
    });
  }

  Future<void> _openLocationPicker() async {
    final result = await Navigator.of(context).push<PickedLocation>(
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
    if (!mounted || result == null) return;
    final newAddress = result.address.isEmpty ? 'Selected location' : result.address;
    LocationService.addressNotifier.value = newAddress;
    setState(() {
      _address = newAddress;
    });
  }

  void _handleCartTap() {
    if (widget.onOpenCart != null) {
      widget.onOpenCart!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const MainCartScreenPage(showBottomNav: false),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.showBackButton) ...[
              IconButton(
                key: const ValueKey('app-top-bar-back'),
                tooltip: 'Back',
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
                onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: ExploringLocation(
                key: widget.locationKey ?? const ValueKey('app-top-bar-location'),
                address: _address,
                onTap: _openLocationPicker,
              ),
            ),
            IconButton(
              key: widget.notificationsKey ?? const ValueKey('app-top-bar-notifications'),
              tooltip: 'Notifications',
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              icon: const Icon(
                Icons.notifications_none_rounded,
                size: 22,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
            ),
            ValueListenableBuilder<Map<String, CartData>>(
              valueListenable: CartService.basketsNotifier,
              builder: (context, baskets, _) {
                final count = CartService.grandTotalItemCount;
                return IconButton(
                  key: widget.cartKey ?? const ValueKey('app-top-bar-cart'),
                  tooltip: 'Cart',
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  icon: Badge(
                    key: const ValueKey('app-top-bar-cart-badge'),
                    isLabelVisible: count > 0,
                    backgroundColor: AppColors.orange,
                    textColor: AppColors.textOnAccent,
                    label: Text(
                      count > 99 ? '99+' : '$count',
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      size: 22,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  onPressed: _handleCartTap,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

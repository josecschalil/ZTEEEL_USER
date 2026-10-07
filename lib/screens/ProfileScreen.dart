import '../app_colors.dart';
import 'package:flutter/material.dart';
import 'WishlistScreen.dart';
import 'SavedShopScreen.dart';
import 'PhoneAuthScreen.dart';
import 'RecentOrderScreen.dart';
import 'HelpSupportScreen.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';


class _MenuItem {
  final IconData icon;
  final Color iconColor;
  final String menupage;
  final String title;
  final String subtitle;
  final bool destructive;
  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.menupage,
    this.destructive = false,
  });
}

const _accountItems = [
  _MenuItem(
    icon: Icons.favorite_rounded,
    iconColor: AppColors.toneFFEC4899, // pink-500
    title: 'Wishlist',
    subtitle: 'Your favorite upcoming deals',
    menupage: 'WishlistScreen()',
  ),
  _MenuItem(
    icon: Icons.restaurant_rounded,
    iconColor: AppColors.vegGreen, // green-500
    title: 'Saved Restaurants',
    subtitle: 'Places you love to visit',
    menupage: 'SavedShopScreen()',
  ),
  _MenuItem(
    icon: Icons.qr_code_2_rounded,
    iconColor: AppColors.toneFF3B82F6, // blue-500
    title: 'My Redemptions',
    subtitle: 'Active and past QR code offers',
    menupage: 'OrderScreen',
  ),
];

const _supportItems = [
  _MenuItem(
    icon: Icons.help_outline_rounded,
    iconColor: AppColors.toneFFA855F7, // purple-500
    title: 'Help & Support',
    subtitle: 'FAQs and contact us',
    menupage: 'HelpScreen',
  ),
  _MenuItem(
    icon: Icons.logout_rounded,
    iconColor: AppColors.nonVegRed, // red-500
    title: 'Logout',
    subtitle: 'Sign out of your account',
    menupage: 'LoginScreen',
    destructive: true,
  ),
];

const _avatarUrl =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuDm4rhOuYJUZrS2Q-tAhxvNsOKSEthV7hKDaXStZB5ugYzYsE1YhBmjXsb1I1LQDb7sAIYAb2TlOmAfzuGbQtwbXkN_M2BW3Enp3zgqsFIXZlnomsNWPgchUgxL9Hb7WdpCsYknYhuCkiQjrOvOpF0EQFbJnRE9L_M9Zw2C-qTcPLWRBJaEnjW2rlSNYJpUFk9dPMN4J6xUGYiurPG_vlnsg06d5tdMOrzUvHa9nPLAy1wmlY1-sloOJhNiDICpDQyTX6i8hR2kjJM3';

/// ---------------------------------------------------------------------
/// Main screen
/// ---------------------------------------------------------------------
class ProfileScreen extends StatefulWidget {
  final bool showBottomNav;
  final VoidCallback? onBack;
  final String fullName;
  final String phoneNumber;
  final double bottomOverlayPadding;
  final Future<void> Function()? onRefresh;

  const ProfileScreen({
    super.key,
    this.showBottomNav = true,
    this.onBack,
    this.fullName = '',
    this.phoneNumber = '',
    this.bottomOverlayPadding = 0,
    this.onRefresh,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _navIndex = 4;
  late String _fullName;
  late String _phoneNumber;

  @override
  void initState() {
    super.initState();
    _fullName = widget.fullName;
    _phoneNumber = widget.phoneNumber;
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fullName != oldWidget.fullName || widget.phoneNumber != oldWidget.phoneNumber) {
      setState(() {
        _fullName = widget.fullName;
        _phoneNumber = widget.phoneNumber;
      });
    }
  }

  Future<void> _handleRefresh() async {
    if (widget.onRefresh != null) {
      await widget.onRefresh!();
    }
    final profile = await AuthService.getCustomerProfile();
    if (mounted && profile != null) {
      final firstName = profile['first_name']?.toString().trim() ?? '';
      final lastName = profile['last_name']?.toString().trim() ?? '';
      setState(() {
        _fullName = [firstName, lastName].where((p) => p.isNotEmpty).join(' ');
        _phoneNumber = profile['phone_number']?.toString().trim() ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.bgDeep : AppColors.white;

    final bodyContent = SafeArea(
      bottom: widget.bottomOverlayPadding == 0,
      child: Column(
        children: [
          _TopBar(
            isDark: isDark,
            onBack: widget.onBack ?? () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: isDark ? AppColors.cardDark : AppColors.white,
              onRefresh: _handleRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.only(
                  bottom: 32 + widget.bottomOverlayPadding,
                ),
                children: [
                  const SizedBox(height: 8),
                  _ProfileHeader(
                    isDark: isDark,
                    fullName: _fullName,
                    phoneNumber: _phoneNumber,
                  ),
                  const SizedBox(height: 28),
                  _MenuSection(
                    title: 'Account Overview',
                    items: _accountItems,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),
                  _MenuSection(
                    title: 'Support & Settings',
                    items: _supportItems,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (!widget.showBottomNav) {
      return Container(color: bgColor, child: bodyContent);
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: bodyContent,
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: 58,
        height: 58,
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
          border: Border.all(color: bgColor, width: 4),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          Icons.qr_code_scanner_rounded,
          color: AppColors.white,
          size: 26,
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Sticky top bar: back chevron + "Profile" title
/// ---------------------------------------------------------------------
class _TopBar extends StatelessWidget {
  final bool isDark;
  final VoidCallback onBack;
  const _TopBar({required this.isDark, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      color: isDark ? AppColors.bgDeep : AppColors.white,
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: onBack,
              icon: Icon(
                Icons.chevron_left_rounded,
                color: isDark ? AppColors.white : AppColors.textPrimary,
                size: 28,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: isDark ? AppColors.white : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Avatar + name + phone + gold member badge
/// ---------------------------------------------------------------------
class _ProfileHeader extends StatelessWidget {
  final bool isDark;
  final String fullName;
  final String phoneNumber;

  const _ProfileHeader({
    required this.isDark,
    required this.fullName,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 120,
              height: 120,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(
                    alpha: isDark ? 0.3 : 0.2,
                  ),
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? AppColors.black.withValues(alpha: 0.4)
                        : AppColors.black.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(_avatarUrl, fit: BoxFit.cover),
              ),
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.cardFill : AppColors.white,
                  border: Border.all(
                    color: isDark
                        ? AppColors.bgDeep
                        : AppColors.white,
                    width: 2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: AppColors.primary,
                  size: 17,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          fullName.isEmpty ? 'Your profile' : fullName,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.white : AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          phoneNumber.isEmpty ? 'Phone number unavailable' : phoneNumber,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textDescription : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

/// ---------------------------------------------------------------------
/// A titled section of menu rows ("Account Overview" / "Support & Settings")
/// ---------------------------------------------------------------------
class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  final bool isDark;

  const _MenuSection({
    required this.title,
    required this.items,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textDescription
                        : AppColors.textSecondary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MenuRow(item: item, isDark: isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final _MenuItem item;
  final bool isDark;
  const _MenuRow({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.cardFill : AppColors.white;
    final cardBorderColor = isDark
        ? AppColors.cardBorder
        : const Color(0xFFE5E7EB);

    Future<void> navigateToPage() async {
      if (item.menupage == 'LoginScreen') {
        // A cart is account-scoped. Clear local state before replacing tokens
        // so it cannot be shown to whoever signs in next.
        CartService.resetLocalState();
        await AuthService.logout();
        if (!context.mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
        return;
      }

      Widget? targetPage;
      switch (item.menupage) {
        case 'WishlistScreen()':
          targetPage = const Wishlistscreen();
          break;
        case 'SavedShopScreen()':
          targetPage = const SavedRestaurantsScreen();
          break;
        case 'OrderScreen':
          targetPage = const OrdersScreen();
          break;
        case 'HelpScreen':
          targetPage = const HelpSupportScreen();
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item.title} feature coming soon!'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
          return;
      }

      Navigator.push(context, MaterialPageRoute(builder: (_) => targetPage!));
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.black.withValues(alpha: 0.2)
                : AppColors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: navigateToPage,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: item.iconColor.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.iconColor, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                          color: item.destructive
                              ? AppColors.nonVegRed
                              : (isDark
                                    ? AppColors.white
                                    : AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.subtitle,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: item.destructive
                              ? AppColors.nonVegRed.withValues(alpha: 0.7)
                              : (isDark
                                    ? AppColors.textDescription
                                    : AppColors.materialGrey[600]),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: item.destructive
                      ? AppColors.nonVegRed.withValues(alpha: 0.5)
                      : (isDark
                            ? AppColors.textDescription
                            : AppColors.materialGrey[400]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Bottom navigation bar (standalone mode)
/// ---------------------------------------------------------------------
class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = [
      (Icons.home_rounded, 'Home'),
      (Icons.local_offer_rounded, 'Deals'),
      null, // gap for the FAB
      (Icons.favorite_rounded, 'Saved'),
      (Icons.person_rounded, 'Profile'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDeep : AppColors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.cardBorder
                : AppColors.borderLight,
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(items.length, (i) {
              final item = items[i];
              if (item == null) {
                return const SizedBox(width: 56);
              }
              final (icon, label) = item;
              final selected = i == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 22,
                        color: selected
                            ? AppColors.primary
                            : (isDark
                                  ? AppColors.textDescription
                                  : AppColors.materialGrey[400]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected
                              ? AppColors.primary
                              : (isDark
                                    ? AppColors.textDescription
                                    : AppColors.materialGrey[400]),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

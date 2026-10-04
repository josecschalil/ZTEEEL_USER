import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zteel_user/screens/QrScreen.dart';
import '../services/redemption_service.dart';

class RecentOrderColors {
  static const primary = Color(0xFFEE5B2B);
  static const bgLight = Color(0xFFFAFAFC);
  static const bgDark = Color(0xFF1E1714);
  static const cardLight = Colors.white;
  static const cardDark = Color(0xFF281E19);
  static const borderLight = Color(0xFFF0F0F3);
  static const borderDark = Color(0xFF3D2B23);
  static const textMutedDark = Color(0xFFC9A092);
}

class OrdersScreen extends StatefulWidget {
  final int initialTabIndex;
  const OrdersScreen({super.key, this.initialTabIndex = 0});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

typedef RecentOrderScreen = OrdersScreen;

class _OrdersScreenState extends State<OrdersScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final PageController _pageController;
  late int _selectedTab;
  bool _isLoading = false;
  Timer? _poller;
  List<RedemptionSessionData> _allOrders = [];

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTabIndex;
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
    _pageController = PageController(initialPage: widget.initialTabIndex);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      _pageController.animateToPage(
        _tabController.index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _selectedTab = _tabController.index);
    });
    _loadOrders();
    _startPolling();
  }

  void _switchToTab(int index) {
    if (index >= 0 && index < 3 && mounted) {
      setState(() => _selectedTab = index);
      _tabController.animateTo(index);
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _startPolling() {
    _poller?.cancel();
    _poller = Timer.periodic(const Duration(milliseconds: 2000), (_) {
      if (!mounted) return;
      _loadOrders(silent: true);
    });
  }

  Future<void> _loadOrders({bool silent = false}) async {
    if (!silent && _allOrders.isEmpty) {
      setState(() => _isLoading = true);
    }
    final orders = await RedemptionService.getCustomerRedemptions();
    if (mounted) {
      setState(() {
        _allOrders = orders;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _poller?.cancel();
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openOrderDetails(RedemptionSessionData session) async {
    final result = await Navigator.of(
      context,
    ).push<bool>(
      MaterialPageRoute(
        builder: (_) => RedeemQrScreen(
          session: session,
          openedFromOrdersScreen: true,
        ),
      ),
    );
    await _loadOrders(silent: true);
    if (result == true && mounted) {
      _switchToTab(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pending = _allOrders.where((o) => o.isPending).toList();
    final completed = _allOrders.where((o) => o.isConfirmed).toList();
    final expired = _allOrders.where((o) => o.isExpired).toList();

    return Scaffold(
      backgroundColor: isDark ? RecentOrderColors.bgDark : RecentOrderColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // ── Sticky header (top bar + title + tab bar) ──────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildTopBar(),
                  const SizedBox(height: 28),
                  _buildPageHeader(),
                  const SizedBox(height: 24),
                  _buildTabBar(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            // ── Swipeable tab pages ────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: RecentOrderColors.primary),
                    )
                  : PageView(
                      controller: _pageController,
                      physics: const ClampingScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() => _selectedTab = index);
                        _tabController.animateTo(index);
                      },
                      children: [
                        _buildTabPage(_buildOrderList(pending, 'No pending orders at the moment.')),
                        _buildTabPage(_buildOrderList(completed, 'No completed orders yet.')),
                        _buildTabPage(_buildOrderList(expired, 'No expired orders right now.')),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabPage(List<Widget> children) {
    return RefreshIndicator(
      color: RecentOrderColors.primary,
      onRefresh: () => _loadOrders(silent: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  List<Widget> _buildOrderList(List<RedemptionSessionData> orders, String emptyMsg) {
    if (orders.isEmpty) {
      return [_buildEmptyState(emptyMsg)];
    }
    final list = <Widget>[];
    for (final order in orders) {
      list.add(_buildOrderCard(order));
      list.add(const SizedBox(height: 16));
    }
    if (list.isNotEmpty && list.last is SizedBox) {
      list.removeLast();
    }
    return list;
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF3D1F10),
              ),
              child: const Icon(
                Icons.restaurant_rounded,
                color: RecentOrderColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'My Orders',
              style: TextStyle(
                color: Color(0xFF1C1B1A),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: _loadOrders,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F5F3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: Color(0xFFEF5A4C),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Orders',
          style: TextStyle(
            color: Color(0xFF1C1B1A),
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Track your active redemptions and dining vouchers.',
          style: TextStyle(
            color: Color(0xFF5C5751),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    const tabs = ['Pending', 'Completed', 'Expired'];
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final selected = _selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                setState(() => _selectedTab = i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFFEF5A4C) : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                alignment: Alignment.center,
                child: Text(
                  tabs[i],
                  style: TextStyle(
                    color: selected
                        ? const Color.fromARGB(255, 252, 252, 252)
                        : const Color(0xFF5C5751),
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFECEAE7)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            color: Color(0xFFC9A092),
            size: 36,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF5C5751),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(RedemptionSessionData session) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? RecentOrderColors.cardDark : RecentOrderColors.cardLight;
    final borderCol = isDark ? RecentOrderColors.borderDark : RecentOrderColors.borderLight;

    final cleanQr = session.qrCode.replaceAll('-', '').toUpperCase();
    final shortId = cleanQr.length >= 8
        ? cleanQr.substring(0, 8)
        : (cleanQr.isNotEmpty ? cleanQr : 'C571267D');

    final isConfirmed = session.isConfirmed;
    final isPending = session.isPending;

    return GestureDetector(
      onTap: () => _openOrderDetails(session),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderCol, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORDER #$shortId',
                      style: const TextStyle(
                        color: Color(0xFF5C5751),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                    if (session.vendor != null)
                      Text(
                        session.vendor!.businessName,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF1C1B1A),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                GestureDetector(
                  onTap: () => _openOrderDetails(session),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPending
                          ? RecentOrderColors.primary.withValues(alpha: 0.1)
                          : (isConfirmed ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isPending ? 'Show QR' : 'Show Details',
                      style: TextStyle(
                        color: isPending ? const Color(0xFFEF5A4C) : (isConfirmed ? Colors.green : Colors.grey),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Order items
            for (int i = 0; i < session.items.length && i < 2; i++) ...[
              _buildItemRow(session.items[i]),
              if (i < session.items.length - 1 && i < 1)
                const SizedBox(height: 12),
            ],

            if (session.items.length > 2) ...[
              const SizedBox(height: 8),
              Text(
                '+ ${session.items.length - 2} more items',
                style: const TextStyle(
                  color: Color(0xFF8A8A9A),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],

            const SizedBox(height: 16),
            const Divider(color: Color(0xFFECEAE7), thickness: 1),
            const SizedBox(height: 12),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1714) : const Color(0xFFFAFAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF3D2B23) : const Color(0xFFF0F0F3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isConfirmed
                            ? Icons.verified_rounded
                            : (isPending ? Icons.timer_outlined : Icons.cancel_outlined),
                        color: isConfirmed
                            ? const Color(0xFF1D9E6B)
                            : (isPending ? RecentOrderColors.primary : Colors.grey),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isConfirmed
                                ? 'Redeemed Successfully'
                                : (isPending ? 'Active QR Code' : 'Order ${session.status.toUpperCase()}'),
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1E1714),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isConfirmed
                                ? 'Redemption verified'
                                : (isPending ? 'Show at restaurant' : 'Session closed'),
                            style: TextStyle(
                              fontSize: 9.5,
                              color: isDark ? RecentOrderColors.textMutedDark : const Color(0xFF8A8A9A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'TOTAL VALUE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isDark ? RecentOrderColors.textMutedDark : const Color(0xFF8A8A9A),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$${session.finalTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: RecentOrderColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(RedemptionItem item) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 48,
            height: 48,
            color: const Color(0xFFECEAE7),
            child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                ? Image.network(
                    item.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.restaurant,
                      color: Color(0xFFEF5A4C),
                      size: 20,
                    ),
                  )
                : const Icon(
                    Icons.restaurant,
                    color: Color(0xFFEF5A4C),
                    size: 20,
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF1C1B1A),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.note,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF5C5751),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Text(
          'x${item.quantity}',
          style: const TextStyle(
            color: Color(0xFF5C5751),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

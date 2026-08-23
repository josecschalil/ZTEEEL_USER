import 'package:flutter/material.dart';
import 'package:zteel_user/screens/QrScreen.dart';

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
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

typedef RecentOrderScreen = OrdersScreen;

class _OrdersScreenState extends State<OrdersScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final PageController _pageController;
  int _selectedTab = 0;
  bool _order1Completed = false;
  bool _order2Completed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController();
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      _pageController.animateToPage(
        _tabController.index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _selectedTab = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _openOrder1Details() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const QrScreen()));
  }

  void _openOrder2Details() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const QrScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
              child: PageView(
                controller: _pageController,
                physics: const ClampingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _selectedTab = index);
                  _tabController.animateTo(index);
                },
                children: [
                  _buildTabPage(_pendingPageContent()),
                  _buildTabPage(_completedPageContent()),
                  _buildTabPage(_expiredPageContent()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Wraps a list of widgets in a scrollable page
  Widget _buildTabPage(List<Widget> children) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  // ── Tab content builders ───────────────────────────────────
  List<Widget> _pendingPageContent() {
    final cards = <Widget>[];
    if (!_order1Completed) {
      cards.add(_buildOrderCard1());
      cards.add(const SizedBox(height: 16));
    }
    if (!_order2Completed) {
      cards.add(_buildOrderCard2());
      cards.add(const SizedBox(height: 16));
    }
    if (cards.isEmpty) {
      return [_buildEmptyState('No pending orders at the moment.')];
    }
    if (cards.last is SizedBox) cards.removeLast();
    return cards;
  }

  List<Widget> _completedPageContent() {
    final cards = <Widget>[];
    if (_order1Completed) {
      cards.add(_buildOrderCard1());
      cards.add(const SizedBox(height: 16));
    }
    if (_order2Completed) {
      cards.add(_buildOrderCard2());
      cards.add(const SizedBox(height: 16));
    }
    if (cards.isEmpty) {
      return [_buildEmptyState('No completed orders yet.')];
    }
    if (cards.last is SizedBox) cards.removeLast();
    return cards;
  }

  List<Widget> _expiredPageContent() {
    return [_buildEmptyState('No expired orders right now.')];
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
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1476124369491-e7addf5db371?w=200',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Saffron Bistro',
              style: TextStyle(
                color: Color(0xFF1C1B1A),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Color(0xFFF7F5F3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: Color(0xFFEF5A4C),
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Orders',
          style: TextStyle(
            color: Color(0xFF1C1B1A),
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Track your culinary journey with us.',
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
        color: Color(0xFFFFFFFF),
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
                  color: selected ? Color(0xFFEF5A4C) : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                alignment: Alignment.center,
                child: Text(
                  tabs[i],
                  style: TextStyle(
                    color: selected
                        ? const Color.fromARGB(255, 252, 252, 252)
                        : Color(0xFF5C5751),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Color(0xFFECEAE7)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF5C5751),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildOrderCard1() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? RecentOrderColors.cardDark : RecentOrderColors.cardLight;
    final borderCol = isDark ? RecentOrderColors.borderDark : RecentOrderColors.borderLight;

    return GestureDetector(
      onTap: _openOrder1Details,
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
                Text(
                  'ORDER #SB-9021',
                  style: TextStyle(
                    color: Color(0xFF5C5751),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                GestureDetector(
                  onTap: _openOrder1Details,
                  child: const Text(
                    'Show Details',
                    style: TextStyle(
                      color: Color(0xFFEF5A4C),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Item 1
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 52,
                    height: 52,
                    color: Color(0xFFECEAE7),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1476124369491-e7addf5db371?w=200',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.restaurant,
                        color: Color(0xFFEF5A4C),
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Saffron Infused Risotto',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF1C1B1A),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Extra spice, No onions',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF5C5751),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'x1',
                  style: TextStyle(
                    color: Color(0xFF5C5751),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Item 2
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 52,
                    height: 52,
                    color: Color(0xFFECEAE7),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1551538827-9c037cb4f32a?w=200',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.local_bar,
                        color: Color(0xFFEF5A4C),
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Midnight Spritz',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF1C1B1A),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Standard serve',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF5C5751),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'x2',
                  style: TextStyle(
                    color: Color(0xFF5C5751),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Divider(color: Color(0xFFECEAE7), thickness: 1),
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
                      const Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF1D9E6B),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Redeemed Successfully',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1E1714),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Redemption verified',
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
                      const Text(
                        '\$48.50',
                        style: TextStyle(
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

  Widget _buildOrderCard2() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? RecentOrderColors.cardDark : RecentOrderColors.cardLight;
    final borderCol = isDark ? RecentOrderColors.borderDark : RecentOrderColors.borderLight;

    return GestureDetector(
      onTap: _openOrder2Details,
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
                Text(
                  'ORDER #SB-8842',
                  style: TextStyle(
                    color: Color(0xFF5C5751),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                GestureDetector(
                  onTap: _openOrder2Details,
                  child: const Text(
                    'Show Details',
                    style: TextStyle(
                      color: Color(0xFFEF5A4C),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Item
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 52,
                    height: 52,
                    color: Color(0xFFECEAE7),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=200',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.eco,
                        color: Color(0xFFEF5A4C),
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bistro Signature Salad',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF1C1B1A),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Vegan option',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF5C5751),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'x3',
                  style: TextStyle(
                    color: Color(0xFF5C5751),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 52,
                    height: 52,
                    color: Color(0xFFECEAE7),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1544025162-d76694265947?w=200',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.rice_bowl,
                        color: Color(0xFFEF5A4C),
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Herbed Rice Bowl',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF1C1B1A),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'No mushrooms',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF5C5751),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'x1',
                  style: TextStyle(
                    color: Color(0xFF5C5751),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(color: Color(0xFFECEAE7), thickness: 1),
            const SizedBox(height: 14),

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
                      const Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF1D9E6B),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Redeemed Successfully',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1E1714),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Redemption verified',
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
                      const Text(
                        '\$62.00',
                        style: TextStyle(
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
}

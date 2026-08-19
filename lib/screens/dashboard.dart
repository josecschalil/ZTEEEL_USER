import 'package:flutter/material.dart';
import 'ProfileScreen.dart';
import '../widgets/bottom_nav_bar.dart';

class AppColorss {
  static const primary = Color(0xFFEE5B2B);
  static const backgroundLight = Color(0xFFFAFAFC);
  static const backgroundDark = Color(0xFF1E1714);
  static const cardDark = Color(0xFF281E19);
  static const borderDark = Color(0xFF3D2B23);
  static const navBarDark = Color(0xFF2E201B);
  static const mutedTextDark = Color(0xFFC9A092);

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
class FoodCategory {
  final String label;
  final String imageUrl;
  const FoodCategory(this.label, this.imageUrl);
}

class Deal {
  final String title;
  final String restaurant;
  final String distance;
  final String discount;
  final String timeLeft;
  final String imageUrl;
  const Deal({
    required this.title,
    required this.restaurant,
    required this.distance,
    required this.discount,
    required this.timeLeft,
    required this.imageUrl,
  });
}

class Restaurant {
  final String name;
  final String cuisine;
  final double rating;
  final String distanceKm;
  final String etaMinutes;
  final bool isOpen; // drives the green/red status dot
  final String imageUrl;
  const Restaurant({
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.distanceKm,
    required this.etaMinutes,
    required this.isOpen,
    required this.imageUrl,
  });
}

/// ---------------------------------------------------------------------
/// Sample content
/// ---------------------------------------------------------------------
const _categories = [
  FoodCategory(
    'Pizza',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCEeewmi3-B0_HyhZE7-KrPuhB9ziibuuP3X2GBctJZwruo3FPJYxvF6rqi9sdQasDZ0Aem-OWXMLd2xiFMaWmnhNxOciGM-Rz5H8sxMov2-9Vnsj8R5QR30a0gMM3Ad2VL8Yv2V7fZTjDGD3ETQF711A4UvhrNsuWkJaWITFTwQllmbojft5wvLhayPUIRSOHuB9UXN2N-qC1S69k2fwLa7whFZY2Aq84d3HcSGv9AZLvll4uTnwI_5kKkDvO3XBPwi7q5WfuxbSvp',
  ),
  FoodCategory(
    'Burger',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuDm4rhOuYJUZrS2Q-tAhxvNsOKSEthV7hKDaXStZB5ugYzYsE1YhBmjXsb1I1LQDb7sAIYAb2TlOmAfzuGbQtwbXkN_M2BW3Enp3zgqsFIXZlnomsNWPgchUgxL9Hb7WdpCsYknYhuCkiQjrOvOpF0EQFbJnRE9L_M9Zw2C-qTcPLWRBJaEnjW2rlSNYJpUFk9dPMN4J6xUGYiurPG_vlnsg06d5tdMOrzUvHa9nPLAy1wmlY1-sloOJhNiDICpDQyTX6i8hR2kjJM3',
  ),
  FoodCategory(
    'Sushi',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuC464_iiquTh2E7j_K39Dv77ncoKxFdFu5dixdE31NXFjOugCC00yvMuOXo13MqUGV4yWa4wH6ly4LGR4hDK-uMBcqt1Dcw3_glQDxO730m7pnYnGRVuAPGQNdAC8uDoRJinvK-CBUJmjrryKN8wqB3xfr5FbVz4VLryP166A8iy0X6yL4e4n6F5WVp_QPwxUfGV4HxnA9ymvbIyoxb5KR06KIE2G-J2ZfXr2hgBYzap6bqm3lwcNXU_A9eVV2-PjuvrAAeN8GGQPIS',
  ),
  FoodCategory(
    'Dessert',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBAGsiyOHEL9kzjdjLoPc_QluAtwODZqKLl4liX7Tv9-sS9XGsXOag1KuSG6zVWs1IeLvDfstM_7RExP1iHzVJ8RooE0bamngjI2G4FChCCwuKK55oMherhSS57eg8e-F2YM0v5zqITcDBcoEWQ_3EfufJIApRPVW7kEIkxb_mu-r5lvi4Rmrowc5_-QylgdHXPOzvfD0iFNCKLgPGry9UpIv8ymKw-fT_xognstAJYIk6gBISlMIVDptbqXIm96q1fiG72X1onNdRr',
  ),
  FoodCategory(
    'Healthy',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuDmClsr1hF4KsV4W4twDAfsFrWFXTZ31Bxa7mfVfdUCs0mpEoYIEGCv2siSmQFAA152guFfymwnrdoD73-596E3g5ET8A_s3XsiWekws1PKpXu_IHHvfZgnoUZ_4BTvWRzK67yL2dYdaMZb-6JBAwZ4C_T0P7igosFRYybg9KUw_ce7vp3t_CwCBvgpGrpxBt2Eo9OFJJhmApuotN-C6r7ROpiEJzn8l2rrqapZchT_5Az54C7O7VGBsJUSlbkVLlf5DZx_ThzSrlpa',
  ),
  FoodCategory(
    'Drinks',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuC4TMsYLSFBQkrI9u5xigblkckcI8LHPmb4hzatBTTA_woDs5mbG22K4ofQDJKnpztkW1oWLOfVtrinJWQaqDM752MOkeSdHTTu0KDXrHgFDQeEwbqptFRaJO3AfKvIQM0EZ_MWe_JeB23krhW9pXatIJluGQHiO3q6f41_HkULepqwmQ_NIr_5ESJN-jwqQENR9drb1mdylZUv9h7jKs2rq-yxvfpiwu3g8ZqrXDJuKasJnvNZAuRZQ-TEYCm5AEZiyr41hyK8ynSw',
  ),
  FoodCategory(
    'Mexican',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCLTi6pZrVjkpasLqxqqRdUOqtumEU-EjOuOfmBin4Yi1_BEH_70SEBEceJfBceRie4aq2CZ4Uc8M0ZiLoDGLBuWYHI0yHzDOuuVATaHposaWp4VhzTqSEu7t8fZcnRQywkNYtjkyhgfsqSaH2J2dc5f-d9ZTEGX30en9vxxjpGcu_kMReJ_KpDSyFGC0KyTRtZlBmD-9RXRgkpplz3VyBj_vgaWimGr4vobu099Jb-gULJxDCTtNJB4gVGLg5jxB5HDYHQnr6Jq1cP',
  ),
  FoodCategory(
    'Asian',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCuKK9VXgMM6b9d_slglf8P8EAcluFthQt6SiDQEeexs7IMPfsZt_8GOqMVxhGErdf5TNGGJavG6C3ctGZ0bz2Jaa7TdrEmkKxtILLYtQ7wwD-HO-AqKwjTOOV_ukWi6YZ-vUNsE1j0aPNarFoBcpGn7bY0-HnDJgYOWOp1XLa6JgYohu4Sj7epk4DDA-3f42nvjl9YfQuL1vWzqIHSQXxmCRC8tVs-elFzJp9J6BzdErNEYwuq2krIHY01Mn13VHRUVE3lW_Sg8G8H',
  ),
];

const _deals = [
  Deal(
    title: 'Cheesy Delight Pizza',
    restaurant: 'Pizza Hut',
    distance: '1.2km away',
    discount: '20% OFF',
    timeLeft: '2h left',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBJSMfmwvvapG0ZHxYVePZV8uQK-WLKaOEBlNU9foogkBwzEY19ieziXMxOYMCX9IYuRqVLhcqWCTifN7QdZEEqEN8lDswHzWTC85QA716MmM_ZSZMnzW02rcdwwDJooMYoPnPnf3aPk-VikoWOdXQ20ZaHpC25Efb0cY9Ny4akg6_z0o_MckdyPF8P-9Pc5aqeflowj9BIXYHyx56_gOS9liUE9vu4vySXUoDz4bJZ3C_YHKPo8OqOLiFZ4ZtqCMc5fqX9v0UzPaKn',
  ),
  Deal(
    title: 'Double Beef Smash',
    restaurant: 'Burger King',
    distance: '0.8km away',
    discount: '50% OFF',
    timeLeft: '45m left',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAQajB08E40GIXc8XWyyyJMRfiC-vn1pldnjNsBeT4QKpDSVuRPNQiF_8Xk7LRwrIYXJxmOvomxzJt0g1Mb_vFTw03CabQfXbrnowLWkLGvTcQApK-VYIWfGXD-eU6-Mr2ZxcrCB1y52q3uNdCnHoOtbB4c0y3OXzn8IKuMQUNSr1UiZok0k27xh3YuHhZJLw9l1ZPXTbm4vGTIpX6ZbJuOTXN3CMD3aNLeddYUY_4mTJJjgQW83l3ZJlgse1qM9CR25MIsOBKXjG7p',
  ),
  Deal(
    title: 'Morning Berry Bowl',
    restaurant: 'Fresh & Green',
    distance: '2.5km away',
    discount: '15% OFF',
    timeLeft: '5h left',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuD4yhPin6dzd-0bzsMiqqxvvUt4eAfu6HTxkb3DYB2THXb5sagbjYSFDbkvCxjzxusQ5dWZfaRvXoq8qyJ8ACdiGbOtBoi4StQfmdpWtxfMDDOKxb_FfqRgdCmcx7tEt6Jg4w6nZRHbKit8KD9do6rpyv5ztqJla4UiiAJPNjRWxApaV0lYy8kQYFKgSmBBeW6U6yndkJdUiE4s9N6gPfR91oID-PtuospqsPqEOBlETl8irRRgka1_hH9yTIY8UvuntkKdc5zVoqO7',
  ),
];

const _restaurants = [
  Restaurant(
    name: 'La Bella Italia',
    cuisine: 'Italian • Pasta • Pizza',
    rating: 4.8,
    distanceKm: '1.2 km',
    etaMinutes: '20 min',
    isOpen: true,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCSrAnq8EYT5wnPYsBKM4M5us1vIvfGA30eMn3GSPlJqfTEM7v4960LrWnx8xNtMKP3B6QkCmCMz9PueCntKEAWezbE30-Nlx4xzksuUO6xye8VEtwJvvu5W2Jfaa2Wg61Bs3NkBJICRQncyjqcMuKJ1DiT5JsUzgeiM3cY4Dg2L2N9tVCdHZ3pW2xfXw-GTFilmX0l0T8cSYCg574ublg6gZavHvJXBX9gFRHjGb48u0xk09SGDqsYSP2HrjG1pqlCek7-N0UWX17y',
  ),
  Restaurant(
    name: 'Sushi Master',
    cuisine: 'Japanese • Sushi • Asian',
    rating: 4.5,
    distanceKm: '2.5 km',
    etaMinutes: '35 min',
    isOpen: false,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAV4KaIk0LA9cH24ERImPnDkVz--7lPo2L7pPtM2ILiJhfh0K-ySZfynaoy-RmSiB3YFvtnAnPgcgPfxjk45wiAgrcxPmrls2BXXRcdQnbRRgFR7aO9gJoJkN__NYftVngo4SuuITMfTf85wsWZCjZcqAyWW-PyFiSMPAudLaT6684M6XG-yZXkly9UGMXJTmTNaiTlqXPlC1po5TviR3F0hRBE_griI99iN1Erc2ovBo4HTf-eA3ZswrpbBD4rOHvkOhMP92rss5OE',
  ),
  Restaurant(
    name: 'The Smokehouse',
    cuisine: 'American • BBQ • Grill',
    rating: 4.9,
    distanceKm: '3.0 km',
    etaMinutes: '40 min',
    isOpen: true,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBYqdb8-9dmDhLNbRhUZwKxFHXjz7Y4vohYf_W8xFGxw9kTwBHveqIdCkrTHUQFaxTmEKqlWLgb-g07hckDwyvI3EPQVd3yfOyVhYftbNZTfrukzHIIF1mz8wheRiNmvKSKP5jfdisKF6Q9AqcHT4mQn639vumXdwgcHeA5Cwp-7jEXE5VN06kcFAgxiMEPHNL6fnBGJ-owFJCNfjFr7-zH4-urFCgqol1C4sA1vL_GrWomz0r_eUCrXltx83sxyhzUlNVuKq2S8fzN',
  ),
];

/// ---------------------------------------------------------------------
/// Main Dashboard Screen Shell (Handling page swapping across bottom nav)
/// ---------------------------------------------------------------------
class HomeDiscoveryScreen extends StatefulWidget {
  const HomeDiscoveryScreen({super.key});

  @override
  State<HomeDiscoveryScreen> createState() => _HomeDiscoveryScreenState();
}

class _HomeDiscoveryScreenState extends State<HomeDiscoveryScreen> {
  int _navIndex = 0;

  void _showScanModal(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColorss.cardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: isDark ? AppColorss.borderDark : const Color(0xFFEEEEEE),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColorss.primary.withAlpha(isDark ? 35 : 20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                size: 56,
                color: AppColorss.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Scan QR Code',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1D1E20),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Align the QR code within the frame to redeem offers or view restaurant menus instantly.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColorss.mutedTextDark : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
                label: const Text(
                  'Open Camera',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorss.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> pages = [
      _HomeDiscoveryView(isDark: isDark),
      _DealsView(isDark: isDark),
      const SizedBox.shrink(), // Index 2 reserved for central FAB Scan button
      _SavedView(isDark: isDark),
      ProfileScreen(
        showBottomNav: false,
        onBack: () => setState(() => _navIndex = 0),
      ),
    ];

    final bool showNav = _navIndex != 4;

    return Scaffold(
      backgroundColor: isDark
          ? AppColorss.backgroundDark
          : AppColorss.backgroundLight,
      body: IndexedStack(index: _navIndex, children: pages),
      bottomNavigationBar: showNav
          ? AppBottomNavBar(
              isDark: isDark,
              currentIndex: _navIndex,
              onTap: (i) {
                if (i == 2) {
                  _showScanModal(context, isDark);
                } else {
                  setState(() => _navIndex = i);
                }
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: showNav
          ? GestureDetector(
              onTap: () => _showScanModal(context, isDark),
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColorss.primary,
                  border: Border.all(
                    color: isDark ? AppColorss.backgroundDark : Colors.white,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColorss.primary.withAlpha(110),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            )
          : null,
    );
  }
}

/// ---------------------------------------------------------------------
/// Home Discovery Tab Content (Index 0)
/// ---------------------------------------------------------------------
class _HomeDiscoveryView extends StatelessWidget {
  final bool isDark;
  const _HomeDiscoveryView({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _Header(isDark: isDark),
          _SearchBar(isDark: isDark),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 28),
              children: [
                const SizedBox(height: 12),
                const _SectionHeader(title: 'Popular Food Items'),
                const SizedBox(height: 14),
                _PopularFoodGrid(isDark: isDark),
                const SizedBox(height: 28),
                const _SectionHeader(title: 'Hot Deals Near You 🔥'),
                const SizedBox(height: 14),
                _HotDealsRow(),
                const SizedBox(height: 28),
                const _SectionHeader(title: 'Best Restaurants'),
                const SizedBox(height: 14),
                _BestRestaurantsList(isDark: isDark),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Deals Tab Content (Index 1)
/// ---------------------------------------------------------------------
class _DealsView extends StatelessWidget {
  final bool isDark;
  const _DealsView({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exclusive Deals 🔥',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: isDark ? Colors.white : const Color(0xFF1D1E20),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColorss.primary.withAlpha(isDark ? 35 : 20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '3 Active',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColorss.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              itemCount: _deals.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, i) {
                final deal = _deals[i];
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(deal.imageUrl, fit: BoxFit.cover),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withAlpha(220),
                                Colors.black.withAlpha(100),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.55, 1.0],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 14,
                          left: 14,
                          child: _Badge(text: deal.discount, filled: true),
                        ),
                        Positioned(
                          top: 14,
                          right: 14,
                          child: _Badge(
                            text: deal.timeLeft,
                            filled: false,
                            icon: Icons.timer_outlined,
                          ),
                        ),
                        Positioned(
                          bottom: 14,
                          left: 14,
                          right: 14,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                deal.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${deal.restaurant} • ${deal.distance}',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(210),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
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
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Saved Tab Content (Index 3)
/// ---------------------------------------------------------------------
class _SavedView extends StatelessWidget {
  final bool isDark;
  const _SavedView({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saved Restaurants ❤️',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: isDark ? Colors.white : const Color(0xFF1D1E20),
                  ),
                ),
                Text(
                  '${_restaurants.length} Items',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColorss.mutedTextDark : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              itemCount: _restaurants.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                return _RestaurantCard(
                  restaurant: _restaurants[i],
                  isDark: isDark,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Header: location + notification bell
/// ---------------------------------------------------------------------
class _Header extends StatelessWidget {
  final bool isDark;
  const _Header({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColorss.primary.withAlpha(isDark ? 35 : 20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: AppColorss.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURRENT LOCATION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: isDark
                          ? AppColorss.mutedTextDark
                          : const Color(0xFF8E8E93),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'New York, USA',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1D1E20),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: isDark
                            ? AppColorss.mutedTextDark
                            : Colors.grey[600],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Stack(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColorss.cardDark : Colors.white,
                  border: Border.all(
                    color: isDark
                        ? AppColorss.borderDark
                        : const Color(0xFFEEEEEE),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withAlpha(80)
                          : Colors.black.withAlpha(15),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: isDark ? Colors.grey[200] : Colors.grey[800],
                  size: 22,
                ),
              ),
              Positioned(
                top: 9,
                right: 11,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColorss.primary,
                    border: Border.all(
                      color: isDark ? AppColorss.cardDark : Colors.white,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Search bar
/// ---------------------------------------------------------------------
class _SearchBar extends StatelessWidget {
  final bool isDark;
  const _SearchBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 10),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColorss.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColorss.borderDark : const Color(0xFFEFEFEF),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withAlpha(90)
                  : Colors.black.withAlpha(14),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: 'Search food or restaurants...',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Colors.grey[400],
              size: 22,
            ),
            suffixIcon: Container(
              margin: const EdgeInsets.all(6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColorss.primary.withAlpha(isDark ? 35 : 20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: AppColorss.primary,
                size: 18,
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Section header with "See All"
/// ---------------------------------------------------------------------
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: isDark ? Colors.white : const Color(0xFF1D1E20),
            ),
          ),
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(6),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                'See All',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                  color: AppColorss.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Popular food items (4-column grid of round avatars)
/// ---------------------------------------------------------------------
class _PopularFoodGrid extends StatelessWidget {
  final bool isDark;
  const _PopularFoodGrid({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 18,
          crossAxisSpacing: 16,
          childAspectRatio: 0.78,
        ),
        itemBuilder: (context, i) {
          final c = _categories[i];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 66,
                height: 66,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColorss.cardDark : Colors.white,
                  border: Border.all(
                    color: isDark
                        ? AppColorss.borderDark
                        : const Color(0xFFF0F0F2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withAlpha(70)
                          : Colors.black.withAlpha(12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(c.imageUrl, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                c.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                  color: isDark ? Colors.grey[200] : const Color(0xFF2D2D2D),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Hot deals horizontal scroll cards
/// ---------------------------------------------------------------------
class _HotDealsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 196,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _deals.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, i) => _DealCard(deal: _deals[i]),
      ),
    );
  }
}

class _DealCard extends StatelessWidget {
  final Deal deal;
  const _DealCard({required this.deal});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 285,
      height: 196,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(deal.imageUrl, fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withAlpha(220),
                    Colors.black.withAlpha(100),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 14,
              child: _Badge(text: deal.discount, filled: true),
            ),
            Positioned(
              top: 14,
              right: 14,
              child: _Badge(
                text: deal.timeLeft,
                filled: false,
                icon: Icons.timer_outlined,
              ),
            ),
            Positioned(
              bottom: 14,
              left: 14,
              right: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    deal.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      letterSpacing: -0.3,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${deal.restaurant} • ${deal.distance}',
                    style: TextStyle(
                      color: Colors.white.withAlpha(210),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
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

class _Badge extends StatelessWidget {
  final String text;
  final bool filled;
  final IconData? icon;
  const _Badge({required this.text, required this.filled, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? AppColorss.primary : Colors.black.withAlpha(120),
        borderRadius: BorderRadius.circular(8),
        border: filled
            ? null
            : Border.all(color: Colors.white.withAlpha(50), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Best restaurants list
/// ---------------------------------------------------------------------
class _BestRestaurantsList extends StatelessWidget {
  final bool isDark;
  const _BestRestaurantsList({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: _restaurants
            .map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _RestaurantCard(restaurant: r, isDark: isDark),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final bool isDark;
  const _RestaurantCard({required this.restaurant, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColorss.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColorss.borderDark : const Color(0xFFF0F0F3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(80)
                : Colors.black.withAlpha(12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              restaurant.imageUrl,
              width: 92,
              height: 92,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: SizedBox(
              height: 92,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1D1E20),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColorss.primary.withAlpha(isDark ? 45 : 20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: AppColorss.primary,
                              size: 14,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              restaurant.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: AppColorss.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    restaurant.cuisine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColorss.mutedTextDark
                          : Colors.grey[600],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.near_me_outlined,
                            size: 15,
                            color: isDark
                                ? AppColorss.mutedTextDark
                                : Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.distanceKm,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColorss.mutedTextDark
                                  : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Icon(
                            Icons.access_time_rounded,
                            size: 15,
                            color: isDark
                                ? AppColorss.mutedTextDark
                                : Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.etaMinutes,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColorss.mutedTextDark
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: restaurant.isOpen
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFEF4444),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (restaurant.isOpen
                                          ? const Color(0xFF22C55E)
                                          : const Color(0xFFEF4444))
                                      .withAlpha(140),
                              blurRadius: 6,
                              spreadRadius: 1,
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
        ],
      ),
    );
  }
}

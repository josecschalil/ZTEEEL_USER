import 'package:flutter/material.dart';

class SearchColors {
  static const primary = Color(0xFFEE5B2B);
  static const backgroundLight = Color(0xFFF8F6F6);
  static const cardLight = Colors.white;
  static const borderLight = Color(0xFFE2E8F0); // slate-200
  static const textPrimary = Color(0xFF0F172A); // slate-900
  static const textSecondary = Color(0xFF64748B); // slate-500
  static const textMuted = Color(0xFF94A3B8); // slate-400

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    fontFamily: 'PlusJakartaSans',
    scaffoldBackgroundColor: backgroundLight,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
  );
}

/// ---------------------------------------------------------------------
/// Data models
/// ---------------------------------------------------------------------
class TrendingTag {
  final String label;
  final String imageUrl;
  final bool highlighted;
  const TrendingTag({
    required this.label,
    required this.imageUrl,
    this.highlighted = false,
  });
}

class SuggestedPlace {
  final String name;
  final String distance;
  final String imageUrl;
  const SuggestedPlace({
    required this.name,
    required this.distance,
    required this.imageUrl,
  });
}

const _filterChips = ['All', 'Food', 'Restaurants', 'Offers', 'Nearby'];

const _trending = [
  TrendingTag(
    label: 'Tacos',
    highlighted: true,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCLTi6pZrVjkpasLqxqqRdUOqtumEU-EjOuOfmBin4Yi1_BEH_70SEBEceJfBceRie4aq2CZ4Uc8M0ZiLoDGLBuWYHI0yHzDOuuVATaHposaWp4VhzTqSEu7t8fZcnRQywkNYtjkyhgfsqSaH2J2dc5f-d9ZTEGX30en9vxxjpGcu_kMReJ_KpDSyFGC0KyTRtZlBmD-9RXRgkpplz3VyBj_vgaWimGr4vobu099Jb-gULJxDCTtNJB4gVGLg5jxB5HDYHQnr6Jq1cP',
  ),
  TrendingTag(
    label: 'Burgers',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDm4rhOuYJUZrS2Q-tAhxvNsOKSEthV7hKDaXStZB5ugYzYsE1YhBmjXsb1I1LQDb7sAIYAb2TlOmAfzuGbQtwbXkN_M2BW3Enp3zgqsFIXZlnomsNWPgchUgxL9Hb7WdpCsYknYhuCkiQjrOvOpF0EQFbJnRE9L_M9Zw2C-qTcPLWRBJaEnjW2rlSNYJpUFk9dPMN4J6xUGYiurPG_vlnsg06d5tdMOrzUvHa9nPLAy1wmlY1-sloOJhNiDICpDQyTX6i8hR2kjJM3',
  ),
  TrendingTag(
    label: 'Pizza',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCEeewmi3-B0_HyhZE7-KrPuhB9ziibuuP3X2GBctJZwruo3FPJYxvF6rqi9sdQasDZ0Aem-OWXMLd2xiFMaWmnhNxOciGM-Rz5H8sxMov2-9Vnsj8R5QR30a0gMM3Ad2VL8Yv2V7fZTjDGD3ETQF711A4UvhrNsuWkJaWITFTwQllmbojft5wvLhayPUIRSOHuB9UXN2N-qC1S69k2fwLa7whFZY2Aq84d3HcSGv9AZLvll4uTnwI_5kKkDvO3XBPwi7q5WfuxbSvp',
  ),
  TrendingTag(
    label: 'Ramen',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCuKK9VXgMM6b9d_slglf8P8EAcluFthQt6SiDQEeexs7IMPfsZt_8GOqMVxhGErdf5TNGGJavG6C3ctGZ0bz2Jaa7TdrEmkKxtILLYtQ7wwD-HO-AqKwjTOOV_ukWi6YZ-vUNsE1j0aPNarFoBcpGn7bY0-HnDJgYOWOp1XLa6JgYohu4Sj7epk4DDA-3f42nvjl9YfQuL1vWzqIHSQXxmCRC8tVs-elFzJp9J6BzdErNEYwuq2krIHY01Mn13VHRUVE3lW_Sg8G8H',
  ),
  TrendingTag(
    label: 'Sushi',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuC464_iiquTh2E7j_K39Dv77ncoKxFdFu5dixdE31NXFjOugCC00yvMuOXo13MqUGV4yWa4wH6ly4LGR4hDK-uMBcqt1Dcw3_glQDxO730m7pnYnGRVuAPGQNdAC8uDoRJinvK-CBUJmjrryKN8wqB3xfr5FbVz4VLryP166A8iy0X6yL4e4n6F5WVp_QPwxUfGV4HxnA9ymvbIyoxb5KR06KIE2G-J2ZfXr2hgBYzap6bqm3lwcNXU_A9eVV2-PjuvrAAeN8GGQPIS',
  ),
];

const _suggested = [
  SuggestedPlace(
    name: 'Italian Feast',
    distance: '2.4 km away',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBJSMfmwvvapG0ZHxYVePZV8uQK-WLKaOEBlNU9foogkBwzEY19ieziXMxOYMCX9IYuRqVLhcqWCTifN7QdZEEqEN8lDswHzWTC85QA716MmM_ZSZMnzW02rcdwwDJooMYoPnPnf3aPk-VikoWOdXQ20ZaHpC25Efb0cY9Ny4akg6_z0o_MckdyPF8P-9Pc5aqeflowj9BIXYHyx56_gOS9liUE9vu4vySXUoDz4bJZ3C_YHKPo8OqOLiFZ4ZtqCMc5fqX9v0UzPaKn',
  ),
  SuggestedPlace(
    name: 'Steakhouse Grill',
    distance: '1.8 km away',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAQajB08E40GIXc8XWyyyJMRfiC-vn1pldnjNsBeT4QKpDSVuRPNQiF_8Xk7LRwrIYXJxmOvomxzJt0g1Mb_vFTw03CabQfXbrnowLWkLGvTcQApK-VYIWfGXD-eU6-Mr2ZxcrCB1y52q3uNdCnHoOtbB4c0y3OXzn8IKuMQUNSr1UiZok0k27xh3YuHhZJLw9l1ZPXTbm4vGTIpX6ZbJuOTXN3CMD3aNLeddYUY_4mTJJjgQW83l3ZJlgse1qM9CR25MIsOBKXjG7p',
  ),
];

/// ---------------------------------------------------------------------
/// Main screen
/// ---------------------------------------------------------------------
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  List<String> _recentSearches = [
    'Double Cheese Pepperoni',
    'Sushi Bar Near Me',
    'Vegetarian Bowls',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _removeRecent(String term) {
    setState(() => _recentSearches.remove(term));
  }

  void _clearAllRecent() {
    setState(() => _recentSearches = []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SearchColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _SearchHeader(
              controller: _searchController,
              selectedFilter: _selectedFilter,
              onFilterSelected: (f) => setState(() => _selectedFilter = f),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 8),
                  if (_recentSearches.isNotEmpty)
                    _RecentSearchesSection(
                      terms: _recentSearches,
                      onRemove: _removeRecent,
                      onClearAll: _clearAllRecent,
                    ),
                  const SizedBox(height: 16),
                  _TrendingSection(),
                  const SizedBox(height: 16),
                  _SuggestedSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Sticky header: back button, search field, filter chips
/// ---------------------------------------------------------------------
class _SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;
  const _SearchHeader({
    required this.controller,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: SearchColors.backgroundLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context).maybePop(),
                  style: IconButton.styleFrom(
                    backgroundColor: SearchColors.cardLight,
                    shape: const CircleBorder(),
                  ),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: SearchColors.textSecondary,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: SearchColors.cardLight,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    style: const TextStyle(
                      color: SearchColors.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Pizza, Burger, or Restaurant',
                      hintStyle: const TextStyle(color: SearchColors.textMuted),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: SearchColors.textMuted,
                        size: 20,
                      ),
                      suffixIcon: const Icon(
                        Icons.tune,
                        color: SearchColors.primary,
                        size: 22,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filterChips.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final chip = _filterChips[i];
                final selected = chip == selectedFilter;
                return InkWell(
                  onTap: () => onFilterSelected(chip),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? SearchColors.primary
                          : SearchColors.cardLight,
                      borderRadius: BorderRadius.circular(999),
                      border: selected
                          ? null
                          : Border.all(color: SearchColors.borderLight),
                    ),
                    child: Text(
                      chip,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: selected
                            ? Colors.white
                            : SearchColors.textSecondary,
                      ),
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
/// Recent searches section
/// ---------------------------------------------------------------------
class _RecentSearchesSection extends StatelessWidget {
  final List<String> terms;
  final ValueChanged<String> onRemove;
  final VoidCallback onClearAll;
  const _RecentSearchesSection({
    required this.terms,
    required this.onRemove,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Searches',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: SearchColors.textPrimary,
              ),
            ),
            InkWell(
              onTap: onClearAll,
              child: const Text(
                'Clear All',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: SearchColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        for (final term in terms)
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: SearchColors.borderLight, width: 1),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.history,
                        color: SearchColors.textMuted,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        term,
                        style: const TextStyle(
                          fontSize: 14,
                          color: SearchColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => onRemove(term),
                    child: const Icon(
                      Icons.close,
                      color: SearchColors.textMuted,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------
/// Trending Now — horizontal circular avatars
/// ---------------------------------------------------------------------
class _TrendingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trending Now',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: SearchColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _trending.length,
            separatorBuilder: (_, __) => const SizedBox(width: 20),
            itemBuilder: (context, i) {
              final tag = _trending[i];
              return Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: tag.highlighted ? null : Colors.grey[100],
                      border: tag.highlighted
                          ? Border.all(color: SearchColors.primary, width: 2)
                          : null,
                    ),
                    child: ClipOval(
                      child: Image.network(tag.imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tag.label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: SearchColors.textPrimary,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------
/// Suggested for You — 2-column grid
/// ---------------------------------------------------------------------
class _SuggestedSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suggested for You',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: SearchColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _suggested.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (context, i) {
            final place = _suggested[i];
            return Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: SearchColors.cardLight,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        place.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: SearchColors.textPrimary,
                          ),
                        ),
                        Text(
                          place.distance,
                          style: const TextStyle(
                            fontSize: 12,
                            color: SearchColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

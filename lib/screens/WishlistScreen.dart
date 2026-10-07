import '../app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Data model ───────────────────────────────────────────────────────────────
class DishItem {
  final String id;
  final String restaurant;
  final double distance;
  final String name;
  final double rating;
  final String tag;
  final Color tagColor;
  final double price;
  final String category;
  final String imageUrl;

  const DishItem({
    required this.id,
    required this.restaurant,
    required this.distance,
    required this.name,
    required this.rating,
    required this.tag,
    required this.tagColor,
    required this.price,
    required this.category,
    required this.imageUrl,
  });
}

final List<DishItem> _allItems = [
  DishItem(
    id: '1',
    restaurant: 'The Burger Foundry',
    distance: 0.4,
    name: 'Truffle Wagyu Double Smash',
    rating: 4.9,
    tag: 'Bestseller',
    tagColor: AppColors.toneFF64748B,
    price: 16.50,
    category: 'burgers',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuChJa_7z6FQ4Cc3dqQv_05s5vL0bX8Dv3Imb6RanYxUdzG4RGsiQ04OWyBV4d4TH_-iUKMq8mV2nEe4PnnoB4mxQX-p0KSZ5YmdtJAJgZOvKmwkJFE8HENVh4loQ6sgPIPVOBMwYx8KalMDTh_ndzEdnUcwNTdsEN3Q-F-uyRgqCiKzBk06O2Dkn4woTW_9P9sv3vSiSs1Hw773VV1aDXdo0FdmDv6EfxtnZEimJ030Qdzkklwu8-wZ8A',
  ),
  DishItem(
    id: '2',
    restaurant: 'Aloha Poke & Greens',
    distance: 1.1,
    name: 'Spicy Salmon & Avocado Bowl',
    rating: 4.8,
    tag: 'Gluten-free',
    tagColor: AppColors.toneFF059669,
    price: 14.20,
    category: 'japanese',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCuYBD1euhC3LEdJ0dSm42lJpLpqUQPniU8yiTItfLJHaHdxmtMUxo76C43a6zJg4_xQDjnIHevWAYDqcy85Jq7Hmn1deiJeolmkYpVXlWS0dyU2qVfkd7_vIwVro3FQKJeo9w9Q6mmZR1ThqAG_DjO-Asp6JSTxDaWdxuYPhrwK7WxxPQaFyy8haSMRPxQvWA4Sdnkt-CLU7slQBDUoDWcl6y_0Osojg5JqFxUCaBLTPyT_BRd-XWLiA',
  ),
  DishItem(
    id: '3',
    restaurant: 'Bella Napoli Pizzeria',
    distance: 0.8,
    name: 'Wood-Fired Margherita',
    rating: 4.9,
    tag: 'Wood Oven',
    tagColor: AppColors.toneFF64748B,
    price: 18.00,
    category: 'pizza',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDRyyhlIGP5x6ywi8bDKDJt31j3BTgfpJVLw_4Fxk_SVj-bq1JnuvoXLPFE_LrfndvVMn8NXdJmrxYc5DKpICOhT8qksgqm-wHWxRoDxVj6m7b2chOwKOFrFxPOMtHESct75MjTQwn-hXeFTjbKVsB17s-DwzDydSNLLEqUb87p9BzoiS6d65_K0d3_P1YrYOoK3_TJhnhRmJFOaKwp6cxrsHO1WhcGs8UT9nw-FX_wheVrHb3ibThnag',
  ),
  DishItem(
    id: '4',
    restaurant: 'Ramen Master Shinjuku',
    distance: 1.6,
    name: 'Tonkotsu Black Garlic Ramen',
    rating: 4.7,
    tag: 'Extra Ajitama',
    tagColor: AppColors.toneFF64748B,
    price: 15.80,
    category: 'japanese',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBl3le2yFK8tIF9xJ9oF7n0HQIWMRvsIsrmsBxlFDLAmTd-ZuDBKrX16l1dBCyblp0FaQ92CuZ6W0oEdouxrI1FEamza-J9NsYKUtR5t4RJPgTv9IpHMqoAGWqjsrFkp6X2waVGbBIvF_OshHIC_y1Mhy0Xdvqd1O-vpU6FHMXrl29SbTyt_9vrIGanTLA8tqCS-6owjd_QbW6douHo-oAQtyO5o8OAWa9nFwv1QI3ua54V4PNbyL1Xjg',
  ),
  DishItem(
    id: '5',
    restaurant: 'Kumo Bakery & Cafe',
    distance: 2.2,
    name: 'Matcha Basque Cheesecake',
    rating: 5.0,
    tag: 'Artisanal',
    tagColor: AppColors.toneFF64748B,
    price: 7.50,
    category: 'desserts',
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCqVHlc8mO7cZb0teb5uaEAVGYThfxb4ROaZISvZWiGps2pP9HKo3P12Rk6q3hIOfp-D1f_qY2wDk5PCaNKGc4b-dpmXsKtbFW9OY6rW7rHPlYkgGYeBDYOiDXjztHgnbvw3r_2VuNEl3ZUZwj14YEycvu2jsSiQpgL4aSgBwm0are4HAAlOIBSfgnCCovTM9EGj1JktEXpIPqIWoepMavY7dPQAbpSC1omOcay2F8rRbRtUfdo97UeJQ',
  ),
];

// ─── Saved Screen ─────────────────────────────────────────────────────────────
class Wishlistscreen extends StatefulWidget {
  const Wishlistscreen({super.key});
  @override
  State<Wishlistscreen> createState() => _WishlistscreenState();
}

class _WishlistscreenState extends State<Wishlistscreen> {
  String _activeFilter = 'all';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();
  final Set<String> _addedIds = {};
  late List<DishItem> _items;

  static const _categories = [
    ('all', 'All'),
    ('burgers', 'Burgers'),
    ('japanese', 'Japanese & Bowls'),
    ('pizza', 'Pizza'),
    ('desserts', 'Desserts'),
  ];

  @override
  void initState() {
    super.initState();
    _items = List.from(_allItems);
  }

  List<DishItem> get _filtered => _items.where((d) {
    final matchCat = _activeFilter == 'all' || d.category == _activeFilter;
    final q = _searchQuery.toLowerCase();
    final matchSearch =
        q.isEmpty ||
        d.name.toLowerCase().contains(q) ||
        d.restaurant.toLowerCase().contains(q) ||
        d.tag.toLowerCase().contains(q);
    return matchCat && matchSearch;
  }).toList();

  void _removeItem(String id) {
    setState(() => _items.removeWhere((d) => d.id == id));
  }

  void _toggleAdd(String id) async {
    setState(() => _addedIds.add(id));
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => _addedIds.remove(id));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _refreshWishlist() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: AppColors.toneFFFAFAFB,
      extendBody: true,
      body: Stack(
        children: [
          // ── Scrollable content ─────────────────────────────────────────────
          RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.white,
            onRefresh: _refreshWishlist,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
              // Status bar spacer
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).padding.top + 56,
                ),
              ),
              // Search bar
              SliverToBoxAdapter(
                child: _SearchBar(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  onClear: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                ),
              ),
              // Category pills
              SliverToBoxAdapter(
                child: _CategoryPills(
                  categories: _categories,
                  active: _activeFilter,
                  onSelect: (f) => setState(() => _activeFilter = f),
                ),
              ),
              // Cards
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                sliver: SliverList.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final item = filtered[i];
                    return _DishCard(
                      key: ValueKey(item.id),
                      item: item,
                      isAdded: _addedIds.contains(item.id),
                      onRemove: () => _removeItem(item.id),
                      onAdd: () => _toggleAdd(item.id),
                    );
                  },
                ),
              ),
              // Bottom hint
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.favorite_rounded,
                        size: 14,
                        color: AppColors.toneFF94A3B8,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Tap heart to remove from saved',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.materialGrey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Space for floating cart + nav
              const SliverToBoxAdapter(child: SizedBox(height: 140)),
            ],
          ),
        ),

          // ── Frosted header ─────────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _Header(count: filtered.length),
          ),

          // ── Floating cart dock ─────────────────────────────────────────────
          Positioned(
            bottom:
                kBottomNavigationBarHeight +
                MediaQuery.of(context).padding.bottom +
                8,
            left: 16,
            right: 16,
            child: const _CartDock(),
          ),
        ],
      ),
      // ── Bottom nav ──────────────────────────────────────────────────────────
      bottomNavigationBar: _BottomNav(),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final int count;
  const _Header({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.toneD9FAFAFB,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Saved',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.toneFF0F172A,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.toneFFFFF7ED,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                // Filter button
                _IconBtn(icon: Icons.tune_rounded, onTap: () {}),
                const SizedBox(width: 8),
                // Avatar
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.toneFFF1F5F9,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.toneFFE2E8F0,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'JD',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.toneFF475569,
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

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.toneFFF1F5F9, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: AppColors.toneFF475569),
      ),
    );
  }
}

// ─── Search bar ───────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: AppColors.toneFFE2E8F0.withOpacity(0.7)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.025),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: AppColors.toneFF1E293B,
          ),
          decoration: InputDecoration(
            hintText: 'Search saved dishes & spots...',
            hintStyle: TextStyle(
              color: AppColors.materialGrey.shade400,
              fontWeight: FontWeight.w400,
              fontSize: 13.5,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              size: 20,
              color: AppColors.toneFF94A3B8,
            ),
            suffixIcon: controller.text.isNotEmpty
                ? GestureDetector(
                    onTap: onClear,
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.toneFF94A3B8,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 11),
          ),
        ),
      ),
    );
  }
}

// ─── Category pills ───────────────────────────────────────────────────────────
class _CategoryPills extends StatelessWidget {
  final List<(String, String)> categories;
  final String active;
  final ValueChanged<String> onSelect;

  const _CategoryPills({
    required this.categories,
    required this.active,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final (key, label) = categories[i];
          final isActive = active == key;
          return GestureDetector(
            onTap: () => onSelect(key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.toneFF0F172A : AppColors.white,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: isActive
                      ? AppColors.transparent
                      : AppColors.toneFFE2E8F0,
                  width: 1,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? AppColors.white : AppColors.toneFF475569,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Dish Card ────────────────────────────────────────────────────────────────
class _DishCard extends StatefulWidget {
  final DishItem item;
  final bool isAdded;
  final VoidCallback onRemove;
  final VoidCallback onAdd;

  const _DishCard({
    super.key,
    required this.item,
    required this.isAdded,
    required this.onRemove,
    required this.onAdd,
  });

  @override
  State<_DishCard> createState() => _DishCardState();
}

class _DishCardState extends State<_DishCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _opacityAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _opacityAnim = Tween<double>(begin: 1, end: 0).animate(_animCtrl);
    _scaleAnim = Tween<double>(begin: 1, end: 0.95).animate(_animCtrl);
  }

  void _handleRemove() async {
    await _animCtrl.forward();
    widget.onRemove();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return FadeTransition(
      opacity: _opacityAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.toneFFF1F5F9, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Thumbnail
                _Thumbnail(imageUrl: item.imageUrl, onRemove: _handleRemove),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Restaurant + distance
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.restaurant,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.toneFF64748B,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              '•',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.toneFF94A3B8,
                              ),
                            ),
                          ),
                          Text(
                            '${item.distance} mi',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.toneFF94A3B8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // Dish name
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.toneFF0F172A,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Rating + tag
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.toneFFFFFBEB,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 12,
                                  color: AppColors.toneFFD97706,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  item.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.toneFFD97706,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.tag,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: item.tagColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Price + Add button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.toneFF0F172A,
                            ),
                          ),
                          _AddButton(
                            isAdded: widget.isAdded,
                            onTap: widget.onAdd,
                          ),
                        ],
                      ),
                    ],
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

// ─── Thumbnail ────────────────────────────────────────────────────────────────
class _Thumbnail extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onRemove;
  const _Thumbnail({required this.imageUrl, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 96,
                height: 96,
                color: AppColors.toneFFF1F5F9,
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.06),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  size: 15,
                  color: AppColors.toneFFF43F5E,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Add Button ───────────────────────────────────────────────────────────────
class _AddButton extends StatelessWidget {
  final bool isAdded;
  final VoidCallback onTap;
  const _AddButton({required this.isAdded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isAdded ? AppColors.toneFF059669 : AppColors.primary,
          borderRadius: BorderRadius.circular(99),
          boxShadow: [
            BoxShadow(
              color:
                  (isAdded ? AppColors.toneFF059669 : AppColors.primary)
                      .withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAdded ? Icons.done_rounded : Icons.add_rounded,
              size: 14,
              color: AppColors.white,
            ),
            const SizedBox(width: 3),
            Text(
              isAdded ? 'Added' : 'Add',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Floating Cart Dock ───────────────────────────────────────────────────────
class _CartDock extends StatelessWidget {
  const _CartDock();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.toneFFE2E8F0.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: AppColors.toneFF0F172A.withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.toneFFFFF7ED,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          // Text
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'The Burger Foundry',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.toneFF0F172A,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1),
                Text(
                  '3 items saved from this menu',
                  style: TextStyle(fontSize: 11, color: AppColors.toneFF64748B),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // CTA
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.toneFF0F172A,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Order Spot',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 13,
                    color: AppColors.white,
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

// ─── Bottom Navigation ────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int _current = 1;

  _BottomNav();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.explore_rounded, Icons.explore_outlined, 'Explore'),
      (Icons.favorite_rounded, Icons.favorite_border_rounded, 'Saved'),
      (Icons.receipt_long_rounded, Icons.receipt_long_outlined, 'Orders'),
      (Icons.account_circle_rounded, Icons.account_circle_outlined, 'Profile'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.toneF7FFFFFF,
        border: Border(top: BorderSide(color: AppColors.toneFFF1F5F9, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final (activeIco, idleIco, label) = items[i];
              final isActive = i == _current;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isActive ? activeIco : idleIco,
                        size: 22,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.toneFF94A3B8,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.toneFF94A3B8,
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

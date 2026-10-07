import '../app_typography.dart';
import '../app_colors.dart';
import 'package:flutter/material.dart';
import '../services/saved_restaurant_service.dart';
import 'RestuarantMenuScreen.dart';

export '../services/saved_restaurant_service.dart' show SavedRestaurant;

/// ---------------------------------------------------------------------
/// Light layout using the shared app palette.
/// ---------------------------------------------------------------------

typedef SavedShopScreen = SavedRestaurantsScreen;

enum ViewMode { list, grid }

enum SortMode { recent, ratingHighLow, distanceNearFar, nameAz }

/// ---------------------------------------------------------------------
/// Main screen
/// ---------------------------------------------------------------------
class SavedRestaurantsScreen extends StatefulWidget {
  const SavedRestaurantsScreen({super.key});

  @override
  State<SavedRestaurantsScreen> createState() => _SavedRestaurantsScreenState();
}

class _SavedRestaurantsScreenState extends State<SavedRestaurantsScreen> {
  List<SavedRestaurant> _restaurants = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _selectedCollection; // null = All
  SortMode _sortMode = SortMode.recent;
  ViewMode _viewMode = ViewMode.list;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    if (SavedRestaurantService.cachedSavedRestaurants.isNotEmpty) {
      _restaurants = List.of(SavedRestaurantService.cachedSavedRestaurants);
      _isLoading = false;
      if (mounted) setState(() {});
    }
    final live = await SavedRestaurantService.fetchSavedRestaurants(forceRefresh: true);
    if (!mounted) return;
    setState(() {
      _restaurants = live;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SavedRestaurant> get _visible {
    var list = _restaurants.where((r) {
      final matchesQuery =
          _query.isEmpty ||
          r.name.toLowerCase().contains(_query) ||
          r.cuisine.toLowerCase().contains(_query);
      final matchesCollection =
          _selectedCollection == null ||
          r.collections.contains(_selectedCollection);
      return matchesQuery && matchesCollection;
    }).toList();

    switch (_sortMode) {
      case SortMode.recent:
        break;
      case SortMode.ratingHighLow:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortMode.distanceNearFar:
        list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        break;
      case SortMode.nameAz:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    return list;
  }

  void _removeRestaurant(SavedRestaurant r) {
    setState(() => _restaurants.removeWhere((x) => x.id == r.id));
    SavedRestaurantService.removeSavedRestaurant(r.id);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        content: Text('Removed "${r.name}" from saved'),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: AppColors.primary,
          onPressed: () {
            setState(() => _restaurants.add(r));
            SavedRestaurantService.saveRestaurant(r.id);
          },
        ),
      ),
    );
  }

  void _openSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _SortSheet(
        selected: _sortMode,
        onSelect: (mode) {
          setState(() => _sortMode = mode);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _showCreateListDialog() async {
    final controller = TextEditingController();
    final listName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create New List'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'List name (e.g. Favorites, Weekend Brunches)',
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Create', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );

    if (listName != null && listName.isNotEmpty) {
      final col = await SavedRestaurantService.createCollection(listName);
      if (col != null && mounted) {
        setState(() {
          _selectedCollection = col.name;
        });
      }
    }
  }

  void _openRestaurant(SavedRestaurant r) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RestaurantMenuScreen(
          vendorId: r.id,
          restaurantName: r.name,
          heroImageUrl: r.imageUrl,
          cuisine: r.cuisine,
          isOpen: r.isOpen,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _Header(count: _restaurants.length),
            Expanded(
              child: _isLoading && _restaurants.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () => _loadSaved(),
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _SearchRow(
                                    controller: _searchController,
                                    onFilterTap: _openSortSheet,
                                    viewMode: _viewMode,
                                    onViewModeChanged: (m) =>
                                        setState(() => _viewMode = m),
                                  ),
                                  const SizedBox(height: 18),
                                  _CollectionsShelf(
                                    restaurants: _restaurants,
                                    selected: _selectedCollection,
                                    onSelect: (c) =>
                                        setState(() => _selectedCollection = c),
                                    onAddCollection: _showCreateListDialog,
                                  ),
                                  const SizedBox(height: 18),
                                ],
                              ),
                            ),
                          ),
                          if (visible.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: _EmptyState(hasQuery: _query.isNotEmpty),
                            )
                          else if (_viewMode == ViewMode.list)
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, i) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _RestaurantListCard(
                                      restaurant: visible[i],
                                      onTap: () => _openRestaurant(visible[i]),
                                      onRemove: () => _removeRestaurant(visible[i]),
                                    ),
                                  ),
                                  childCount: visible.length,
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                              sliver: SliverGrid(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 14,
                                      crossAxisSpacing: 14,
                                      childAspectRatio: 0.72,
                                    ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, i) => _RestaurantGridCard(
                                    restaurant: visible[i],
                                    onTap: () => _openRestaurant(visible[i]),
                                    onRemove: () => _removeRestaurant(visible[i]),
                                  ),
                                  childCount: visible.length,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Header
/// ---------------------------------------------------------------------
class _Header extends StatelessWidget {
  final int count;
  const _Header({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.textPrimary,
                size: 22,
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Saved Restaurants',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  '$count place${count == 1 ? '' : 's'} bookmarked',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Search bar + sort button + list/grid toggle
/// ---------------------------------------------------------------------
class _SearchRow extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onFilterTap;
  final ViewMode viewMode;
  final ValueChanged<ViewMode> onViewModeChanged;
  const _SearchRow({
    required this.controller,
    required this.onFilterTap,
    required this.viewMode,
    required this.onViewModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: controller,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search saved restaurants',
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textMuted,
                      size: 22,
                    ),
                    suffixIcon: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: controller,
                      builder: (context, value, _) {
                        if (value.text.isEmpty) return const SizedBox.shrink();
                        return IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textMuted,
                            size: 18,
                          ),
                          onPressed: controller.clear,
                        );
                      },
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: onFilterTap,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: const Icon(
                  Icons.swap_vert,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                'Your curated spots',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary.withOpacity(0.9),
                ),
              ),
            ),
            _ViewToggle(mode: viewMode, onChanged: onViewModeChanged),
          ],
        ),
      ],
    );
  }
}

class _ViewToggle extends StatelessWidget {
  final ViewMode mode;
  final ValueChanged<ViewMode> onChanged;
  const _ViewToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.chipLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleButton(
            icon: Icons.view_agenda_outlined,
            selected: mode == ViewMode.list,
            onTap: () => onChanged(ViewMode.list),
          ),
          _ToggleButton(
            icon: Icons.grid_view_rounded,
            selected: mode == ViewMode.grid,
            onTap: () => onChanged(ViewMode.grid),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleButton({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: selected ? AppColors.white : AppColors.textMuted,
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Collections shelf — personal curation, not just a filter row.
/// ---------------------------------------------------------------------
class _CollectionsShelf extends StatelessWidget {
  final List<SavedRestaurant> restaurants;
  final String? selected;
  final ValueChanged<String?> onSelect;
  final VoidCallback onAddCollection;

  const _CollectionsShelf({
    required this.restaurants,
    required this.selected,
    required this.onSelect,
    required this.onAddCollection,
  });

  int _countFor(String? collection) {
    if (collection == null) return restaurants.length;
    return restaurants.where((r) => r.collections.contains(collection)).length;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<SavedCollection>>(
      valueListenable: SavedRestaurantService.savedCollectionsNotifier,
      builder: (context, userCollections, _) {
        final allCollectionNames = userCollections.map((c) => c.name).toList();

        return SizedBox(
          height: 92,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _CollectionTile(
                label: 'All Saved',
                count: _countFor(null),
                icon: Icons.bookmark,
                selected: selected == null,
                onTap: () => onSelect(null),
              ),
              const SizedBox(width: 12),
              for (final collection in allCollectionNames) ...[
                _CollectionTile(
                  label: collection,
                  count: _countFor(collection),
                  icon: Icons.folder_special_rounded,
                  selected: selected == collection,
                  onTap: () => onSelect(collection),
                ),
                const SizedBox(width: 12),
              ],
              _AddCollectionTile(onTap: onAddCollection),
            ],
          ),
        );
      },
    );
  }
}

class _CollectionTile extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _CollectionTile({
    required this.label,
    required this.count,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 108,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDeep],
                )
              : null,
          color: selected ? null : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.transparent : AppColors.borderLight,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : const [
                  BoxShadow(
                    color: AppColors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? AppColors.white : AppColors.primary,
            ),
            const Spacer(),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: selected ? AppColors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$count place${count == 1 ? '' : 's'}',
              style: TextStyle(
                fontSize: 10,
                color: selected
                    ? AppColors.white.withOpacity(0.85)
                    : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCollectionTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddCollectionTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 88,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.chipLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderLight,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: AppColors.textSecondary, size: 22),
            const SizedBox(height: 6),
            Text(
              'New List',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// List-view restaurant card — full-bleed hero photo, rating pill,
/// status dot, quick call/directions actions, bookmark to remove.
/// ---------------------------------------------------------------------
class _RestaurantListCard extends StatelessWidget {
  final SavedRestaurant restaurant;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  const _RestaurantListCard({
    required this.restaurant,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(restaurant.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          color: AppColors.materialRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.materialRedAccent),
      ),
      child: Material(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 150,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(restaurant.imageUrl, fit: BoxFit.cover),
                      // Dark gradient stays even on the light theme — it's the
                      // only way white overlay text stays legible on a photo.
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              AppColors.black.withOpacity(0.7),
                              AppColors.transparent,
                            ],
                            stops: const [0.0, 0.7],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: _StatusChip(isOpen: restaurant.isOpen),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: _BookmarkButton(onTap: onRemove),
                      ),
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 10,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                restaurant.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                            _RatingPill(
                              rating: restaurant.rating,
                              reviewCount: restaurant.reviewCount,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${restaurant.cuisine} · ${restaurant.priceTag}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${restaurant.distanceKm.toStringAsFixed(1)} km',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (restaurant.collections.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: restaurant.collections
                              .map((c) => _CollectionTag(label: c))
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.call_outlined,
                              label: 'Call',
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.directions_outlined,
                              label: 'Directions',
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.restaurant_menu,
                              label: 'Menu',
                              filled: true,
                              onTap: onTap,
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
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Grid-view restaurant card — compact variant for fast scanning.
/// ---------------------------------------------------------------------
class _RestaurantGridCard extends StatelessWidget {
  final SavedRestaurant restaurant;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  const _RestaurantGridCard({
    required this.restaurant,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardLight,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: const [
              BoxShadow(
                color: AppColors.black12,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(restaurant.imageUrl, fit: BoxFit.cover),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppColors.black.withOpacity(0.65),
                            AppColors.transparent,
                          ],
                          stops: const [0.0, 0.6],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _BookmarkButton(onTap: onRemove, compact: true),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _StatusChip(isOpen: restaurant.isOpen, compact: true),
                    ),
                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: 8,
                      child: Text(
                        restaurant.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 13, color: AppColors.yellow),
                    const SizedBox(width: 3),
                    Text(
                      restaurant.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${restaurant.distanceKm.toStringAsFixed(1)} km',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Shared small pieces
/// ---------------------------------------------------------------------
class _StatusChip extends StatelessWidget {
  final bool isOpen;
  final bool compact;
  const _StatusChip({required this.isOpen, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? AppColors.materialGreen : AppColors.materialRedAccent;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isOpen ? 'OPEN' : 'CLOSED',
            style: TextStyle(
              fontSize: compact ? 8 : 9,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  final double rating;
  final int reviewCount;
  const _RatingPill({required this.rating, required this.reviewCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 13, color: AppColors.yellow),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.white.withOpacity(0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionTag extends StatelessWidget {
  final String label;
  const _CollectionTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDeep,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : AppColors.chipLight,
          borderRadius: BorderRadius.circular(10),
          border: filled ? null : Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: filled ? AppColors.white : AppColors.textPrimary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: filled ? AppColors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bookmark toggle used to remove a saved restaurant, with a light pop
/// animation so it doesn't read as a bare icon button. Sits over the
/// photo so it stays on a dark translucent chip regardless of theme.
class _BookmarkButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool compact;
  const _BookmarkButton({required this.onTap, this.compact = false});

  @override
  State<_BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<_BookmarkButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    lowerBound: 0.8,
    upperBound: 1.1,
  )..value = 1;

  void _handleTap() async {
    await _controller.animateTo(0.75, curve: Curves.easeOut);
    widget.onTap();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.compact ? 26.0 : 32.0;
    return InkWell(
      onTap: _handleTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.black.withOpacity(0.45),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white.withOpacity(0.2)),
        ),
        child: ScaleTransition(
          scale: _controller,
          child: Icon(
            Icons.bookmark,
            size: widget.compact ? 14 : 16,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Sort bottom sheet
/// ---------------------------------------------------------------------
class _SortSheet extends StatelessWidget {
  final SortMode selected;
  final ValueChanged<SortMode> onSelect;
  const _SortSheet({required this.selected, required this.onSelect});

  static const _options = [
    (SortMode.recent, 'Recently Saved', Icons.schedule),
    (SortMode.ratingHighLow, 'Rating: High to Low', Icons.star_outline),
    (SortMode.distanceNearFar, 'Distance: Near to Far', Icons.near_me_outlined),
    (SortMode.nameAz, 'Name (A–Z)', Icons.sort_by_alpha),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const Text(
              'Sort by',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            for (final (mode, label, icon) in _options)
              InkWell(
                onTap: () => onSelect(mode),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 20,
                        color: mode == selected
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: mode == selected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: mode == selected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (mode == selected)
                        const Icon(
                          Icons.check_circle,
                          size: 18,
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Empty state
/// ---------------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  final bool hasQuery;
  const _EmptyState({required this.hasQuery});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasQuery ? Icons.search_off : Icons.bookmark_border,
                color: AppColors.primary,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasQuery ? 'No matches found' : 'No saved restaurants yet',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasQuery
                  ? 'Try a different search term or switch collections.'
                  : 'Tap the bookmark on any restaurant to save it here.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

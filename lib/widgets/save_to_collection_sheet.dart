import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../services/saved_restaurant_service.dart';

/// Interactive modal sheet to save a restaurant and assign it to custom lists/collections.
class SaveToCollectionSheet extends StatefulWidget {
  final String vendorId;
  final String restaurantName;
  final String? imageUrl;
  final List<String> initialCollectionIds;

  const SaveToCollectionSheet({
    super.key,
    required this.vendorId,
    required this.restaurantName,
    this.imageUrl,
    this.initialCollectionIds = const [],
  });

  static Future<bool?> show(
    BuildContext context, {
    required String vendorId,
    required String restaurantName,
    String? imageUrl,
    List<String> initialCollectionIds = const [],
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SaveToCollectionSheet(
        vendorId: vendorId,
        restaurantName: restaurantName,
        imageUrl: imageUrl,
        initialCollectionIds: initialCollectionIds,
      ),
    );
  }

  @override
  State<SaveToCollectionSheet> createState() => _SaveToCollectionSheetState();
}

class _SaveToCollectionSheetState extends State<SaveToCollectionSheet> {
  late Set<String> _selectedIds;
  bool _isCreatingList = false;
  final TextEditingController _newListController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set<String>.from(widget.initialCollectionIds);
    SavedRestaurantService.fetchCollections();
  }

  @override
  void dispose() {
    _newListController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateCollection() async {
    final name = _newListController.text.trim();
    if (name.isEmpty) return;

    final created = await SavedRestaurantService.createCollection(name);
    if (created != null && mounted) {
      setState(() {
        _selectedIds.add(created.id);
        _isCreatingList = false;
        _newListController.clear();
      });
    }
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    final success = await SavedRestaurantService.saveRestaurant(
      widget.vendorId,
      collectionIds: _selectedIds.toList(),
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.of(context).pop(success);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        content: Text(
          _selectedIds.isEmpty
              ? 'Saved "${widget.restaurantName}" to your bookmarks'
              : 'Saved "${widget.restaurantName}" to ${_selectedIds.length} list${_selectedIds.length > 1 ? 's' : ''}',
        ),
      ),
    );
  }

  Future<void> _handleUnsave() async {
    setState(() => _isSaving = true);
    final success = await SavedRestaurantService.removeSavedRestaurant(widget.vendorId);
    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.of(context).pop(success);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        content: Text('Removed "${widget.restaurantName}" from saved'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isAlreadySaved = SavedRestaurantService.savedVendorIdsNotifier.value
        .contains(widget.vendorId);

    return ValueListenableBuilder<List<SavedCollection>>(
      valueListenable: SavedRestaurantService.savedCollectionsNotifier,
      builder: (context, collections, _) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Row
              Row(
                children: [
                  if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        widget.imageUrl!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 44,
                          height: 44,
                          color: AppColors.surfaceRaised,
                          child: const Icon(Icons.restaurant, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                  if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
                    const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Save to Custom List',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.restaurantName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              const Text(
                'YOUR LISTS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),

              // All Saved (General) checkbox
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaisedWarm,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.bookmark_added_rounded, color: AppColors.primary),
                  title: const Text(
                    'All Saved (Default)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  trailing: const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                  onTap: () {},
                ),
              ),

              // Custom user collections
              if (collections.isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 180),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: collections.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final col = collections[index];
                      final isSelected = _selectedIds.contains(col.id);

                      return Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primarySoft
                              : AppColors.surfaceRaised,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.borderLight,
                          ),
                        ),
                        child: ListTile(
                          dense: true,
                          leading: Text(
                            col.icon.isNotEmpty ? col.icon : '📌',
                            style: const TextStyle(fontSize: 18),
                          ),
                          title: Text(
                            col.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primaryDeep
                                  : AppColors.textPrimary,
                            ),
                          ),
                          trailing: Icon(
                            isSelected
                                ? Icons.check_box_rounded
                                : Icons.check_box_outline_blank_rounded,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textMuted,
                          ),
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedIds.remove(col.id);
                              } else {
                                _selectedIds.add(col.id);
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 10),

              // Create New List Option
              if (!_isCreatingList)
                TextButton.icon(
                  onPressed: () => setState(() => _isCreatingList = true),
                  icon: const Icon(Icons.add_rounded, color: AppColors.primary),
                  label: const Text(
                    'Create New List',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newListController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'List name (e.g. Date Night)',
                          hintStyle: const TextStyle(fontSize: 13),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                        onSubmitted: (_) => _handleCreateCollection(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _handleCreateCollection,
                      child: const Text('Add', style: TextStyle(color: AppColors.white)),
                    ),
                  ],
                ),

              const SizedBox(height: 18),

              // Action Buttons: Save or Unsave
              Row(
                children: [
                  if (isAlreadySaved) ...[
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.nonVegRed,
                          side: const BorderSide(color: AppColors.nonVegRed),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _isSaving ? null : _handleUnsave,
                        child: const Text(
                          'Unsave',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _isSaving ? null : _handleSave,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : Text(
                              isAlreadySaved ? 'Update Saved Lists' : 'Save Restaurant',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

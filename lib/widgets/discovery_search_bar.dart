import 'package:flutter/material.dart';

import '../app_colors.dart';

/// Shared search treatment for the discovery, deals, and nearby screens.
///
/// The map/location control deliberately lives outside this widget so each
/// screen can compose its own secondary actions beside the search field.
class DiscoverySearchBar extends StatelessWidget {
  final String hintText;
  final String selectedFilterLabel;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSearchTap;
  final VoidCallback? onClear;
  final VoidCallback? onFilterTap;
  final bool isDark;
  final Color? backgroundColor;
  final Key? shellKey;
  final Key? searchKey;
  final Key? filterKey;
  final FocusNode? focusNode;
  final bool autofocus;

  // Optional: custom icon for the filter pill (defaults to schedule_rounded)
  final IconData? filterIcon;

  // Optional: badge count shown in the pill when > 0
  final int? selectedCount;

  // When false, no pill is shown and search bar goes full width
  final bool showFilterPill;

  const DiscoverySearchBar.navigation({
    super.key,
    required this.hintText,
    required this.selectedFilterLabel,
    required this.onSearchTap,
    this.onFilterTap,
    this.isDark = false,
    this.backgroundColor,
    this.shellKey,
    this.searchKey,
    this.filterKey,
    this.filterIcon,
    this.selectedCount,
    this.showFilterPill = true,
  }) : controller = null,
       onChanged = null,
       onClear = null,
       focusNode = null,
       autofocus = false;

  const DiscoverySearchBar.editable({
    super.key,
    required this.hintText,
    required this.selectedFilterLabel,
    required TextEditingController this.controller,
    required ValueChanged<String> this.onChanged,
    this.onClear,
    this.onFilterTap,
    this.isDark = false,
    this.backgroundColor,
    this.shellKey,
    this.searchKey,
    this.filterKey,
    this.focusNode,
    this.autofocus = false,
    this.filterIcon,
    this.selectedCount,
    this.showFilterPill = true,
  }) : onSearchTap = null;

  bool get _isEditable => controller != null;

  @override
  Widget build(BuildContext context) {
    final surface = backgroundColor ?? (isDark ? AppColors.cardDark : AppColors.surface);
    final foreground = isDark ? AppColors.white : AppColors.textPrimary;
    final hint = isDark ? AppColors.textMutedDark : AppColors.textMuted;
    final radius = BorderRadius.circular(28);

    return Semantics(
      label: '$hintText. Selected filter: $selectedFilterLabel',
      child: Container(
        key: shellKey,
        height: 52,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: radius,
          border: isDark ? Border.all(color: AppColors.borderDark) : null,
          boxShadow: (isDark || backgroundColor != null)
              ? null
              : [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          children: [
            Expanded(child: _buildSearch(context, foreground, hint, radius)),
            if (showFilterPill)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _HomeFilterPill(
                  key: filterKey,
                  label: selectedFilterLabel,
                  icon: filterIcon,
                  count: selectedCount,
                  onTap: onFilterTap,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch(
    BuildContext context,
    Color foreground,
    Color hint,
    BorderRadius radius,
  ) {
    if (!_isEditable) {
      return InkWell(
        key: searchKey,
        onTap: onSearchTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.only(left: 13, right: 6),
          child: Row(
            children: [
              Icon(Icons.search_rounded, size: 21, color: foreground),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  hintText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: hint,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return TextField(
      key: searchKey,
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: foreground,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: hint,
        ),
        prefixIcon: Icon(Icons.search_rounded, size: 21, color: hint),
        suffixIcon: controller!.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                onPressed: onClear,
                icon: Icon(Icons.close_rounded, size: 18, color: hint),
              ),
        border: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}

class _HomeFilterPill extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final int? count;

  const _HomeFilterPill({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final hasCount = (count ?? 0) > 0;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 156),
      child: Material(
        color: AppColors.orange,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
            height: 40,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon ?? Icons.schedule_rounded,
                    size: 13,
                    color: AppColors.textOnAccent,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textOnAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (hasCount) ...[
                    const SizedBox(width: 5),
                    Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.orange,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 14,
                    color: AppColors.textOnAccent,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

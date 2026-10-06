import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../services/food_tag_service.dart';
import 'shimmer_loading.dart';

class CategoryRow extends StatelessWidget {
  final List<FoodTag> foodTags;
  final bool isLoading;
  final ValueChanged<FoodTag>? onTagTap;
  final String? selectedTagId;
  final String? selectedTagName;
  final EdgeInsetsGeometry padding;
  final Key? scrollKey;
  final double? itemSize;

  const CategoryRow({
    super.key,
    required this.foodTags,
    required this.isLoading,
    this.onTagTap,
    this.selectedTagId,
    this.selectedTagName,
    this.padding = const EdgeInsets.symmetric(horizontal: 18),
    this.scrollKey,
    this.itemSize,
  });

  @override
  Widget build(BuildContext context) {
    const tagTextGap = 4.0;
    const fontSize = 12.0;
    final labelHeight = MediaQuery.textScalerOf(context).scale(fontSize) * 1.25;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Five touch targets fit across the content area for a compact, thick look
        final tileSize = itemSize ??
            ((constraints.maxWidth - 36 - 32) / 5).clamp(52.0, 64.0);

        final cardRadius = BorderRadius.circular(14);

        return Hero(
          tag: 'discovery_food_tags_hero',
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              height: tileSize + tagTextGap + labelHeight + 2,
              child: ListView.separated(
                key: scrollKey ?? const PageStorageKey('home-categories'),
                scrollDirection: Axis.horizontal,
                padding: padding,
                itemCount: isLoading ? 5 : foodTags.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (isLoading) {
                    return SizedBox(
                      width: tileSize,
                      child: _CategorySkeleton(
                        size: tileSize,
                        gap: tagTextGap,
                        radius: cardRadius,
                      ),
                    );
                  }
                  final tag = foodTags[index];
                  final isSelected = (selectedTagId != null &&
                          selectedTagId!.isNotEmpty &&
                          selectedTagId == tag.id) ||
                      (selectedTagName != null &&
                          selectedTagName!.isNotEmpty &&
                          selectedTagName!.toLowerCase() ==
                              tag.name.toLowerCase());

                  final fallback = Container(
                    decoration: BoxDecoration(
                      color: AppColors.orangeTint,
                      borderRadius: cardRadius,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.restaurant_menu_rounded,
                        color: AppColors.orange,
                        size: 24,
                      ),
                    ),
                  );

                  return SizedBox(
                    width: tileSize,
                    child: InkWell(
                      key: ValueKey('home-food-tag-${tag.id}'),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      onTap: () => onTagTap?.call(tag),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: tileSize,
                            height: tileSize,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Glow positioned below/behind PNG
                                if (isSelected) ...[
                                  Positioned(
                                    bottom: 2,
                                    left: tileSize * 0.10,
                                    right: tileSize * 0.10,
                                    height: tileSize * 0.32,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.elliptical(
                                            tileSize * 0.40,
                                            tileSize * 0.16,
                                          ),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.orange
                                                .withValues(alpha: 0.40),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: cardRadius,
                                        gradient: RadialGradient(
                                          colors: [
                                            AppColors.orange
                                                .withValues(alpha: 0.22),
                                            AppColors.orange
                                                .withValues(alpha: 0.06),
                                            Colors.transparent,
                                          ],
                                          stops: const [0.0, 0.60, 1.0],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],

                                // Category image
                                ClipRRect(
                                  borderRadius: cardRadius,
                                  child: SizedBox.expand(
                                    child: tag.imageUrl == null
                                        ? fallback
                                        : Image.network(
                                            tag.imageUrl!,
                                            fit: BoxFit.cover,
                                            excludeFromSemantics: true,
                                            errorBuilder: (_, _, _) => fallback,
                                            loadingBuilder:
                                                (_, child, progress) =>
                                                    progress == null
                                                        ? child
                                                        : fallback,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: tagTextGap),
                          Text(
                            tag.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  fontSize: fontSize,
                                  height: 1.2,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w700,
                                  color: isSelected
                                      ? AppColors.orange
                                      : AppColors.toneFF2F2F2F,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CategorySkeleton extends StatelessWidget {
  final double size;
  final double gap;
  final BorderRadius radius;

  const _CategorySkeleton({
    required this.size,
    this.gap = 4.0,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: radius,
            ),
          ),
          SizedBox(height: gap),
          Container(
            width: (size * 0.75).clamp(32.0, 48.0),
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

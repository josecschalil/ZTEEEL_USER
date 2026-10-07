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
    const tagTextGap = 3.0;
    const fontSize = 12.0;
    final labelHeight = MediaQuery.textScalerOf(context).scale(fontSize) * 1.25;

    return LayoutBuilder(
      builder: (context, constraints) {
        final iconSize = (itemSize ?? 72.0).clamp(64.0, 78.0);
        final itemWidth = iconSize;
        final cardRadius = BorderRadius.circular(18);

        return Hero(
          tag: 'discovery_food_tags_hero',
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              height: iconSize + tagTextGap + labelHeight + 2,
              child: ListView.separated(
                key: scrollKey ?? const PageStorageKey('home-categories'),
                scrollDirection: Axis.horizontal,
                padding: padding,
                itemCount: isLoading ? 6 : foodTags.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (isLoading) {
                    return SizedBox(
                      width: itemWidth,
                      child: _CategorySkeleton(
                        size: iconSize,
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
                        size: 30,
                      ),
                    ),
                  );

                  return SizedBox(
                    width: itemWidth,
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
                            width: iconSize,
                            height: iconSize,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Glow positioned below/behind PNG
                                if (isSelected) ...[
                                  Positioned(
                                    bottom: 2,
                                    left: iconSize * 0.10,
                                    right: iconSize * 0.10,
                                    height: iconSize * 0.32,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.elliptical(
                                            iconSize * 0.40,
                                            iconSize * 0.16,
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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 1),
                            child: Text(
                              tag.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    fontSize: fontSize,
                                    letterSpacing: -0.25,
                                    height: 1.15,
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w700,
                                    color: isSelected
                                        ? AppColors.orange
                                        : AppColors.toneFF2F2F2F,
                                  ),
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
            width: (size * 0.85).clamp(32.0, 52.0),
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

import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../screens/RestaurantListScreen.dart' show RestaurantListing;
import '../services/saved_restaurant_service.dart';
import 'save_to_collection_sheet.dart';
import 'shimmer_loading.dart';

/// The standard restaurant card used across the app (Home feed, search, nearby, etc.)
class RestaurantCard extends StatelessWidget {
  final RestaurantListing restaurant;
  final VoidCallback onTap;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const cardRadius = BorderRadius.all(Radius.circular(28));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: cardRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: cardRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─────────────────────────────────────────────
              // IMAGE (Full-bleed, rounded top, no side borders/padding)
              // ─────────────────────────────────────────────
              SizedBox(
                height: 154,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    RestaurantImage(restaurant: restaurant),

                    // BOOKMARK / SAVE BUTTON
                    Positioned(
                      top: 10,
                      right: 10,
                      child: ValueListenableBuilder<Set<String>>(
                        valueListenable:
                            SavedRestaurantService.savedVendorIdsNotifier,
                        builder: (context, savedIds, _) {
                          final isSaved = savedIds.contains(restaurant.id);
                          return Material(
                            color: AppColors.black.withValues(alpha: 0.35),
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () {
                                SaveToCollectionSheet.show(
                                  context,
                                  vendorId: restaurant.id,
                                  restaurantName: restaurant.name,
                                  imageUrl: restaurant.imageUrl,
                                );
                              },
                              child: Container(
                                width: 34,
                                height: 34,
                                alignment: Alignment.center,
                                child: Icon(
                                  isSaved
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_border_rounded,
                                  color: isSaved
                                      ? AppColors.primary
                                      : AppColors.white,
                                  size: 19,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // PROMOTED / FREE DELIVERY / OFFER BADGES
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Row(
                        children: [
                          if (restaurant.offerLabel != null &&
                              restaurant.offerLabel!.isNotEmpty)
                            _ImageBadge(
                              icon: Icons.bolt_rounded,
                              label: restaurant.offerLabel!,
                              dark: true,
                            )
                          else if (restaurant.isPromoted)
                            const _ImageBadge(
                              icon: Icons.bolt_rounded,
                              label: 'PROMOTED',
                              dark: true,
                            ),

                          if (restaurant.isPromoted &&
                              restaurant.hasFreeDelivery)
                            const SizedBox(width: 6),

                          if (restaurant.hasFreeDelivery)
                            const _ImageBadge(
                              icon: Icons.delivery_dining_rounded,
                              label: 'FREE DELIVERY',
                              dark: false,
                            ),
                        ],
                      ),
                    ),

                    // OPEN / CLOSED BADGE
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: AppColors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              restaurant.isOpenNow ? 'Open now' : 'Closed',
                              style: TextStyle(
                                fontSize: 10.5,
                                height: 1,
                                fontWeight: FontWeight.w700,
                                color: AppColors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ─────────────────────────────────────────────
              // DETAILS
              // ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurant.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  height: 1.15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.35,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                restaurant.cuisines.join(' · '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  height: 1.15,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        _RatingBadge(rating: restaurant.rating),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // DISTANCE + ETA
                    Row(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14.5,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${restaurant.distanceKm.toStringAsFixed(1)} km',
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${restaurant.etaMins} mins',
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
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
    );
  }
}

/// Restaurant image with safe fallback.
class RestaurantImage extends StatelessWidget {
  final RestaurantListing restaurant;

  const RestaurantImage({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final imageUrl = restaurant.imageUrl;

    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return _PhotoFallback(icon: restaurant.fallbackIcon);
        },
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(color: AppColors.surfaceRaised);
        },
      );
    }

    return _PhotoFallback(icon: restaurant.fallbackIcon);
  }
}

/// Fallback icon placeholder shown when restaurant has no image.
class _PhotoFallback extends StatelessWidget {
  final IconData icon;

  const _PhotoFallback({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.orangeTint, AppColors.surfaceRaised],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 38, color: AppColors.orange),
    );
  }
}

/// Floating badge displayed over the restaurant cover image.
class _ImageBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool dark;

  const _ImageBadge({
    required this.icon,
    required this.label,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: dark ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: dark ? null : Border.all(color: AppColors.orangeBorder, width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.tone18000000,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: dark ? AppColors.white : AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 8.5,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
              color: dark ? AppColors.white : AppColors.primaryDeep,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact star + rating value badge.
class _RatingBadge extends StatelessWidget {
  final double rating;

  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 18, color: AppColors.yellow),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 13,
            height: 1,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Shimmer wireframe skeleton for RestaurantCard.
class RestaurantCardSkeleton extends StatelessWidget {
  const RestaurantCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    const cardRadius = BorderRadius.all(Radius.circular(28));

    return ExcludeSemantics(
      child: ShimmerLoading(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: cardRadius,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: cardRadius,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo wireframe (height: 154)
                SizedBox(
                  height: 154,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Container(color: AppColors.surfaceRaised),
                      // Top left badge placeholder
                      Positioned(
                        left: 12,
                        top: 12,
                        child: Container(
                          width: 88,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      // Bottom right open status badge placeholder
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Container(
                          width: 74,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.90),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Card details area
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title bar
                                Container(
                                  width: 170,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceRaised,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // Cuisine bar
                                Container(
                                  width: 220,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceRaised,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Rating badge placeholder
                          Container(
                            width: 46,
                            height: 22,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceRaised,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Distance and ETA row
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 11,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceRaised,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: AppColors.textMuted,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 54,
                            height: 11,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceRaised,
                              borderRadius: BorderRadius.circular(4),
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

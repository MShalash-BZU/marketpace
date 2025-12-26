import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../shared/models/store.dart';

class StoreCard extends StatelessWidget {
  final String storeName;
  final String category;
  final double rating;
  final int reviewsCount;
  final String deliveryTime;
  final double deliveryFee;
  final String imageUrl;
  final bool isOpen;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const StoreCard({
    super.key,
    required this.storeName,
    required this.category,
    required this.rating,
    required this.reviewsCount,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.imageUrl,
    required this.isOpen,
    required this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  Store? get storeData => null; // Will be passed from parent

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isOpen ? onTap : null,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppDimensions.radiusMedium),
                    topRight: Radius.circular(AppDimensions.radiusMedium),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 120,
                      color: AppColors.grey200,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 120,
                      color: AppColors.grey200,
                      child: const Icon(
                        Icons.store,
                        size: 40,
                        color: AppColors.grey400,
                      ),
                    ),
                  ),
                ),

                // Favorite Button
                Positioned(
                  top: AppDimensions.paddingSmall,
                  right: AppDimensions.paddingSmall,
                  child: GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.white.withAlpha(230),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withAlpha(26),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isFavorite ? AppColors.error : AppColors.grey600,
                      ),
                    ),
                  ),
                ),

                // Status Badge
                Positioned(
                  top: AppDimensions.paddingSmall,
                  left: AppDimensions.paddingSmall,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingSmall,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isOpen ? AppColors.success : AppColors.error,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSmall,
                      ),
                    ),
                    child: Text(
                      isOpen ? 'مفتوح' : 'مغلق',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Closed Overlay
                if (!isOpen)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.black.withAlpha(102),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppDimensions.radiusMedium),
                          topRight: Radius.circular(AppDimensions.radiusMedium),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Store Name
                    Text(
                      storeName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 2),

                    // Category
                    Text(
                      category,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.grey600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // Rating
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '($reviewsCount)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.grey500,
                                fontSize: 10,
                              ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Delivery Info
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 12,
                          color: AppColors.grey500,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            deliveryTime,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.grey600,
                                  fontSize: 10,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 2),

                    // Delivery Fee
                    Row(
                      children: [
                        const Icon(
                          Icons.delivery_dining,
                          size: 12,
                          color: AppColors.grey500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          deliveryFee == 0 ? 'توصيل مجاني' : '${deliveryFee.toInt()} ر.س',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: deliveryFee == 0 ? AppColors.success : AppColors.grey600,
                                fontSize: 10,
                                fontWeight: deliveryFee == 0 ? FontWeight.w600 : FontWeight.normal,
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
      ),
    );
  }
}
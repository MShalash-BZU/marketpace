import 'package:flutter/material.dart';
import '../../../../../shared/models/cart_item.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';

typedef VoidCallbackStr = void Function();

class CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final VoidCallback onIncreaseQuantity;
  final VoidCallback onDecreaseQuantity;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onIncreaseQuantity,
    required this.onDecreaseQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingSmall),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        boxShadow: [
          BoxShadow(color: AppColors.black.withAlpha(8), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: item.product.primaryImageUrl != null
                ? Image.network(item.product.primaryImageUrl!)
                : const Icon(Icons.image_not_supported),
          ),
          const SizedBox(width: AppDimensions.paddingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name),
                const SizedBox(height: 4),
                Text('${item.product.price} SAR', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(onPressed: onDecreaseQuantity, icon: const Icon(Icons.remove)),
                    Text('${item.quantity}'),
                    IconButton(onPressed: onIncreaseQuantity, icon: const Icon(Icons.add)),
                    const Spacer(),
                    IconButton(onPressed: onRemove, icon: const Icon(Icons.delete, color: AppColors.error)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

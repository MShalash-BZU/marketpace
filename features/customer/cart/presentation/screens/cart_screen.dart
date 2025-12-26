import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../shared/widgets/common/app_button.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_summary_card.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final isEmpty = ref.watch(cartIsEmptyProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('السلة'),
          actions: [
            if (!isEmpty)
              TextButton(
                onPressed: () {
                  _showClearCartDialog(context, ref);
                },
                child: const Text(
                  'إفراغ السلة',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
          ],
        ),
        body: isEmpty ? _buildEmptyState(context) : _buildCartContent(context, ref, cart),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: AppColors.grey300,
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          Text(
            'السلة فارغة',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.grey600,
                ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          const Text(
            'أضف منتجات لتبدأ التسوق',
            style: TextStyle(color: AppColors.grey500),
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          AppButton(
            text: 'تصفح المحلات',
            onPressed: () {
              Navigator.of(context).pop();
            },
            type: AppButtonType.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, WidgetRef ref, cart) {
    final itemsByStore = cart.itemsByStore;

    return Column(
      children: [
        // Cart Items (Scrollable)
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            itemCount: itemsByStore.length,
            itemBuilder: (context, index) {
              final storeId = itemsByStore.keys.elementAt(index);
              final storeItems = itemsByStore[storeId]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store Header
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                    decoration: BoxDecoration(
                      color: AppColors.grey50,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSmall,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.store,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppDimensions.paddingSmall),
                        Expanded(
                          child: Text(
                            'المحل ${index + 1}', // TODO: Show actual store name
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        Text(
                          '${storeItems.length} ${storeItems.length == 1 ? 'منتج' : 'منتجات'}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.grey600,
                              ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingSmall),

                  // Store Items
                  ...storeItems.map((item) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.paddingSmall,
                        ),
                        child: CartItemCard(
                          item: item,
                          onRemove: () {
                            ref.read(cartProvider.notifier).removeProduct(item.product.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم حذف المنتج من السلة'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          onIncreaseQuantity: () {
                            try {
                              ref.read(cartProvider.notifier).increaseQuantity(item.product.id);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString()),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          },
                          onDecreaseQuantity: () {
                            ref.read(cartProvider.notifier).decreaseQuantity(item.product.id);
                          },
                        ),
                      )),

                  const SizedBox(height: AppDimensions.paddingMedium),
                ],
              );
            },
          ),
        ),

        // Summary & Checkout Button
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withAlpha(26),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                children: [
                  // Summary
                  CartSummaryCard(
                    subtotal: cart.subtotal,
                    deliveryFee: 0, // Will calculate in checkout
                    discount: 0,
                  ),

                  const SizedBox(height: AppDimensions.paddingMedium),

                  // Checkout Button
                  AppButton(
                    text: 'متابعة للدفع',
                    isFullWidth: true,
                    size: AppButtonSize.large,
                    onPressed: () {
                      // Validate cart first
                      final errors = ref.read(cartProvider.notifier).validateCart();
                      
                      if (errors.isNotEmpty) {
                        _showValidationErrors(context, errors);
                        return;
                      }

                      // Navigate to checkout
                      // TODO: Implement checkout screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('صفحة الدفع قريباً...'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showClearCartDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('إفراغ السلة'),
          content: const Text('هل أنت متأكد من حذف جميع المنتجات من السلة؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(cartProvider.notifier).clearCart();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إفراغ السلة'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text('حذف الكل'),
            ),
          ],
        ),
      ),
    );
  }

  void _showValidationErrors(BuildContext context, List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تنبيه'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('بعض المنتجات في السلة غير متوفرة:'),
              const SizedBox(height: AppDimensions.paddingSmall),
              ...errors.map((error) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppDimensions.paddingTiny,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(child: Text(error)),
                      ],
                    ),
                  )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('حسناً'),
            ),
          ],
        ),
      ),
    );
  }
}
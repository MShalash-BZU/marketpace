import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../providers/orders_provider.dart';
import '../widgets/order_card.dart';
import 'order_details_screen.dart';

class OrdersListScreen extends ConsumerWidget {
  const OrdersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(ordersProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('طلباتي'),
        ),
        body: ordersState.isLoading && ordersState.orders.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ordersState.error != null && ordersState.orders.isEmpty
                ? _buildErrorState(context, ref, ordersState.error!)
                : ordersState.orders.isEmpty
                    ? _buildEmptyState(context)
                    : _buildOrdersList(context, ref, ordersState),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_bag_outlined,
            size: 100,
            color: AppColors.grey300,
          ),
          const SizedBox(height: AppDimensions.paddingLarge),
          Text(
            'لا توجد طلبات بعد',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.grey600,
                ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          const Text(
            'ابدأ التسوق الآن وأضف منتجاتك المفضلة',
            style: TextStyle(color: AppColors.grey500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          const Text(
            'حدث خطأ في تحميل الطلبات',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            error,
            style: const TextStyle(color: AppColors.grey600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          ElevatedButton(
            onPressed: () {
              ref.read(ordersProvider.notifier).refresh();
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, WidgetRef ref, ordersState) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(ordersProvider.notifier).refresh();
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        itemCount: ordersState.orders.length,
        separatorBuilder: (_, __) => const SizedBox(
          height: AppDimensions.paddingMedium,
        ),
        itemBuilder: (context, index) {
          final order = ordersState.orders[index];
          return OrderCard(
            order: order,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OrderDetailsScreen(orderId: order.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
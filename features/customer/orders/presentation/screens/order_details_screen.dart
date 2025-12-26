import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/utils/extensions.dart';
import '../../../../../shared/models/order.dart';
import '../providers/orders_provider.dart';
import '../widgets/order_status_timeline.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailsProvider(orderId));
    final itemsAsync = ref.watch(orderItemsProvider(orderId));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('طلب #${orderId.substring(0, 8)}'),
        ),
        body: orderAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text('حدث خطأ: $error'),
          ),
          data: (order) => SingleChildScrollView(
            child: Column(
              children: [
                // Order Status Timeline
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  color: AppColors.white,
                  child: OrderStatusTimeline(status: order.status),
                ),

                const SizedBox(height: AppDimensions.paddingSmall),

                // Order Info
                _buildOrderInfo(context, order),

                const SizedBox(height: AppDimensions.paddingSmall),

                // Order Items
                itemsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('خطأ: $error')),
                  data: (items) => _buildOrderItems(context, items),
                ),

                const SizedBox(height: AppDimensions.paddingSmall),

                // Order Summary
                _buildOrderSummary(context, order),

                const SizedBox(height: AppDimensions.paddingLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderInfo(BuildContext context, Order order) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات الطلب',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          _buildInfoRow(Icons.calendar_today, 'التاريخ', order.createdAt.formatDateTime),
          const SizedBox(height: AppDimensions.paddingSmall),
          _buildInfoRow(Icons.location_on, 'عنوان التوصيل', order.addressText),
          const SizedBox(height: AppDimensions.paddingSmall),
          _buildInfoRow(
            Icons.payment,
            'طريقة الدفع',
            order.paymentMethod == PaymentMethod.cod ? 'الدفع عند الاستلام' : 'الدفع الإلكتروني',
          ),
          if (order.otpCode != null) ...[
            const SizedBox(height: AppDimensions.paddingSmall),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingSmall),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text('رمز التحقق: '),
                  Text(
                    order.otpCode!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.grey500),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.grey600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItems(BuildContext context, List<Map<String, dynamic>> items) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المنتجات',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
                child: Row(
                  children: [
                    Text('${item['qty']}x'),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item['product_name_snapshot'],
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      (item['line_total'] as num).toDouble().formatCurrency,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, Order order) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملخص الطلب',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          _buildSummaryRow('المجموع الفرعي', order.subtotalProducts),
          const SizedBox(height: AppDimensions.paddingSmall),
          _buildSummaryRow('رسوم التوصيل', order.deliveryFeeTotal),
          if (order.discountTotal > 0) ...[
            const SizedBox(height: AppDimensions.paddingSmall),
            _buildSummaryRow('الخصم', order.discountTotal, isDiscount: true),
          ],
          const Divider(height: AppDimensions.paddingMedium),
          _buildSummaryRow('الإجمالي', order.grandTotal, isBold: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isBold = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          '${isDiscount ? '-' : ''}${value.formatCurrency}',
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: isBold ? 18 : 14,
            color: isDiscount ? AppColors.success : (isBold ? AppColors.primary : null),
          ),
        ),
      ],
    );
  }
}
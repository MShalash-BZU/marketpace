import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';

class CartSummaryCard extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final double discount;

  const CartSummaryCard({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
  });

  double get total => subtotal + deliveryFee - discount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            context,
            'المجموع الفرعي',
            subtotal,
          ),
          
          const SizedBox(height: AppDimensions.paddingSmall),
          
          _buildSummaryRow(
            context,
            'رسوم التوصيل',
            deliveryFee,
            color: deliveryFee == 0 ? AppColors.success : null,
            valueText: deliveryFee == 0 ? 'مجاني' : null,
          ),
          
          if (discount > 0) ...[
            const SizedBox(height: AppDimensions.paddingSmall),
            _buildSummaryRow(
              context,
              'الخصم',
              discount,
              color: AppColors.success,
              isNegative: true,
            ),
          ],
          
          const Padding(
            padding: EdgeInsets.symmetric(
              vertical: AppDimensions.paddingSmall,
            ),
            child: Divider(),
          ),
          
          _buildSummaryRow(
            context,
            'الإجمالي',
            total,
            isBold: true,
            isLarge: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    double value, {
    Color? color,
    String? valueText,
    bool isBold = false,
    bool isLarge = false,
    bool isNegative = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color ?? AppColors.grey700,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: isLarge ? 16 : null,
              ),
        ),
        Text(
          valueText ?? '${isNegative ? '-' : ''}${value.toStringAsFixed(2)} ر.س',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color ?? AppColors.grey900,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                fontSize: isLarge ? 18 : null,
              ),
        ),
      ],
    );
  }
}
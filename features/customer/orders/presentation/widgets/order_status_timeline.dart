import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../shared/models/order.dart';

class OrderStatusTimeline extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusTimeline({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      _TimelineStep('تم الطلب', OrderStatus.created, Icons.shopping_bag),
      _TimelineStep('قيد التحضير', OrderStatus.inProgress, Icons.restaurant),
      _TimelineStep('في الطريق', OrderStatus.outForDelivery, Icons.delivery_dining),
      _TimelineStep('تم التوصيل', OrderStatus.delivered, Icons.check_circle),
    ];

    final currentIndex = _getCurrentStepIndex(status);

    return Column(
      children: [
        Row(
          children: List.generate(
            steps.length,
            (index) => Expanded(
              child: _buildTimelineStep(
                context,
                steps[index],
                isActive: index <= currentIndex,
                isCompleted: index < currentIndex,
                isLast: index == steps.length - 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  int _getCurrentStepIndex(OrderStatus status) {
    switch (status) {
      case OrderStatus.created:
      case OrderStatus.confirmed:
        return 0;
      case OrderStatus.inProgress:
        return 1;
      case OrderStatus.outForDelivery:
        return 2;
      case OrderStatus.delivered:
        return 3;
      case OrderStatus.cancelled:
        return -1;
    }
  }

  Widget _buildTimelineStep(
    BuildContext context,
    _TimelineStep step, {
    required bool isActive,
    required bool isCompleted,
    required bool isLast,
  }) {
    return Column(
      children: [
        // Icon & Line
        Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.grey200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check : step.icon,
                color: isActive ? AppColors.white : AppColors.grey500,
                size: 20,
              ),
            ),
            // Line to next step
            if (!isLast)
              Expanded(
                child: Container(
                  height: 2,
                  color: isCompleted ? AppColors.primary : AppColors.grey300,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingSmall),
        // Label
        Text(
          step.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? AppColors.primary : AppColors.grey600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _TimelineStep {
  final String label;
  final OrderStatus status;
  final IconData icon;

  _TimelineStep(this.label, this.status, this.icon);
}
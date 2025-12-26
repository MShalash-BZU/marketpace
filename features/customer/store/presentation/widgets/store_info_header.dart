import 'package:flutter/material.dart';
import '../../../../../shared/models/store.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_colors.dart';

class StoreInfoHeader extends StatelessWidget {
  final Store store;

  const StoreInfoHeader({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(store.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(store.addressText, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey600)),
        ],
      ),
    );
  }
}

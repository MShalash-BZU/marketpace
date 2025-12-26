import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../shared/models/category.dart';

class CategoryChips extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final Function(String?) onCategorySelected;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  // Default icon mapping
  static const Map<String, IconData> _iconMap = {
    'مطاعم': Icons.restaurant,
    'سوبرماركت': Icons.shopping_basket,
    'صيدليات': Icons.medical_services,
    'ملابس': Icons.checkroom,
    'إلكترونيات': Icons.devices,
    'كتب': Icons.menu_book,
    'رياضة': Icons.sports_soccer,
    'عام': Icons.store,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1, // +1 for "All" chip
        separatorBuilder: (_, __) => const SizedBox(
          width: AppDimensions.paddingSmall,
        ),
        itemBuilder: (context, index) {
          // First chip is "All"
          if (index == 0) {
            return _buildCategoryChip(
              context,
              label: 'الكل',
              icon: Icons.apps,
              isSelected: selectedCategoryId == null,
              onTap: () => onCategorySelected(null),
            );
          }

          final category = categories[index - 1];
          final icon = _getIconForCategory(category.name);
          final isSelected = selectedCategoryId == category.id;

          return _buildCategoryChip(
            context,
            label: category.name,
            icon: icon,
            isSelected: isSelected,
            onTap: () => onCategorySelected(category.id),
          );
        },
      ),
    );
  }

  IconData _getIconForCategory(String categoryName) {
    return _iconMap[categoryName] ?? Icons.category;
  }

  Widget _buildCategoryChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.grey50,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? AppColors.white : AppColors.grey600,
            ),
            const SizedBox(height: AppDimensions.paddingTiny),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isSelected ? AppColors.white : AppColors.grey700,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
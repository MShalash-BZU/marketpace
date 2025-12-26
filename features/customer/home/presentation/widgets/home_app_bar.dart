import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badges/badges.dart' as badges;
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../cart/presentation/screens/cart_screen.dart';
// تأكد من استيراد TownProvider الذي أنشأناه سابقاً
import '../providers/town_provider.dart'; 

class HomeAppBar extends ConsumerWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. استدعاء بيانات البلدة والسلة
    final selectedTown = ref.watch(selectedTownProvider);
    final townsAsync = ref.watch(townsListProvider);
    final cartCount = ref.watch(cartItemsCountProvider);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea( // إضافة SafeArea للحماية من الـ Notch
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                // 2. استبدال اللوجو الثابت بمحدد الموقع
                Expanded(
                  child: InkWell(
                    onTap: () => _showTownSelectionDialog(context, ref, townsAsync),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'التوصيل إلى',
                          style: TextStyle(fontSize: 12, color: AppColors.grey600),
                        ),
                        Row(
                          children: [
                            Text(
                              selectedTown?.name ?? 'اختر مدينتك',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Actions (Notifications & Cart)
                Row(
                  children: [
                    // Notifications (Placeholder)
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {},
                      color: AppColors.grey700,
                    ),

                    // Cart Badge
                    badges.Badge(
                      badgeContent: Text(
                        '$cartCount',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      showBadge: cartCount > 0,
                      badgeStyle: const badges.BadgeStyle(
                        badgeColor: AppColors.primary,
                        padding: EdgeInsets.all(4),
                      ),
                      position: badges.BadgePosition.topEnd(top: -5, end: -5),
                      child: IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CartScreen(),
                            ),
                          );
                        },
                        color: AppColors.grey700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // نافذة اختيار المدينة
  void _showTownSelectionDialog(BuildContext context, WidgetRef ref, AsyncValue<List<Town>> townsAsync) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => townsAsync.when(
        data: (towns) => ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: towns.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (ctx, index) => ListTile(
            title: Text(
              towns[index].name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: ref.read(selectedTownProvider)?.id == towns[index].id 
                ? const Icon(Icons.check_circle, color: AppColors.primary)
                : null,
            onTap: () {
              ref.read(selectedTownProvider.notifier).setTown(towns[index]);
              Navigator.pop(ctx);
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';

class StoreOwnerDashboardScreen extends ConsumerStatefulWidget {
  const StoreOwnerDashboardScreen({super.key});

  @override
  ConsumerState<StoreOwnerDashboardScreen> createState() => _StoreOwnerDashboardScreenState();
}

class _StoreOwnerDashboardScreenState extends ConsumerState<StoreOwnerDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('لوحة التحكم'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // TODO: Notifications
              },
            ),
          ],
        ),
        body: _currentIndex == 0
            ? _buildDashboard()
            : _currentIndex == 1
                ? _buildProductsPlaceholder()
                : _currentIndex == 2
                    ? _buildOrdersPlaceholder()
                    : _buildSettingsPlaceholder(),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Welcome Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرحباً بك! 👋',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppDimensions.paddingSmall),
                  Text(
                    'إليك نظرة سريعة على أداء متجرك',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.grey600,
                        ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.paddingLarge),

          // Stats Grid
          Row(
            children: [
              Expanded(child: _buildStatCard('المبيعات اليوم', '0 ر.س', Icons.shopping_bag, AppColors.primary)),
              const SizedBox(width: AppDimensions.paddingMedium),
              Expanded(child: _buildStatCard('الطلبات', '0', Icons.receipt, AppColors.success)),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingMedium),

          Row(
            children: [
              Expanded(child: _buildStatCard('المنتجات', '0', Icons.inventory_2, AppColors.warning)),
              const SizedBox(width: AppDimensions.paddingMedium),
              Expanded(child: _buildStatCard('التقييم', '0.0', Icons.star, AppColors.accent)),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingLarge),

          // Recent Orders
          Text(
            'الطلبات الأخيرة',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: AppDimensions.paddingMedium),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              child: Column(
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.grey400),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  Text(
                    'لا توجد طلبات حالياً',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.grey600,
                        ),
                  ),
                  const SizedBox(height: AppDimensions.paddingSmall),
                  Text(
                    'ستظهر الطلبات هنا عند وجودها',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.grey500,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.paddingLarge),

          // Quick Actions
          Text(
            'إجراءات سريعة',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: AppDimensions.paddingMedium),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: AppDimensions.paddingMedium,
            mainAxisSpacing: AppDimensions.paddingMedium,
            childAspectRatio: 1.5,
            children: [
              _buildQuickActionCard(
                'إضافة منتج',
                Icons.add_circle_outline,
                AppColors.primary,
                () {
                  // TODO: Navigate to add product
                },
              ),
              _buildQuickActionCard(
                'إدارة المنتجات',
                Icons.inventory_2_outlined,
                AppColors.success,
                () {
                  setState(() => _currentIndex = 1);
                },
              ),
              _buildQuickActionCard(
                'الطلبات',
                Icons.receipt_long_outlined,
                AppColors.warning,
                () {
                  setState(() => _currentIndex = 2);
                },
              ),
              _buildQuickActionCard(
                'الإعدادات',
                Icons.settings_outlined,
                AppColors.grey600,
                () {
                  setState(() => _currentIndex = 3);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                  decoration: BoxDecoration(
                    color: color.withAlpha(26),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: AppDimensions.paddingTiny),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.grey600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: AppDimensions.paddingSmall),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.grey400),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            'إدارة المنتجات',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            'قريباً...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.grey400),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            'إدارة الطلبات',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            'قريباً...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.settings_outlined, size: 64, color: AppColors.grey400),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            'الإعدادات',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          Text(
            'قريباً...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey400,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'المنتجات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'الطلبات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}


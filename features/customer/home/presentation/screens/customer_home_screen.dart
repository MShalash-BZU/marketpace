import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../shared/widgets/common/app_text_field.dart';
import '../../../orders/presentation/screens/orders_list_screen.dart';
import '../../../store/presentation/screens/store_details_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../providers/stores_provider.dart';
import '../providers/town_provider.dart';
import '../widgets/category_chips.dart';
import '../widgets/store_card.dart';
import '../widgets/home_app_bar.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // TODO: Implement scroll loading with proper ref access
    // For now, we'll handle this in the _buildHomeTab method
  }

 @override
Widget build(BuildContext context) {
  return Consumer(
    builder: (context, ref, child) {
      final selectedTown = ref.watch(selectedTownProvider);
      final townsAsync = ref.watch(townsListProvider);

      return Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('التوصيل إلى', style: TextStyle(fontSize: 12, color: Colors.grey)),
              GestureDetector(
                onTap: () => _showTownSelectionDialog(context, ref, townsAsync),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     Text(
                       selectedTown?.name ?? 'اختر المنطقة', 
                       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)
                     ),
                     const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // TODO: Navigate to notifications
              },
            ),
          ],
        ),
        body: _currentIndex == 0
            ? Consumer(
                builder: (context, ref, child) => _buildHomeTab(ref),
              )
            : _currentIndex == 1
                ? const OrdersListScreen()
                : _currentIndex == 3
                    ? const ProfileScreen()
                    : _buildOtherTabs(),
        bottomNavigationBar: _buildBottomNavBar(),
      );
    },
  );
}

// دالة لإظهار Dialog الاختيار
void _showTownSelectionDialog(BuildContext context, WidgetRef ref, AsyncValue<List<Town>> townsAsync) {
  showModalBottomSheet(
    context: context,
    builder: (ctx) => townsAsync.when(
      data: (towns) => ListView.builder(
        itemCount: towns.length,
        itemBuilder: (ctx, index) => ListTile(
          title: Text(towns[index].name),
          onTap: () {
            ref.read(selectedTownProvider.notifier).setTown(towns[index]);
            // تحديث قائمة المتاجر سيحدث تلقائياً لأن storesProvider يراقب selectedTownProvider
            Navigator.pop(ctx);
          },
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ: $e')),
    ),
  );
}

  Widget _buildHomeTab(WidgetRef ref) {
    final storesState = ref.watch(storesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(storesProvider.notifier).refresh();
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar
          const SliverToBoxAdapter(
            child: HomeAppBar(),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: AppSearchField(
                hint: 'ابحث عن محلات أو منتجات',
                controller: _searchController,
                onChanged: (value) {
                  // Debounce search
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (_searchController.text == value) {
                      ref.read(storesProvider.notifier).searchStores(value);
                    }
                  });
                },
              ),
            ),
          ),

          // Categories
          categoriesAsync.when(
            data: (categories) => SliverToBoxAdapter(
              child: CategoryChips(
                categories: categories,
                selectedCategoryId: storesState.selectedCategoryId,
                onCategorySelected: (categoryId) {
                  ref.read(storesProvider.notifier).filterByCategory(categoryId);
                },
              ),
            ),
            loading: () => const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
            error: (_, __) => const SliverToBoxAdapter(
              child: SizedBox.shrink(),
            ),
          ),

          // Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    storesState.searchQuery.isEmpty
                        ? 'المحلات القريبة منك'
                        : 'نتائج البحث',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (storesState.stores.isNotEmpty)
                    Text(
                      '${storesState.stores.length} محل',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.grey600,
                          ),
                    ),
                ],
              ),
            ),
          ),

          // Error State
          if (storesState.error != null && storesState.stores.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    Text(
                      'حدث خطأ في تحميل المحلات',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall),
                    Text(
                      storesState.error!,
                      style: const TextStyle(color: AppColors.grey600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(storesProvider.notifier).refresh();
                      },
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            )
          // Empty State
          else if (storesState.stores.isEmpty && !storesState.isLoading)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.store_outlined,
                      size: 64,
                      color: AppColors.grey400,
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    Text(
                      storesState.searchQuery.isEmpty
                          ? 'لا توجد محلات متاحة حالياً'
                          : 'لم نجد محلات تطابق بحثك',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppDimensions.paddingSmall),
                    const Text(
                      'جرب البحث بكلمة أخرى',
                      style: TextStyle(color: AppColors.grey600),
                    ),
                  ],
                ),
              ),
            )
          // Stores Grid
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppDimensions.paddingMedium,
                  crossAxisSpacing: AppDimensions.paddingMedium,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= storesState.stores.length) {
                      return const SizedBox.shrink();
                    }

                    final store = storesState.stores[index];
                    
                    return StoreCard(
                      storeName: store.name,
                      category: store.categoryName ?? 'عام',
                      rating: store.rating ?? 0.0,
                      reviewsCount: store.reviewsCount ?? 0,
                      deliveryTime: store.deliveryTime,
                      deliveryFee: 15, // TODO: Calculate from delivery rates
                      imageUrl: store.imageUrl ?? 'https://via.placeholder.com/300',
                      isOpen: store.isActive,
                      onTap: () {
                        // Navigate to store details
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => StoreDetailsScreen(store: store),
                          ),
                        );
                      },
                    );
                  },
                  childCount: storesState.stores.length,
                ),
              ),
            ),

          // Loading Indicator
          if (storesState.isLoading && storesState.stores.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.paddingMedium),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),

          // Initial Loading
          if (storesState.isLoading && storesState.stores.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: AppDimensions.paddingMedium),
                    Text(
                      'جاري تحميل المحلات...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.grey600,
                          ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: AppDimensions.paddingLarge),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherTabs() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getTabIcon(_currentIndex),
            size: 64,
            color: AppColors.grey400,
          ),
          const SizedBox(height: AppDimensions.paddingMedium),
          Text(
            _getTabLabel(_currentIndex),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.grey600,
                ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),
          const Text(
            'قريباً...',
            style: TextStyle(color: AppColors.grey500),
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
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey400,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'طلباتي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'المفضلة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }

  IconData _getTabIcon(int index) {
    switch (index) {
      case 0:
        return Icons.home;
      case 1:
        return Icons.receipt_long;
      case 2:
        return Icons.favorite;
      case 3:
        return Icons.person;
      default:
        return Icons.home;
    }
  }

  String _getTabLabel(int index) {
    switch (index) {
      case 0:
        return 'الرئيسية';
      case 1:
        return 'طلباتي';
      case 2:
        return 'المفضلة';
      case 3:
        return 'حسابي';
      default:
        return '';
    }
  }
}
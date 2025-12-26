import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../shared/models/store.dart';
import '../../../../../shared/models/product.dart';
import '../../../../../features/customer/home/data/repositories/stores_repository.dart';
import '../../../../../features/customer/home/presentation/providers/stores_provider.dart';
import '../widgets/product_card_horizontal.dart';
import '../widgets/store_info_header.dart';

// Minimal provider for store products used by UI
class StoreProductsState {
  final List<Product> products;
  final List<String> categories;
  final bool isLoading;
  final String? error;

  StoreProductsState({
    this.products = const [],
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  StoreProductsState copyWith({
    List<Product>? products,
    List<String>? categories,
    bool? isLoading,
    String? error,
  }) {
    return StoreProductsState(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class StoreProductsNotifier extends StateNotifier<StoreProductsState> {
  final String storeId;
  final StoresRepository _storesRepository;

  StoreProductsNotifier(this.storeId, this._storesRepository) : super(StoreProductsState()) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final products = await _storesRepository.getProductsByStore(storeId, isActive: true);
      final categories = await _storesRepository.getCategories(isActive: true);

      // Extract unique category IDs from products
      final productCategoryIds = products
          .map((product) => product.categoryId)
          .where((id) => id != null)
          .toSet();

      // Filter categories to only include those used by products
      final filteredCategories = categories
          .where((category) => productCategoryIds.contains(category.id))
          .map((category) => category.name)
          .toList();

      state = state.copyWith(
        products: products,
        categories: filteredCategories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void filterByCategory(String? categoryId) {
    // This will be implemented when we have category filtering in the repository
  }
}

final storeProductsProvider = StateNotifierProvider.family<StoreProductsNotifier, StoreProductsState, String>((ref, storeId) {
  final storesRepository = ref.watch(storesRepositoryProvider);
  return StoreProductsNotifier(storeId, storesRepository);
});

class StoreDetailsScreen extends ConsumerStatefulWidget {
  final Store store;

  const StoreDetailsScreen({
    super.key,
    required this.store,
  });

  @override
  ConsumerState<StoreDetailsScreen> createState() => _StoreDetailsScreenState();
}

class _StoreDetailsScreenState extends ConsumerState<StoreDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load products when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(storeProductsProvider(widget.store.id).notifier).loadProducts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(storeProductsProvider(widget.store.id));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // Store Header with Image
            _buildSliverAppBar(),

            // Store Info
            SliverToBoxAdapter(
              child: StoreInfoHeader(store: widget.store),
            ),

            // Categories Tab
            if (productsState.categories.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildCategoriesTab(productsState.categories),
              ),

            // Products List
            if (productsState.isLoading && productsState.products.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (productsState.error != null && productsState.products.isEmpty)
              SliverFillRemaining(
                child: _buildErrorState(productsState.error!),
              )
            else if (productsState.products.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: AppColors.grey400,
                      ),
                      SizedBox(height: AppDimensions.paddingMedium),
                      Text(
                        'لا توجد منتجات متاحة حالياً',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = productsState.products[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.paddingMedium,
                        ),
                        child: ProductCardHorizontal(
                          product: product,
                          onAddToCart: () {
                            // TODO: Add to cart
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('تمت إضافة ${product.name} للسلة'),
                                backgroundColor: AppColors.success,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: productsState.products.length,
                  ),
                ),
              ),

            // Bottom spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),

        // Floating Cart Button
        floatingActionButton: _buildCartButton(),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.white.withAlpha(230),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back,
            color: AppColors.grey900,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white.withAlpha(230),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border,
              color: AppColors.grey900,
            ),
          ),
          onPressed: () {
            // Toggle favorite
          },
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white.withAlpha(230),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.share,
              color: AppColors.grey900,
            ),
          ),
          onPressed: () {
            // Share store
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: widget.store.coverImageUrl ?? 
                         widget.store.imageUrl ?? 
                         'https://via.placeholder.com/800x400',
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.grey200,
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.grey200,
                child: const Icon(
                  Icons.store,
                  size: 64,
                  color: AppColors.grey400,
                ),
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.black.withAlpha(179),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesTab(List<String> categories) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.paddingSmall,
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(
          width: AppDimensions.paddingSmall,
        ),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCategoryChip(
              'الكل',
              isSelected: _selectedCategoryId == null,
              onTap: () {
                setState(() => _selectedCategoryId = null);
                ref
                    .read(storeProductsProvider(widget.store.id).notifier)
                    .filterByCategory(null);
              },
            );
          }

          final category = categories[index - 1];
          return _buildCategoryChip(
            category,
            isSelected: _selectedCategoryId == category,
            onTap: () {
              setState(() => _selectedCategoryId = category);
              ref
                  .read(storeProductsProvider(widget.store.id).notifier)
                  .filterByCategory(category);
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(
    String label, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMedium,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.grey100,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.grey700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
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
            'حدث خطأ في تحميل المنتجات',
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
              ref
                  .read(storeProductsProvider(widget.store.id).notifier)
                  .loadProducts();
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartButton() {
    // TODO: Get cart count from cart provider
    const cartCount = 2;

    if (cartCount == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton.icon(
        onPressed: () {
          // Navigate to cart
        },
        icon: const Icon(Icons.shopping_cart),
        label: Text('عرض السلة ($cartCount)'), // ignore: prefer_const_constructors
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLarge,
            vertical: AppDimensions.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          ),
        ),
      ),
    );
  }
}
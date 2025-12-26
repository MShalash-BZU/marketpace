import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../shared/models/store.dart';
import '../../../../../shared/models/product.dart';
import '../../data/repositories/products_repository.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../cart/presentation/screens/cart_screen.dart';
import 'package:badges/badges.dart' as badges;

// Provider لجلب المنتجات
final storeProductsProvider = FutureProvider.family<List<Product>, String>((ref, storeId) async {
  return await ProductsRepository().getStoreProducts(storeId);
});

class StoreDetailsScreen extends ConsumerWidget {
  final Store store;

  const StoreDetailsScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(storeProductsProvider(store.id));
    final cartCount = ref.watch(cartItemsCountProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. صورة الغلاف ومعلومات المتجر (SliverAppBar)
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(store.name, style: const TextStyle(color: Colors.black, fontSize: 16)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  store.coverImageUrl != null
                      ? CachedNetworkImage(imageUrl: store.coverImageUrl!, fit: BoxFit.cover)
                      : Container(color: AppColors.primaryLight),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.white.withAlpha(204)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // زر السلة
               Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: badges.Badge(
                  position: badges.BadgePosition.topEnd(top: 0, end: 3),
                  badgeContent: Text('$cartCount', style: const TextStyle(color: Colors.white, fontSize: 10)),
                  showBadge: cartCount > 0,
                  child: IconButton(
                    icon: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.shopping_cart, color: AppColors.primary),
                    ),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
                  ),
                ),
              ),
            ],
          ),

          // 2. معلومات التوصيل والتقييم
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoChip(Icons.star, '${4.5}', 'تقييم'), // Static for now
                      _buildInfoChip(Icons.timer, '${store.expectedPrepMinutes} دقيقة', 'وقت التحضير'),
                      _buildInfoChip(Icons.delivery_dining, '15 ر.س', 'التوصيل'), // Static until we link DeliveryRates
                    ],
                  ),
                  const Divider(height: 30),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text('القائمة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),

          // 3. قائمة المنتجات
          productsAsync.when(
            data: (products) => products.isEmpty
                ? const SliverToBoxAdapter(child: Center(child: Text('لا توجد منتجات حالياً')))
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = products[index];
                        return _ProductItemRow(product: product);
                      },
                      childCount: products.length,
                    ),
                  ),
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverToBoxAdapter(child: Text('خطأ: $e')),
          ),
          
          // مساحة في الأسفل لعدم تغطية آخر عنصر
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String subLabel) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(subLabel, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

// ويدجت لعنصر المنتج
class _ProductItemRow extends ConsumerWidget {
  final Product product;

  const _ProductItemRow({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // التحقق مما إذا كان المنتج في السلة وكميته
    final cart = ref.watch(cartProvider);
    final existingItem = cart.findItemByProductId(product.id);
    final quantity = existingItem?.quantity ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withAlpha(26), blurRadius: 5)],
      ),
      child: Row(
        children: [
          // الصورة
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 80,
              color: Colors.grey[200],
              child: product.imageUrls.isNotEmpty
                  ? CachedNetworkImage(imageUrl: product.imageUrls.first, fit: BoxFit.cover)
                  : const Icon(Icons.fastfood, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 12),
          // التفاصيل
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  product.description ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text('${product.price} ر.س', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // أزرار التحكم بالكمية
          Column(
            children: [
              if (quantity > 0) ...[
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.primary),
                  onPressed: () {
                    ref.read(cartProvider.notifier).increaseQuantity(product.id);
                  },
                ),
                Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                  onPressed: () {
                    ref.read(cartProvider.notifier).decreaseQuantity(product.id);
                  },
                ),
              ] else
                ElevatedButton(
                  onPressed: () {
                    ref.read(cartProvider.notifier).addProduct(product);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10),
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
            ],
          )
        ],
      ),
    );
  }
}
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../shared/models/product.dart';

class ProductsRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Product>> getStoreProducts(String storeId) async {
    try {
      final response = await _supabase
          .from('products')
          .select('*, product_images(url)')
          .eq('store_id', storeId)
          .eq('is_active', true)
          .order('created_at'); // يمكن الترتيب حسب القسم لاحقاً

      return (response as List).map((json) {
         // معالجة الصور إذا كانت مصفوفة أو JSON
         return Product.fromJson(json);
      }).toList();
    } catch (e) {
      throw ServerException('فشل جلب المنتجات: ${e.toString()}');
    }
  }
}
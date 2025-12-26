import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../shared/models/cart.dart';

class CheckoutRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> submitOrder({
    required Cart cart,
    required String userId,
    required String townId,
    required String address,
    required String paymentMethod,
    required double deliveryFee,
  }) async {
    try {
      // 1. تحويل عناصر السلة إلى JSON بسيط يفهمه السيرفر
      final List<Map<String, dynamic>> itemsJson = cart.items.map((item) {
        return {
          'store_id': item.product.storeId,
          'product_id': item.product.id,
          'name': item.product.name,
          'price': item.product.price,
          'qty': item.quantity,
        };
      }).toList();

      // 2. استدعاء الدالة في قاعدة البيانات (RPC Call)
      final orderId = await _supabase.rpc('place_order', params: {
        'p_customer_id': userId,
        'p_town_id': townId,
        'p_address_text': address,
        'p_payment_method': paymentMethod,
        'p_subtotal': cart.subtotal,
        'p_delivery_fee': deliveryFee,
        'p_grand_total': cart.subtotal + deliveryFee, // خصم الكوبون يضاف لاحقاً هنا
        'p_items': itemsJson,
      });

      return orderId as String;
    } on PostgrestException catch (e) {
      throw ServerException('فشل الطلب: ${e.message}');
    } catch (e) {
      throw ServerException('خطأ غير متوقع: $e');
    }
  }
}
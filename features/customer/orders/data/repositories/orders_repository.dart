import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../shared/models/order.dart';

class OrdersRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get user orders
  Future<List<Order>> getUserOrders(String userId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .eq('customer_id', userId)
          .order('created_at', ascending: false);

      final orders = (response as List).map((json) => Order.fromJson(json)).toList();
      return orders;
    } catch (e) {
      throw ServerException('Failed to fetch orders: ${e.toString()}');
    }
  }

  // Get order by ID
  Future<Order> getOrderById(String orderId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select()
          .eq('id', orderId)
          .single();

      return Order.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to fetch order: ${e.toString()}');
    }
  }

  // Get order items
  Future<List<Map<String, dynamic>>> getOrderItems(String orderId) async {
    try {
      final response = await _supabase
          .from('order_items')
          .select()
          .eq('order_id', orderId);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw ServerException('Failed to fetch order items: ${e.toString()}');
    }
  }

  // Cancel order
  Future<void> cancelOrder(String orderId) async {
    try {
      await _supabase.from('orders').update({
        'status': 'CANCELLED',
      }).eq('id', orderId);
    } catch (e) {
      throw ServerException('Failed to cancel order: ${e.toString()}');
    }
  }
}
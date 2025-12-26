import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/models/order.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/orders_repository.dart';

// Repository Provider
final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepository();
});

// Orders State
class OrdersState {
  final List<Order> orders;
  final bool isLoading;
  final String? error;

  const OrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
  });

  OrdersState copyWith({
    List<Order>? orders,
    bool? isLoading,
    String? error,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Orders Notifier
class OrdersNotifier extends StateNotifier<OrdersState> {
  final OrdersRepository _repository;
  final String userId;

  OrdersNotifier(this._repository, this.userId) : super(const OrdersState()) {
    loadOrders();
  }

  Future<void> loadOrders() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final orders = await _repository.getUserOrders(userId);
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await loadOrders();
  }

  Future<bool> cancelOrder(String orderId) async {
    try {
      await _repository.cancelOrder(orderId);
      await loadOrders(); // Reload orders
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

// Orders Provider
final ordersProvider = StateNotifierProvider<OrdersNotifier, OrdersState>((ref) {
  final user = ref.watch(currentUserProvider);
  final repository = ref.watch(ordersRepositoryProvider);
  
  if (user == null) {
    throw Exception('User not logged in');
  }

  return OrdersNotifier(repository, user.id);
});

// Order Details Provider (for single order)
final orderDetailsProvider = FutureProvider.family<Order, String>((ref, orderId) async {
  final repository = ref.watch(ordersRepositoryProvider);
  return repository.getOrderById(orderId);
});

// Order Items Provider
final orderItemsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, orderId) async {
    final repository = ref.watch(ordersRepositoryProvider);
    return repository.getOrderItems(orderId);
  },
);
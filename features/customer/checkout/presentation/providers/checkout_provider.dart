import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../home/presentation/providers/town_provider.dart';
import '../../data/repositories/checkout_repository.dart';

// الحالة (State) الخاصة بعملية الشراء
class CheckoutState {
  final bool isLoading;
  final String? error;
  final String? successOrderId;

  CheckoutState({this.isLoading = false, this.error, this.successOrderId});
}

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final CheckoutRepository _repository;
  final Ref _ref;

  CheckoutNotifier(this._repository, this._ref) : super(CheckoutState());

  Future<void> placeOrder({
    required String address,
    required String paymentMethod, // 'COD' or 'ONLINE'
  }) async {
    state = CheckoutState(isLoading: true);

    try {
      // جلب البيانات اللازمة من البروفايدرز الأخرى
      final cart = _ref.read(cartProvider);
      final user = _ref.read(currentUserProvider);
      final town = _ref.read(selectedTownProvider);

      if (cart.isEmpty) throw 'السلة فارغة';
      if (user == null) throw 'يجب تسجيل الدخول أولاً';
      if (town == null) throw 'يجب اختيار منطقة التوصيل';

      // TODO: جلب سعر التوصيل الحقيقي من قاعدة البيانات
      const double deliveryFee = 15.0; 

      final orderId = await _repository.submitOrder(
        cart: cart,
        userId: user.id,
        townId: town.id,
        address: address,
        paymentMethod: paymentMethod,
        deliveryFee: deliveryFee,
      );

      // نجاح! قم بتفريغ السلة
      await _ref.read(cartProvider.notifier).clearCart();
      
      state = CheckoutState(successOrderId: orderId);
    } catch (e) {
      state = CheckoutState(error: e.toString().replaceAll('Exception: ', ''));
    }
  }
}

final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier(CheckoutRepository(), ref);
});
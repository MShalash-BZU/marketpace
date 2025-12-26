import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../../../shared/models/cart.dart';
import '../../../../../shared/models/cart_item.dart';
import '../../../../../shared/models/product.dart';

// Cart Notifier
class CartNotifier extends StateNotifier<Cart> {
  static const String _cartKey = 'cart_data';
  final Uuid _uuid = const Uuid();

  CartNotifier() : super(const Cart()) {
    _loadCart();
  }

  // Load cart from storage
  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);
      
      if (cartJson != null) {
        final data = jsonDecode(cartJson) as Map<String, dynamic>;
        state = Cart.fromJson(data);
      }
    } catch (e) {
      // If error loading, start with empty cart
      state = const Cart();
    }
  }

  // Save cart to storage
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(state.toJson());
      await prefs.setString(_cartKey, cartJson);
    } catch (e) {
      // Handle save error
    }
  }

  // Add product to cart
  Future<void> addProduct(Product product, {int quantity = 1, String? notes}) async {
    if (!product.isInStock || quantity <= 0) return;

    final existingItem = state.findItemByProductId(product.id);

    if (existingItem != null) {
      // Update quantity if product already in cart
      final newQuantity = existingItem.quantity + quantity;
      
      // Check stock
      if (newQuantity > product.stockQty) {
        throw Exception('الكمية المطلوبة غير متوفرة في المخزون');
      }

      await updateQuantity(product.id, newQuantity);
    } else {
      // Add new item
      final newItem = CartItem(
        id: _uuid.v4(),
        product: product,
        quantity: quantity,
        notes: notes,
      );

      state = state.copyWith(
        items: [...state.items, newItem],
      );

      await _saveCart();
    }
  }

  // Remove product from cart
  Future<void> removeProduct(String productId) async {
    state = state.copyWith(
      items: state.items.where((item) => item.product.id != productId).toList(),
    );

    await _saveCart();
  }

  // Update quantity
  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await removeProduct(productId);
      return;
    }

    final items = state.items.map((item) {
      if (item.product.id == productId) {
        // Check stock
        if (quantity > item.product.stockQty) {
          throw Exception('الكمية المطلوبة غير متوفرة في المخزون');
        }
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = state.copyWith(items: items);
    await _saveCart();
  }

  // Increase quantity
  Future<void> increaseQuantity(String productId) async {
    final item = state.findItemByProductId(productId);
    if (item != null && item.canAddMore) {
      await updateQuantity(productId, item.quantity + 1);
    }
  }

  // Decrease quantity
  Future<void> decreaseQuantity(String productId) async {
    final item = state.findItemByProductId(productId);
    if (item != null) {
      await updateQuantity(productId, item.quantity - 1);
    }
  }

  // Update notes
  Future<void> updateNotes(String productId, String? notes) async {
    final items = state.items.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(notes: notes);
      }
      return item;
    }).toList();

    state = state.copyWith(items: items);
    await _saveCart();
  }

  // Clear cart
  Future<void> clearCart() async {
    state = const Cart();
    await _saveCart();
  }

  // Clear items from specific store
  Future<void> clearStoreItems(String storeId) async {
    state = state.copyWith(
      items: state.items
          .where((item) => item.product.storeId != storeId)
          .toList(),
    );

    await _saveCart();
  }

  // Validate cart (check stock availability)
  List<String> validateCart() {
    final errors = <String>[];

    for (final item in state.items) {
      if (!item.product.isActive) {
        errors.add('${item.product.name} غير متوفر حالياً');
      } else if (item.quantity > item.product.stockQty) {
        errors.add('${item.product.name}: متوفر فقط ${item.product.stockQty} قطعة');
      }
    }

    return errors;
  }
}

// Cart Provider
final cartProvider = StateNotifierProvider<CartNotifier, Cart>((ref) {
  return CartNotifier();
});

// Computed Providers
final cartItemsCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).totalItems;
});

final cartSubtotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).subtotal;
});

final cartStoreCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).storeCount;
});

final cartIsEmptyProvider = Provider<bool>((ref) {
  return ref.watch(cartProvider).isEmpty;
});

// Check if specific product is in cart
final productInCartProvider = Provider.family<bool, String>((ref, productId) {
  return ref.watch(cartProvider).hasProduct(productId);
});

// Get quantity of specific product
final productQuantityProvider = Provider.family<int, String>((ref, productId) {
  return ref.watch(cartProvider).getProductQuantity(productId);
});
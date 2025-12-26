import 'package:equatable/equatable.dart';
import 'cart_item.dart';

class Cart extends Equatable {
  final List<CartItem> items;

  const Cart({
    this.items = const [],
  });

  // Get total items count
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  // Get subtotal (products only)
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.itemTotal);

  // Check if cart is empty
  bool get isEmpty => items.isEmpty;

  // Check if cart is not empty
  bool get isNotEmpty => items.isNotEmpty;

  // Get items grouped by store
  Map<String, List<CartItem>> get itemsByStore {
    final Map<String, List<CartItem>> grouped = {};
    
    for (final item in items) {
      final storeId = item.product.storeId;
      if (!grouped.containsKey(storeId)) {
        grouped[storeId] = [];
      }
      grouped[storeId]!.add(item);
    }
    
    return grouped;
  }

  // Get unique store IDs
  List<String> get storeIds {
    return items.map<String>((item) => item.product.storeId).toSet().toList();
  }

  // Get store count
  int get storeCount => storeIds.length;

  // Find item by product ID
  CartItem? findItemByProductId(String productId) {
    try {
      return items.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Check if product is in cart
  bool hasProduct(String productId) {
    return findItemByProductId(productId) != null;
  }

  // Get quantity of product
  int getProductQuantity(String productId) {
    final item = findItemByProductId(productId);
    return item?.quantity ?? 0;
  }

  Cart copyWith({
    List<CartItem>? items,
  }) {
    return Cart(
      items: items ?? this.items,
    );
  }

  // To JSON (for local storage)
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  // From JSON
  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [items];
}
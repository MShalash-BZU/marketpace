import 'package:equatable/equatable.dart';
import 'product.dart';

class CartItem extends Equatable {
  final String id;
  final Product product;
  final int quantity;
  final String? notes;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    this.notes,
  });

  // Calculate item total
  double get itemTotal => product.price * quantity;

  // Check if can add more
  bool get canAddMore => quantity < product.stockQty;

  // Check if valid (in stock)
  bool get isValid => product.isInStock && quantity <= product.stockQty;

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    String? notes,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }

  // To JSON (for local storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'notes': notes,
    };
  }

  // From JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      notes: json['notes'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, product, quantity, notes];
}
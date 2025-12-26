import 'product.dart';
import '../../../core/utils/formatters.dart';

extension ProductExtensions on Product {
  String? get mainImageUrl => primaryImageUrl;

  String get formattedPrice => price.formatCurrency;

  bool get isLowStock => stockQty > 0 && stockQty <= lowStockThreshold;

  bool get isOutOfStock => stockQty <= 0;

  String get stockStatus => isOutOfStock ? 'غير متوفر' : (isLowStock ? 'كمية قليلة' : 'متوفر');
}

import 'package:equatable/equatable.dart';

class Product extends Equatable {
	final String id;
	final String name;
	final String storeId;
	final String? categoryId;
	final String? description;
	final double price;
	final String? sku;
	final int stockQty;
	final int lowStockThreshold;
	final bool isActive;
	final DateTime createdAt;
	final List<String> imageUrls;

	const Product({
		required this.id,
		required this.name,
		required this.storeId,
		this.categoryId,
		this.description,
		required this.price,
		this.sku,
		required this.stockQty,
		required this.lowStockThreshold,
		this.isActive = true,
		required this.createdAt,
		this.imageUrls = const [],
	});

	bool get isInStock => stockQty > 0;
	bool get isLowStock => stockQty <= lowStockThreshold && stockQty > 0;
	bool get isOutOfStock => stockQty == 0;
	String? get primaryImageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;

	Product copyWith({
		String? id,
		String? name,
		String? storeId,
		String? categoryId,
		String? description,
		double? price,
		String? sku,
		int? stockQty,
		int? lowStockThreshold,
		bool? isActive,
		DateTime? createdAt,
		List<String>? imageUrls,
	}) {
		return Product(
			id: id ?? this.id,
			name: name ?? this.name,
			storeId: storeId ?? this.storeId,
			categoryId: categoryId ?? this.categoryId,
			description: description ?? this.description,
			price: price ?? this.price,
			sku: sku ?? this.sku,
			stockQty: stockQty ?? this.stockQty,
			lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
			isActive: isActive ?? this.isActive,
			createdAt: createdAt ?? this.createdAt,
			imageUrls: imageUrls ?? this.imageUrls,
		);
	}

	Map<String, dynamic> toJson() => {
				'id': id,
				'name': name,
				'store_id': storeId,
				'category_id': categoryId,
				'description': description,
				'price': price,
				'sku': sku,
				'stock_qty': stockQty,
				'low_stock_threshold': lowStockThreshold,
				'is_active': isActive,
				'created_at': createdAt.toIso8601String(),
			};

	factory Product.fromJson(Map<String, dynamic> json) {
		return Product(
			id: json['id'] as String? ?? '',
			name: json['name'] as String? ?? '',
			storeId: json['store_id'] as String? ?? json['storeId'] as String? ?? '',
			categoryId: json['category_id'] as String? ?? json['categoryId'] as String?,
			description: json['description'] as String?,
			price: (json['price'] as num?)?.toDouble() ?? 0.0,
			sku: json['sku'] as String?,
			stockQty: (json['stock_qty'] as int?) ?? (json['stockQty'] as int?) ?? 0,
			lowStockThreshold: (json['low_stock_threshold'] as int?) ?? 10,
			isActive: json['is_active'] as bool? ?? (json['isActive'] as bool?) ?? true,
			createdAt: json['created_at'] != null 
				? DateTime.parse(json['created_at'] as String)
				: DateTime.now(),
			imageUrls: (json['image_urls'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
		);
	}

	@override
	List<Object?> get props => [id, name, storeId, categoryId, description, price, sku, stockQty, lowStockThreshold, isActive, createdAt, imageUrls];
}

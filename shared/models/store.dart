import 'package:equatable/equatable.dart';

class Store extends Equatable {
  final String id;
  final String name;
  final String townId;
  final String addressText;
  final String categoryId;
  final String? categoryName;
  final String ownerId;
  final bool isActive;
  final String? openingHoursJson;
  final int expectedPrepMinutes;
  final String? imageUrl;
  final String? coverImageUrl;
  final double? rating;
  final int? reviewsCount;
  final DateTime createdAt;

  const Store({
    required this.id,
    required this.name,
    required this.townId,
    required this.addressText,
    required this.categoryId,
    this.categoryName,
    required this.ownerId,
    required this.isActive,
    this.openingHoursJson,
    required this.expectedPrepMinutes,
    this.imageUrl,
    this.coverImageUrl,
    this.rating,
    this.reviewsCount,
    required this.createdAt,
  });

  // From JSON
  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] as String,
      name: json['name'] as String,
      townId: json['town_id'] as String,
      addressText: json['address_text'] as String,
      categoryId: json['category_id'] as String,
      categoryName: json['category_name'] as String?,
      ownerId: json['owner_user_id'] as String,
      isActive: json['is_active'] as bool? ?? true,
      openingHoursJson: json['opening_hours_json'] as String?,
      expectedPrepMinutes: json['expected_prep_minutes'] as int? ?? 30,
      imageUrl: json['image_url'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewsCount: json['reviews_count'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'town_id': townId,
      'address_text': addressText,
      'category_id': categoryId,
      'owner_user_id': ownerId,
      'is_active': isActive,
      'opening_hours_json': openingHoursJson,
      'expected_prep_minutes': expectedPrepMinutes,
      'image_url': imageUrl,
      'cover_image_url': coverImageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Store copyWith({
    String? id,
    String? name,
    String? townId,
    String? addressText,
    String? categoryId,
    String? categoryName,
    String? ownerId,
    bool? isActive,
    String? openingHoursJson,
    int? expectedPrepMinutes,
    String? imageUrl,
    String? coverImageUrl,
    double? rating,
    int? reviewsCount,
    DateTime? createdAt,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      townId: townId ?? this.townId,
      addressText: addressText ?? this.addressText,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      ownerId: ownerId ?? this.ownerId,
      isActive: isActive ?? this.isActive,
      openingHoursJson: openingHoursJson ?? this.openingHoursJson,
      expectedPrepMinutes: expectedPrepMinutes ?? this.expectedPrepMinutes,
      imageUrl: imageUrl ?? this.imageUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper methods
  String get deliveryTime => '$expectedPrepMinutes-${expectedPrepMinutes + 10} دقيقة';
  
  bool get hasRating => rating != null && rating! > 0;
  
  String get displayRating => rating?.toStringAsFixed(1) ?? '0.0';

  @override
  List<Object?> get props => [
        id,
        name,
        townId,
        addressText,
        categoryId,
        categoryName,
        ownerId,
        isActive,
        openingHoursJson,
        expectedPrepMinutes,
        imageUrl,
        coverImageUrl,
        rating,
        reviewsCount,
        createdAt,
      ];
}
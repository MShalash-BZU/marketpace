import 'package:equatable/equatable.dart';

enum UserRole {
  customer,
  storeOwner,
  storeStaff,
  courier,
  admin,
}

extension UserRoleExtension on UserRole {
  String get dbValue {
    switch (this) {
      case UserRole.customer:
        return 'CUSTOMER';
      case UserRole.storeOwner:
        return 'STORE_OWNER';
      case UserRole.storeStaff:
        return 'STORE_STAFF';
      case UserRole.courier:
        return 'COURIER';
      case UserRole.admin:
        return 'ADMIN';
    }
  }

  static UserRole fromDbValue(String value) {
    switch (value) {
      case 'CUSTOMER':
        return UserRole.customer;
      case 'STORE_OWNER':
        return UserRole.storeOwner;
      case 'STORE_STAFF':
        return UserRole.storeStaff;
      case 'COURIER':
        return UserRole.courier;
      case 'ADMIN':
        return UserRole.admin;
      default:
        return UserRole.customer;
    }
  }
}

enum UserStatus {
  active,
  blocked,
  suspended,
}

class User extends Equatable {
  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final UserRole role;
  final UserStatus status;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const User({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    required this.role,
    required this.status,
    this.profileImageUrl,
    required this.createdAt,
    this.lastLoginAt,
  });

  bool get isActive => status == UserStatus.active;
  bool get isBlocked => status == UserStatus.blocked;
  bool get isCustomer => role == UserRole.customer;
  bool get isStoreOwner => role == UserRole.storeOwner;
  bool get isCourier => role == UserRole.courier;
  bool get isAdmin => role == UserRole.admin;

  // For compatibility with repository expectations
  User toEntity() => this;

  User copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? email,
    UserRole? role,
    UserStatus? status,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        phone,
        email,
        role,
        status,
        profileImageUrl,
        createdAt,
        lastLoginAt,
      ];

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? json['fullName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      role: UserRoleExtension.fromDbValue(json['role'] as String? ?? 'CUSTOMER'),
      status: UserStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'active'),
        orElse: () => UserStatus.active,
      ),
      profileImageUrl: json['profile_image_url'] as String? ?? json['profileImageUrl'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      lastLoginAt: json['last_login_at'] != null ? DateTime.parse(json['last_login_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'role': role.dbValue,
      'status': status.name,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }
}
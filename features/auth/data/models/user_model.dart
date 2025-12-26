import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.phone,
    super.email,
    required super.role,
    required super.status,
    super.profileImageUrl,
    required super.createdAt,
    super.lastLoginAt,
  });

  // From JSON (Supabase response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      role: _roleFromString(json['role'] as String),
      status: _statusFromString(json['status'] as String),
      profileImageUrl: json['profile_image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
    );
  }

  // To JSON (for Supabase)
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'role': _roleToString(role),
      'status': _statusToString(status),
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }

  // Convert to Entity
  @override
  User toEntity() {
    return User(
      id: id,
      fullName: fullName,
      phone: phone,
      email: email,
      role: role,
      status: status,
      profileImageUrl: profileImageUrl,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
    );
  }

  // From Entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      fullName: user.fullName,
      phone: user.phone,
      email: user.email,
      role: user.role,
      status: user.status,
      profileImageUrl: user.profileImageUrl,
      createdAt: user.createdAt,
      lastLoginAt: user.lastLoginAt,
    );
  }

  // Helper methods for role conversion
  static UserRole _roleFromString(String role) {
    switch (role.toUpperCase()) {
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

  static String _roleToString(UserRole role) {
    switch (role) {
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

  // Helper methods for status conversion
  static UserStatus _statusFromString(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return UserStatus.active;
      case 'BLOCKED':
        return UserStatus.blocked;
      case 'SUSPENDED':
        return UserStatus.suspended;
      default:
        return UserStatus.active;
    }
  }

  static String _statusToString(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return 'ACTIVE';
      case UserStatus.blocked:
        return 'BLOCKED';
      case UserStatus.suspended:
        return 'SUSPENDED';
    }
  }

  @override
  UserModel copyWith({
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
    return UserModel(
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
}
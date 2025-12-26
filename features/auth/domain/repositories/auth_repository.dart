import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  // Login with email & password
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  // Register new user
  Future<Either<Failure, User>> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required UserRole role,
  });

  // Login with phone & OTP
  Future<Either<Failure, void>> sendOTP(String phone);
  Future<Either<Failure, User>> verifyOTP({
    required String phone,
    required String otp,
  });

  // Logout
  Future<Either<Failure, void>> logout();

  // Get current user
  Future<Either<Failure, User?>> getCurrentUser();

  // Check if user is logged in
  Future<bool> isLoggedIn();

  // Update profile
  Future<Either<Failure, User>> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? email,
    String? profileImageUrl,
  });

  // Change password
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  // Reset password
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  });

  // Delete account
  Future<Either<Failure, void>> deleteAccount(String userId);
}
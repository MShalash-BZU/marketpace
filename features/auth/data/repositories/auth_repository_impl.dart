import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  // يمكن إضافة networkInfo لاحقاً للتحقق من الإنترنت

  AuthRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.login(email, password);
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final user = await remoteDataSource.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        role: role.dbValue,
      );
      return Right(user);
    } on AuthException catch (e) {
       // تحسين رسائل الخطأ بناءً على نوع الخطأ من سوبابيس
      if (e.message.contains('already registered')) {
        return const Left(EmailAlreadyExistsFailure());
      }
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> sendOTP(String phone) async {
    // TODO: Implement sendOTP
    return const Left(ServerFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, User>> verifyOTP({
    required String phone,
    required String otp,
  }) async {
    // TODO: Implement verifyOTP
    return const Left(ServerFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return user != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? email,
    String? profileImageUrl,
  }) async {
    // TODO: Implement updateProfile
    return const Left(ServerFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // TODO: Implement changePassword
    return const Left(ServerFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    // TODO: Implement sendPasswordResetEmail
    return const Left(ServerFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    // TODO: Implement resetPassword
    return const Left(ServerFailure('Not implemented'));
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String userId) async {
    // TODO: Implement deleteAccount
    return const Left(ServerFailure('Not implemented'));
  }
}
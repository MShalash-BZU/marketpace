import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure(this.message, [this.code]);

  @override
  List<Object?> get props => [message, code];
}

// Server Failures
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'حدث خطأ في الخادم', super.code]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'لا يوجد اتصال بالإنترنت', super.code]);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'غير مصرح لك بالوصول', super.code = 401]);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'لم يتم العثور على البيانات', super.code = 404]);
}

// Auth Failures
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'فشل تسجيل الدخول', super.code]);
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure([
    super.message = 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
    super.code,
  ]);
}

class EmailAlreadyExistsFailure extends Failure {
  const EmailAlreadyExistsFailure([
    super.message = 'البريد الإلكتروني مستخدم بالفعل',
    super.code,
  ]);
}

class WeakPasswordFailure extends Failure {
  const WeakPasswordFailure([
    super.message = 'كلمة المرور ضعيفة جداً',
    super.code,
  ]);
}

// Cache Failures
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'فشل في الوصول للبيانات المحلية', super.code]);
}

// Validation Failures
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'البيانات المدخلة غير صحيحة', super.code]);
}

// Permission Failures
class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'لا تملك الصلاحيات المطلوبة', super.code]);
}

// Timeout Failures
class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'انتهت مهلة الاتصال', super.code]);
}

// Unknown Failures
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'حدث خطأ غير متوقع', super.code]);
}
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user.dart';

abstract class AuthRemoteDataSource {
  Future<User> signInWithGoogle();
  Future<User> signInWithApple();
  Future<void> signInWithPhone(String phoneNumber);
  Future<User> verifyOTP(String phone, String otp);
  Future<User> login(String email, String password);
  Future<User> register({required String email, required String password, required String fullName, required String phone, required String role});
  Future<void> logout();
  Future<User?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final supabase.SupabaseClient supabaseClient;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.supabaseClient,
    required this.googleSignIn,
  });

  // ✅ 1. Google Sign-In
  @override
  Future<User> signInWithGoogle() async {
    try {
      // 1. تسجيل الدخول عبر Google
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('تم إلغاء تسجيل الدخول');
      }

      // 2. الحصول على Authentication tokens
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null || accessToken == null) {
        throw const AuthException('فشل الحصول على بيانات المصادقة');
      }

      // 3. تسجيل الدخول في Supabase
      final response = await supabaseClient.auth.signInWithIdToken(
        provider: supabase.OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) {
        throw const AuthException('فشل تسجيل الدخول');
      }

      // 4. جلب/إنشاء بيانات المستخدم
      return await _getUserProfile(response.user!.id);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(e.toString());
    }
  }

  // ✅ 2. Apple Sign-In
  @override
  Future<User> signInWithApple() async {
    try {
      // 1. تسجيل الدخول عبر Apple
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // 2. تسجيل الدخول في Supabase
      final response = await supabaseClient.auth.signInWithIdToken(
        provider: supabase.OAuthProvider.apple,
        idToken: credential.identityToken!,
      );

      if (response.user == null) {
        throw const AuthException('فشل تسجيل الدخول');
      }

      // 3. جلب/إنشاء بيانات المستخدم
      return await _getUserProfile(response.user!.id);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(e.toString());
    }
  }

  // ✅ 3. Phone Sign-In - إرسال OTP
  @override
  Future<void> signInWithPhone(String phoneNumber) async {
    try {
      // تنسيق رقم الهاتف (يجب أن يكون بصيغة +972...)
      final formattedPhone = _formatPhoneNumber(phoneNumber);
      
      await supabaseClient.auth.signInWithOtp(
        phone: formattedPhone,
      );
    } catch (e) {
      throw ServerException('فشل إرسال رمز التحقق: ${e.toString()}');
    }
  }

  // ✅ 4. التحقق من OTP
  @override
  Future<User> verifyOTP(String phone, String otp) async {
    try {
      final formattedPhone = _formatPhoneNumber(phone);
      
      final response = await supabaseClient.auth.verifyOTP(
        phone: formattedPhone,
        token: otp,
        type: supabase.OtpType.sms,
      );

      if (response.user == null) {
        throw const AuthException('رمز التحقق غير صحيح');
      }

      return await _getUserProfile(response.user!.id);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(e.toString());
    }
  }

  // ✅ 5. تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
  @override
  Future<User> login(String email, String password) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthException('فشل تسجيل الدخول');
      }

      return await _getUserProfile(response.user!.id);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(e.toString());
    }
  }

  // ✅ 6. التسجيل بالبريد الإلكتروني وكلمة المرور
  @override
  Future<User> register({required String email, required String password, required String fullName, required String phone, required String role}) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
          'role': role,
        },
      );

      if (response.user == null) {
        throw const AuthException('فشل التسجيل');
      }

      return await _getUserProfile(response.user!.id);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(e.toString());
    }
  }

  // ✅ 7. تسجيل الخروج
  @override
  Future<void> logout() async {
    try {
      await googleSignIn.signOut();
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ✅ 6. الحصول على المستخدم الحالي
  @override
  Future<User?> getCurrentUser() async {
    try {
      final session = supabaseClient.auth.currentSession;
      if (session == null) return null;
      return await _getUserProfile(session.user.id);
    } catch (e) {
      return null;
    }
  }

  // ========== Helper Methods ==========

  Future<User> _getUserProfile(String userId) async {
    try {
      final data = await supabaseClient
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      return User.fromJson(data);
    } catch (e) {
      throw const AuthException(
        'لم يتم العثور على بيانات المستخدم. يرجى المحاولة مرة أخرى.'
      );
    }
  }

  String _formatPhoneNumber(String phone) {
    // إزالة المسافات والأحرف الخاصة
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // إضافة كود الدولة إذا لم يكن موجوداً
    if (!cleaned.startsWith('+')) {
      // افترض فلسطين (+970) أو اضبط حسب بلدك
      if (cleaned.startsWith('0')) {
        cleaned = '+970${cleaned.substring(1)}';
      } else {
        cleaned = '+970$cleaned';
      }
    }
    
    return cleaned;
  }
}
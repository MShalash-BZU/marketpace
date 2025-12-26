import '../../domain/entities/user.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(User user);
  Future<User?> getCachedUser();
  Future<void> clearCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  User? _cached;

  @override
  Future<void> cacheUser(User user) async {
    _cached = user;
  }

  @override
  Future<User?> getCachedUser() async => _cached;

  @override
  Future<void> clearCache() async {
    _cached = null;
  }
}

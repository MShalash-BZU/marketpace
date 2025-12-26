class ServerException implements Exception {
	final String message;
	ServerException([this.message = 'Server error']);
	@override
	String toString() => 'ServerException: $message';
}

class AuthException implements Exception {
	final String message;
	const AuthException([this.message = 'Authentication error']);
	@override
	String toString() => 'AuthException: $message';
}


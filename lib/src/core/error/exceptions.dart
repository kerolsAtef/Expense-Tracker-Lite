class ServerException implements Exception {
  final String? message;
  const ServerException([this.message]);
}

class CacheException implements Exception {
  final String? message;
  const CacheException([this.message]);
}

class NetworkException implements Exception {
  final String? message;
  const NetworkException([this.message]);
}

// Authentication exceptions
class AuthException implements Exception {
  final String? message;
  const AuthException([this.message]);
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException([String? message]) : super(message);
}

class UserNotFoundException extends AuthException {
  const UserNotFoundException([String? message]) : super(message);
}

class UserAlreadyExistsException extends AuthException {
  const UserAlreadyExistsException([String? message]) : super(message);
}

class ValidationException implements Exception {
  final String? message;
  const ValidationException([this.message]);
}
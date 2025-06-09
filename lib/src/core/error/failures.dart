import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String? message;
  
  const Failure([this.message]);

  @override
  List<Object?> get props => [message];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure([super.message]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message]);
}

// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure([super.message]);
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure([String? message]) : super(message);
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure([String? message]) : super(message);
}

class UserAlreadyExistsFailure extends AuthFailure {
  const UserAlreadyExistsFailure([String? message]) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure([String? message]) : super(message);
}
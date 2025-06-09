// lib/domain/usecases/auth/auth_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/src/core/error/failures.dart';
import 'package:expense_tracker/src/domain/entities/user.dart';
import 'package:expense_tracker/src/domain/repositories/auth_repository.dart';
import 'package:expense_tracker/src/domain/usecases/usecase.dart';

// Login Use Case
class LoginUseCase implements UseCase<User, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    return await repository.login(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

// Signup Use Case
class SignupUseCase implements UseCase<User, SignupParams> {
  final AuthRepository repository;

  SignupUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(SignupParams params) async {
    return await repository.signup(
      email: params.email,
      password: params.password,
      name: params.name,
    );
  }
}

class SignupParams extends Equatable {
  final String email;
  final String password;
  final String name;

  const SignupParams({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object> get props => [email, password, name];
}

// Logout Use Case
class LogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.logout();
  }
}

// Get Current User Use Case
class GetCurrentUserUseCase implements UseCase<User?, NoParams> {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  @override
  Future<Either<Failure, User?>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}

// Check Login Status Use Case
class CheckLoginStatusUseCase implements UseCase<bool, NoParams> {
  final AuthRepository repository;

  CheckLoginStatusUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.isUserLoggedIn();
  }
}

// Check Email Exists Use Case
class CheckEmailExistsUseCase implements UseCase<bool, CheckEmailParams> {
  final AuthRepository repository;

  CheckEmailExistsUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(CheckEmailParams params) async {
    return await repository.doesEmailExist(params.email);
  }
}

class CheckEmailParams extends Equatable {
  final String email;

  const CheckEmailParams({required this.email});

  @override
  List<Object> get props => [email];
}
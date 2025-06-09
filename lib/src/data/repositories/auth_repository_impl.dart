import 'package:dartz/dartz.dart';
import 'package:expense_tracker/src/data/data_sources/local/auth_local_datasource.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Validate inputs
      final validationResult = _validateLoginInputs(email, password);
      if (validationResult != null) {
        return Left(validationResult);
      }

      final userModel = await localDataSource.login(
        email: email,
        password: password,
      );
      return Right(userModel.toEntity());
    } on InvalidCredentialsException {
      return const Left(InvalidCredentialsFailure('Invalid email or password'));
    } on UserNotFoundException {
      return const Left(UserNotFoundFailure('User not found'));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Validate inputs
      final validationResult = _validateSignupInputs(email, password, name);
      if (validationResult != null) {
        return Left(validationResult);
      }

      final userModel = await localDataSource.signup(
        email: email,
        password: password,
        name: name,
      );
      return Right(userModel.toEntity());
    } on UserAlreadyExistsException {
      return const Left(UserAlreadyExistsFailure('User already exists with this email'));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.logout();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Failed to logout: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final userModel = await localDataSource.getCurrentUser();
      if (userModel == null) {
        return const Right(null);
      }
      return Right(userModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Failed to get current user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> isUserLoggedIn() async {
    try {
      final isLoggedIn = await localDataSource.isUserLoggedIn();
      return Right(isLoggedIn);
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, bool>> doesEmailExist(String email) async {
    try {
      if (!_isValidEmail(email)) {
        return const Left(ValidationFailure('Invalid email format'));
      }
      
      final exists = await localDataSource.doesEmailExist(email);
      return Right(exists);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(AuthFailure('Failed to check email existence: ${e.toString()}'));
    }
  }

  // Helper methods for validation
  ValidationFailure? _validateLoginInputs(String email, String password) {
    if (email.trim().isEmpty) {
      return const ValidationFailure('Email is required');
    }
    if (!_isValidEmail(email)) {
      return const ValidationFailure('Please enter a valid email address');
    }
    if (password.isEmpty) {
      return const ValidationFailure('Password is required');
    }
    return null;
  }

  ValidationFailure? _validateSignupInputs(String email, String password, String name) {
    if (name.trim().isEmpty) {
      return const ValidationFailure('Name is required');
    }
    if (name.trim().length < 2) {
      return const ValidationFailure('Name must be at least 2 characters long');
    }
    if (email.trim().isEmpty) {
      return const ValidationFailure('Email is required');
    }
    if (!_isValidEmail(email)) {
      return const ValidationFailure('Please enter a valid email address');
    }
    if (password.isEmpty) {
      return const ValidationFailure('Password is required');
    }
    if (password.length < 6) {
      return const ValidationFailure('Password must be at least 6 characters long');
    }
    return null;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
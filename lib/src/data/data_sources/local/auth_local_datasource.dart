// lib/data/datasources/auth_local_datasource.dart
import 'package:expense_tracker/src/core/error/exceptions.dart';
import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> signup({
    required String email,
    required String password,
    required String name,
  });
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<bool> isUserLoggedIn();
  Future<bool> doesEmailExist(String email);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String USERS_BOX = 'users';
  static const String AUTH_BOX = 'auth';
  static const String CURRENT_USER_KEY = 'current_user';

  Box<UserModel>? _usersBox;
  Box? _authBox;

  Future<Box<UserModel>> get usersBox async {
    if (_usersBox != null && _usersBox!.isOpen) {
      return _usersBox!;
    }
    _usersBox = await Hive.openBox<UserModel>(USERS_BOX);
    return _usersBox!;
  }

  Future<Box> get authBox async {
    if (_authBox != null && _authBox!.isOpen) {
      return _authBox!;
    }
    _authBox = await Hive.openBox(AUTH_BOX);
    return _authBox!;
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final box = await usersBox;
      final hashedPassword = _hashPassword(password);

      // Find user by email
      final user = box.values.firstWhere(
        (user) => user.email == email.toLowerCase(),
        orElse: () => throw UserNotFoundException(),
      );

      // Verify password
      if (user.password != hashedPassword) {
        throw InvalidCredentialsException();
      }

      // Save current user session
      final authBoxInstance = await authBox;
      await authBoxInstance.put(CURRENT_USER_KEY, user.id);

      return user;
    } catch (e) {
      if (e is UserNotFoundException || e is InvalidCredentialsException) {
        rethrow;
      }
      throw CacheException('Failed to login: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final box = await usersBox;
      final normalizedEmail = email.toLowerCase();

      // Check if user already exists
      final existingUser = box.values
          .where((user) => user.email == normalizedEmail)
          .isNotEmpty;

      if (existingUser) {
        throw UserAlreadyExistsException();
      }

      // Create new user
      final hashedPassword = _hashPassword(password);
      final now = DateTime.now();
      final userId = _generateUserId();

      final newUser = UserModel(
        id: userId,
        email: normalizedEmail,
        password: hashedPassword,
        name: name.trim(),
        createdAt: now,
        updatedAt: now,
      );

      // Save user
      await box.put(userId, newUser);

      // Save current user session
      final authBoxInstance = await authBox;
      await authBoxInstance.put(CURRENT_USER_KEY, userId);

      return newUser;
    } catch (e) {
      if (e is UserAlreadyExistsException) {
        rethrow;
      }
      throw CacheException('Failed to signup: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final authBoxInstance = await authBox;
      await authBoxInstance.delete(CURRENT_USER_KEY);
    } catch (e) {
      throw CacheException('Failed to logout: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final authBoxInstance = await authBox;
      final userId = authBoxInstance.get(CURRENT_USER_KEY);

      if (userId == null) return null;

      final box = await usersBox;
      return box.get(userId);
    } catch (e) {
      throw CacheException('Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<bool> isUserLoggedIn() async {
    try {
      final authBoxInstance = await authBox;
      final userId = authBoxInstance.get(CURRENT_USER_KEY);
      return userId != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> doesEmailExist(String email) async {
    try {
      final box = await usersBox;
      final normalizedEmail = email.toLowerCase();
      
      return box.values
          .any((user) => user.email == normalizedEmail);
    } catch (e) {
      throw CacheException('Failed to check email existence: ${e.toString()}');
    }
  }

  String _generateUserId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        (1000 + (DateTime.now().microsecond % 9000)).toString();
  }
}
import 'package:expense_tracker/src/core/error/failures.dart';
import 'package:expense_tracker/src/domain/usecases/login_usecase.dart';
import 'package:expense_tracker/src/domain/usecases/usecase.dart';
import 'package:expense_tracker/src/presentation/screens/login/controller/state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final SignupUseCase signupUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final CheckLoginStatusUseCase checkLoginStatusUseCase;
  final CheckEmailExistsUseCase checkEmailExistsUseCase;

  AuthCubit({
    required this.loginUseCase,
    required this.signupUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.checkLoginStatusUseCase,
    required this.checkEmailExistsUseCase,
  }) : super(AuthInitial());

  // Check if user is already logged in on app start
  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    
    final result = await checkLoginStatusUseCase(NoParams());
    await result.fold(
      (failure) async {
        emit(AuthUnauthenticated());
      },
      (isLoggedIn) async {
        if (isLoggedIn) {
          final userResult = await getCurrentUserUseCase(NoParams());
          userResult.fold(
            (failure) => emit(AuthUnauthenticated()),
            (user) {
              if (user != null) {
                emit(AuthAuthenticated(user: user));
              } else {
                emit(AuthUnauthenticated());
              }
            },
          );
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  // Login with email and password
  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());

    final result = await loginUseCase(LoginParams(
      email: email,
      password: password,
    ));

    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  // Check if email exists and decide between login or signup
  Future<void> authenticateWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    emit(AuthLoading());

    // First check if email exists
    final emailCheckResult = await checkEmailExistsUseCase(
      CheckEmailParams(email: email),
    );

    await emailCheckResult.fold(
      (failure) async {
        emit(AuthError(message: _mapFailureToMessage(failure)));
      },
      (emailExists) async {
        if (emailExists) {
          // Email exists, try to login
          await login(email: email, password: password);
        } else {
          // Email doesn't exist, try to signup
          if (name == null || name.trim().isEmpty) {
            emit(const AuthError(message: 'Name is required for new account'));
            return;
          }
          await signup(email: email, password: password, name: name);
        }
      },
    );
  }

  // Signup with email, password, and name
  Future<void> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    emit(AuthLoading());

    final result = await signupUseCase(SignupParams(
      email: email,
      password: password,
      name: name,
    ));

    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  // Check if email exists (for UI feedback)
  Future<bool> doesEmailExist(String email) async {
    final result = await checkEmailExistsUseCase(CheckEmailParams(email: email));
    return result.fold(
      (failure) => false,
      (exists) => exists,
    );
  }

  // Logout
  Future<void> logout() async {
    emit(AuthLoading());

    final result = await logoutUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  // Get current user
  Future<void> getCurrentUser() async {
    final result = await getCurrentUserUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthError(message: _mapFailureToMessage(failure))),
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ValidationFailure:
        return failure.message ?? 'Validation error occurred';
      case InvalidCredentialsFailure:
        return failure.message ?? 'Invalid email or password';
      case UserNotFoundFailure:
        return failure.message ?? 'User not found';
      case UserAlreadyExistsFailure:
        return failure.message ?? 'User already exists with this email';
      case CacheFailure:
        return failure.message ?? 'Storage error occurred';
      case NetworkFailure:
        return failure.message ?? 'Network error occurred';
      default:
        return failure.message ?? 'An unexpected error occurred';
    }
  }
}
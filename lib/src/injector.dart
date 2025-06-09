// lib/src/injector.dart
import 'package:expense_tracker/src/data/data_sources/local/auth_local_datasource.dart';
import 'package:expense_tracker/src/data/data_sources/local/currency_local_datasource.dart';
import 'package:expense_tracker/src/data/data_sources/local/expense_local_datasource.dart';
import 'package:expense_tracker/src/data/data_sources/remote/currency_remote_datasource.dart';
import 'package:expense_tracker/src/data/repositories/auth_repository_impl.dart';
import 'package:expense_tracker/src/data/repositories/currency_repository_impl.dart';
import 'package:expense_tracker/src/data/repositories/expense_repository_impl.dart';
import 'package:expense_tracker/src/domain/repositories/auth_repository.dart';
import 'package:expense_tracker/src/domain/repositories/currency_repository.dart' show CurrencyRepository;
import 'package:expense_tracker/src/domain/repositories/expense_repository.dart';
import 'package:expense_tracker/src/domain/usecases/expense/add_expense_usecase.dart';
import 'package:expense_tracker/src/domain/usecases/expense/convert_currency_usecase.dart';
import 'package:expense_tracker/src/domain/usecases/expense/delete_expense_usecase.dart';
import 'package:expense_tracker/src/domain/usecases/expense/get_exchange_rates_usecase.dart';
import 'package:expense_tracker/src/domain/usecases/expense/get_expense_summary_usecase.dart';
import 'package:expense_tracker/src/domain/usecases/expense/get_expenses_usecase.dart';
import 'package:expense_tracker/src/domain/usecases/expense/get_supported_currencies_usecase.dart';
import 'package:expense_tracker/src/domain/usecases/expense/get_total_expense_count_usecase.dart';
import 'package:expense_tracker/src/domain/usecases/expense/update_expense_usecase.dart';
import 'package:expense_tracker/src/domain/usecases/login_usecase.dart';
import 'package:expense_tracker/src/presentation/screens/add_expense/controller/cubit.dart';
import 'package:expense_tracker/src/presentation/screens/dashboard/controller/cubit.dart';
import 'package:expense_tracker/src/presentation/screens/login/controller/cubit.dart';
import 'package:expense_tracker/src/data/models/user_model.dart';
import 'package:expense_tracker/src/data/models/expense_model.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

final sl = GetIt.instance;

bool _isInitialized = false;

Future<void> init() async {
  // Prevent double initialization
  if (_isInitialized) {
    print('Dependency injection already initialized');
    return;
  }

  try {
    // Initialize Hive first
    await Hive.initFlutter();
    print('✅ Hive initialized');

    // Register Hive adapters
    await _registerHiveAdapters();
    print('✅ Hive adapters registered');

    // Register dependencies
    await _registerDependencies();
    print('✅ Dependencies registered');

    _isInitialized = true;
    print('✅ Dependency injection initialized successfully');

  } catch (e) {
    print('❌ Error initializing dependencies: $e');
    rethrow;
  }
}

Future<void> _registerHiveAdapters() async {
  try {
    // Register UserModel adapter
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
      print('✅ UserModelAdapter registered with typeId: 0');
    }

    // Register ExpenseModel adapter
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ExpenseModelAdapter());
      print('✅ ExpenseModelAdapter registered with typeId: 1');
    }
  } catch (e) {
    print('❌ Error registering Hive adapters: $e');
    rethrow;
  }
}

Future<void> _registerDependencies() async {
  //! Features - Dashboard
  // Cubit
  sl.registerFactory(
        () => DashboardCubit(
      getExpensesUseCase: sl(),
      getExpenseSummaryUseCase: sl(),
      getTotalExpenseCountUseCase: sl(),
    ),
  );

  // Add Expense Cubit
  sl.registerFactory(
        () => AddExpenseCubit(
      addExpenseUseCase: sl(),
      getSupportedCurrenciesUseCase: sl(),
      convertCurrencyUseCase: sl(),
    ),
  );

  //! Features - Authentication
  // Cubit
  sl.registerFactory(
        () => AuthCubit(
      loginUseCase: sl(),
      signupUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      checkLoginStatusUseCase: sl(),
      checkEmailExistsUseCase: sl(),
    ),
  );

  //! Use cases - Expense
  sl.registerLazySingleton(() => AddExpenseUseCase(sl()));
  sl.registerLazySingleton(() => GetExpensesUseCase(sl()));
  sl.registerLazySingleton(() => UpdateExpenseUseCase(sl()));
  sl.registerLazySingleton(() => DeleteExpenseUseCase(sl()));
  sl.registerLazySingleton(() => GetExpenseSummaryUseCase(sl()));
  sl.registerLazySingleton(() => GetTotalExpenseCountUseCase(sl()));

  //! Use cases - Currency
  sl.registerLazySingleton(() => GetExchangeRatesUseCase(sl()));
  sl.registerLazySingleton(() => ConvertCurrencyUseCase(sl()));
  sl.registerLazySingleton(() => GetSupportedCurrenciesUseCase(sl()));

  //! Use cases - Authentication
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SignupUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => CheckLoginStatusUseCase(sl()));
  sl.registerLazySingleton(() => CheckEmailExistsUseCase(sl()));

  //! Repository
  sl.registerLazySingleton<ExpenseRepository>(
        () => ExpenseRepositoryImpl(
      localDataSource: sl(),
      currencyRepository: sl(),
    ),
  );

  sl.registerLazySingleton<CurrencyRepository>(
        () => CurrencyRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(localDataSource: sl()),
  );

  //! Data sources
  sl.registerLazySingleton<ExpenseLocalDataSource>(
        () => ExpenseLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<CurrencyRemoteDataSource>(
        () => CurrencyRemoteDataSourceFreeImpl(client: sl()),
  );

  sl.registerLazySingleton<CurrencyLocalDataSource>(
        () => CurrencyLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
        () => AuthLocalDataSourceImpl(),
  );

  //! External
  sl.registerLazySingleton(() => http.Client());
}

// Reset method for testing or hot reload
Future<void> reset() async {
  await sl.reset();
  _isInitialized = false;
}

// Extension to set current user in expense repository
extension DependencyInjectionExtension on GetIt {
  void setCurrentUser(String userId) {
    try {
      final expenseRepo = sl<ExpenseRepository>();
      if (expenseRepo is ExpenseRepositoryImpl) {
        expenseRepo.setCurrentUserId(userId);
      }
    } catch (e) {
      print('Warning: Could not set current user: $e');
    }
  }
}
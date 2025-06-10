import 'package:expense_tracker/src/domain/usecases/expense/add_expense_usecase.dart';
import 'package:expense_tracker/src/domain/usecases/expense/get_supported_currencies_usecase.dart';
import 'package:expense_tracker/src/domain/usecases/expense/convert_currency_usecase.dart';
import 'package:expense_tracker/src/domain/usecases/usecase.dart';
import 'package:expense_tracker/src/presentation/screens/add_expense/controller/state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddExpenseCubit extends Cubit<AddExpenseState> {
  final AddExpenseUseCase addExpenseUseCase;
  final GetSupportedCurrenciesUseCase getSupportedCurrenciesUseCase;
  final ConvertCurrencyUseCase _convertCurrencyUseCase;

  AddExpenseCubit({
    required this.addExpenseUseCase,
    required this.getSupportedCurrenciesUseCase,
    required ConvertCurrencyUseCase convertCurrencyUseCase,
  }) : _convertCurrencyUseCase = convertCurrencyUseCase,
        super(AddExpenseInitial());

  // Load supported currencies
  Future<void> loadSupportedCurrencies() async {
    emit(CurrencyLoading());

    final result = await getSupportedCurrenciesUseCase(NoParams());
    result.fold(
          (failure) {
        print('❌ Error loading currencies: $failure');
        // Fallback to common currencies if API fails
        final fallbackCurrencies = [
          'USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 'CHF', 'CNY', 'SEK', 'NZD',
          'MXN', 'SGD', 'HKD', 'NOK', 'TRY', 'RUB', 'INR', 'BRL', 'ZAR', 'KRW',
          'EGP', 'AED', 'SAR', 'QAR', 'KWD', 'BHD', 'OMR', 'JOD', 'LBP', 'ILS',
        ];
        emit(CurrencyLoaded(currencies: fallbackCurrencies));
      },
          (currencies) {
        print('✅ Loaded currencies: ${currencies.length} currencies');
        emit(CurrencyLoaded(currencies: currencies));
      },
    );
  }

  // Convert currency using the use case - FIXED: No more recursion!
  Future<double> convertCurrency({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    try {
      print('🔄 Converting $amount $fromCurrency to $toCurrency');

      // ✅ FIXED: Call the use case, not the method itself!
      final result = await _convertCurrencyUseCase(ConvertCurrencyParams(
        amount: amount,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
      ));

      return result.fold(
            (failure) {
          print('❌ Currency conversion failed: $failure');
          throw Exception(failure.toString());
        },
            (convertedAmount) {
          print('✅ Conversion result: $amount $fromCurrency = $convertedAmount $toCurrency');
          return convertedAmount;
        },
      );
    } catch (e) {
      print('❌ Currency conversion error: $e');
      rethrow;
    }
  }

  // Add expense
  Future<void> addExpense({
    required String category,
    required double amount,
    required String currency,
    required DateTime date,
    String? description,
    String? receiptPath,
    required String categoryIcon,
  }) async {
    emit(AddExpenseLoading());

    final result = await addExpenseUseCase(AddExpenseParams(
      category: category,
      amount: amount,
      currency: currency,
      date: date,
      description: description,
      receiptPath: receiptPath,
      categoryIcon: categoryIcon,
    ));

    result.fold(
          (failure) => emit(AddExpenseError(message: _mapFailureToMessage(failure.toString()))),
          (expense) => emit(AddExpenseSuccess(expense: expense)),
    );
  }

  // Reset state
  void resetState() {
    emit(AddExpenseInitial());
  }

  String _mapFailureToMessage(String failure) {
    if (failure.contains('Validation')) {
      return failure.replaceAll('ValidationFailure: ', '');
    } else if (failure.contains('Network')) {
      return 'Network error. Please check your connection';
    } else if (failure.contains('Cache')) {
      return 'Storage error occurred';
    } else if (failure.contains('User not authenticated')) {
      return 'Please login to add expenses';
    } else {
      return 'Failed to add expense. Please try again';
    }
  }
}
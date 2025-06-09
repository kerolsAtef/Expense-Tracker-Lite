import 'package:dartz/dartz.dart';
import 'package:expense_tracker/src/data/data_sources/local/expense_local_datasource.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_summary.dart';
import '../../domain/entities/expense_filter.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/repositories/currency_repository.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;
  final CurrencyRepository currencyRepository;

  ExpenseRepositoryImpl({
    required this.localDataSource,
    required this.currencyRepository,
  });

  String? _currentUserId;

  void setCurrentUserId(String userId) {
    _currentUserId = userId;
  }

  @override
  Future<Either<Failure, Expense>> addExpense({
    required String category,
    required double amount,
    required String currency,
    required DateTime date,
    String? description,
    String? receiptPath,
    required String categoryIcon,
  }) async {
    try {
      if (_currentUserId == null) {
        return const Left(AuthFailure('User not authenticated'));
      }

      // Validate inputs
      final validationResult = _validateExpenseInputs(
        category: category,
        amount: amount,
        currency: currency,
        date: date,
        categoryIcon: categoryIcon,
      );
      if (validationResult != null) {
        return Left(validationResult);
      }

      // Convert to USD
      double convertedAmount = amount;
      if (currency != 'USD') {
        final conversionResult = await currencyRepository.convertCurrency(
          amount: amount,
          fromCurrency: currency,
          toCurrency: 'USD',
        );
        
        await conversionResult.fold(
          (failure) => convertedAmount = amount, // Fallback to original amount
          (converted) => convertedAmount = converted,
        );
      }

      final expenseModel = ExpenseModel(
        id: '', // Will be generated in datasource
        userId: _currentUserId!,
        category: category.trim(),
        amount: amount,
        currency: currency,
        convertedAmount: convertedAmount,
        date: date,
        description: description?.trim(),
        receiptPath: receiptPath,
        categoryIcon: categoryIcon,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final savedExpense = await localDataSource.addExpense(expenseModel);
      return Right(savedExpense.toEntity());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to add expense: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getExpenses({
    ExpenseFilter? filter,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      if (_currentUserId == null) {
        return const Left(AuthFailure('User not authenticated'));
      }

      final expenseModels = await localDataSource.getExpenses(
        filter: filter,
        page: page,
        limit: limit,
        userId: _currentUserId,
      );

      final expenses = expenseModels.map((model) => model.toEntity()).toList();
      return Right(expenses);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get expenses: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Expense>> updateExpense(Expense expense) async {
    try {
      if (_currentUserId == null) {
        return const Left(AuthFailure('User not authenticated'));
      }

      // Validate inputs
      final validationResult = _validateExpenseInputs(
        category: expense.category,
        amount: expense.amount,
        currency: expense.currency,
        date: expense.date,
        categoryIcon: expense.categoryIcon,
      );
      if (validationResult != null) {
        return Left(validationResult);
      }

      final expenseModel = ExpenseModel.fromEntity(expense);
      final updatedExpense = await localDataSource.updateExpense(expenseModel);
      return Right(updatedExpense.toEntity());
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to update expense: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String expenseId) async {
    try {
      if (_currentUserId == null) {
        return const Left(AuthFailure('User not authenticated'));
      }

      if (expenseId.trim().isEmpty) {
        return const Left(ValidationFailure('Expense ID is required'));
      }

      await localDataSource.deleteExpense(expenseId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to delete expense: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ExpenseSummary>> getExpenseSummary({
    ExpenseFilter? filter,
  }) async {
    try {
      if (_currentUserId == null) {
        return const Left(AuthFailure('User not authenticated'));
      }

      final allExpenses = await localDataSource.getAllExpensesForUser(_currentUserId!);
      
      // Apply filter if provided
      List<ExpenseModel> filteredExpenses = allExpenses;
      if (filter != null) {
        // Apply same filtering logic as in datasource
        filteredExpenses = _applyFilterLogic(allExpenses, filter);
      }

      // Calculate totals
      double totalExpenses = 0;
      final Map<String, CategorySummaryData> categoryData = {};

      for (final expense in filteredExpenses) {
        totalExpenses += expense.convertedAmount;
        
        if (categoryData.containsKey(expense.category)) {
          categoryData[expense.category]!.amount += expense.convertedAmount;
          categoryData[expense.category]!.count += 1;
        } else {
          categoryData[expense.category] = CategorySummaryData(
            amount: expense.convertedAmount,
            count: 1,
            icon: expense.categoryIcon,
          );
        }
      }

      // Create category breakdown
      final categoryBreakdown = categoryData.entries
          .map((entry) => CategorySummary(
                category: entry.key,
                amount: entry.value.amount,
                categoryIcon: entry.value.icon,
                count: entry.value.count,
              ))
          .toList();

      // Sort by amount (highest first)
      categoryBreakdown.sort((a, b) => b.amount.compareTo(a.amount));

      // For now, we don't track income separately, so balance = -expenses
      const double totalIncome = 0; // Can be implemented later
      final double totalBalance = totalIncome - totalExpenses;

      final summary = ExpenseSummary(
        totalBalance: totalBalance,
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        categoryBreakdown: categoryBreakdown,
        currency: 'USD',
      );

      return Right(summary);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get expense summary: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getTotalExpenseCount({
    ExpenseFilter? filter,
  }) async {
    try {
      if (_currentUserId == null) {
        return const Left(AuthFailure('User not authenticated'));
      }

      final count = await localDataSource.getTotalExpenseCount(
        filter: filter,
        userId: _currentUserId,
      );
      return Right(count);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get expense count: ${e.toString()}'));
    }
  }

  ValidationFailure? _validateExpenseInputs({
    required String category,
    required double amount,
    required String currency,
    required DateTime date,
    required String categoryIcon,
  }) {
    if (category.trim().isEmpty) {
      return const ValidationFailure('Category is required');
    }
    if (amount <= 0) {
      return const ValidationFailure('Amount must be greater than zero');
    }
    if (currency.trim().isEmpty) {
      return const ValidationFailure('Currency is required');
    }
    if (categoryIcon.trim().isEmpty) {
      return const ValidationFailure('Category icon is required');
    }
    if (date.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      return const ValidationFailure('Date cannot be in the future');
    }
    return null;
  }

  List<ExpenseModel> _applyFilterLogic(List<ExpenseModel> expenses, ExpenseFilter filter) {
    // Same filtering logic as in datasource
    List<ExpenseModel> filteredExpenses = List.from(expenses);

    DateTime? startDate;
    DateTime? endDate;
    final now = DateTime.now();

    switch (filter.type) {
      case FilterType.thisMonth:
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case FilterType.lastWeek:
        final lastWeek = now.subtract(const Duration(days: 7));
        startDate = DateTime(lastWeek.year, lastWeek.month, lastWeek.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case FilterType.last30Days:
        startDate = now.subtract(const Duration(days: 30));
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case FilterType.last90Days:
        startDate = now.subtract(const Duration(days: 90));
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case FilterType.thisYear:
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year, 12, 31, 23, 59, 59);
        break;
      case FilterType.custom:
        startDate = filter.startDate;
        endDate = filter.endDate;
        break;
      case FilterType.all:
        break;
    }

    if (startDate != null && endDate != null) {
      filteredExpenses = filteredExpenses.where((expense) =>
          expense.date.isAfter(startDate!) && expense.date.isBefore(endDate!)).toList();
    }

    if (filter.categories != null && filter.categories!.isNotEmpty) {
      filteredExpenses = filteredExpenses.where((expense) =>
          filter.categories!.contains(expense.category)).toList();
    }

    if (filter.minAmount != null) {
      filteredExpenses = filteredExpenses.where((expense) =>
          expense.convertedAmount >= filter.minAmount!).toList();
    }

    if (filter.maxAmount != null) {
      filteredExpenses = filteredExpenses.where((expense) =>
          expense.convertedAmount <= filter.maxAmount!).toList();
    }

    return filteredExpenses;
  }
}

class CategorySummaryData {
  double amount;
  int count;
  final String icon;

  CategorySummaryData({
    required this.amount,
    required this.count,
    required this.icon,
  });
}

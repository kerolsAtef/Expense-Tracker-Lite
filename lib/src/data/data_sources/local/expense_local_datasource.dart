import 'package:expense_tracker/src/core/error/exceptions.dart';
import 'package:expense_tracker/src/data/models/expense_model.dart';
import 'package:expense_tracker/src/domain/entities/expense_filter.dart';
import 'package:hive/hive.dart';

abstract class ExpenseLocalDataSource {
  Future<ExpenseModel> addExpense(ExpenseModel expense);
  Future<List<ExpenseModel>> getExpenses({
    ExpenseFilter? filter,
    int page = 1,
    int limit = 10,
    String? userId,
  });
  Future<ExpenseModel> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(String expenseId);
  Future<int> getTotalExpenseCount({
    ExpenseFilter? filter,
    String? userId,
  });
  Future<List<ExpenseModel>> getAllExpensesForUser(String userId);
}

class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  static const String EXPENSES_BOX = 'expenses';
  
  Box<ExpenseModel>? _expensesBox;

  Future<Box<ExpenseModel>> get expensesBox async {
    if (_expensesBox != null && _expensesBox!.isOpen) {
      return _expensesBox!;
    }
    _expensesBox = await Hive.openBox<ExpenseModel>(EXPENSES_BOX);
    return _expensesBox!;
  }

  String _generateExpenseId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        (1000 + (DateTime.now().microsecond % 9000)).toString();
  }

  @override
  Future<ExpenseModel> addExpense(ExpenseModel expense) async {
    try {
      final box = await expensesBox;
      final expenseWithId = expense.copyWith(
        id: _generateExpenseId(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await box.put(expenseWithId.id, expenseWithId);
      return expenseWithId;
    } catch (e) {
      throw CacheException('Failed to add expense: ${e.toString()}');
    }
  }

  @override
  Future<List<ExpenseModel>> getExpenses({
    ExpenseFilter? filter,
    int page = 1,
    int limit = 10,
    String? userId,
  }) async {
    try {
      final box = await expensesBox;
      List<ExpenseModel> allExpenses = box.values.toList();

      // Filter by user
      if (userId != null) {
        allExpenses = allExpenses.where((expense) => expense.userId == userId).toList();
      }

      // Apply filters
      if (filter != null) {
        allExpenses = _applyFilter(allExpenses, filter);
      }

      // Sort by date (newest first)
      allExpenses.sort((a, b) => b.date.compareTo(a.date));

      // Apply pagination
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;

      if (startIndex >= allExpenses.length) {
        return [];
      }

      return allExpenses.sublist(
        startIndex,
        endIndex > allExpenses.length ? allExpenses.length : endIndex,
      );
    } catch (e) {
      throw CacheException('Failed to get expenses: ${e.toString()}');
    }
  }

  @override
  Future<ExpenseModel> updateExpense(ExpenseModel expense) async {
    try {
      final box = await expensesBox;
      final updatedExpense = expense.copyWith(updatedAt: DateTime.now());
      
      await box.put(expense.id, updatedExpense);
      return updatedExpense;
    } catch (e) {
      throw CacheException('Failed to update expense: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    try {
      final box = await expensesBox;
      await box.delete(expenseId);
    } catch (e) {
      throw CacheException('Failed to delete expense: ${e.toString()}');
    }
  }

  @override
  Future<int> getTotalExpenseCount({
    ExpenseFilter? filter,
    String? userId,
  }) async {
    try {
      final box = await expensesBox;
      List<ExpenseModel> allExpenses = box.values.toList();

      // Filter by user
      if (userId != null) {
        allExpenses = allExpenses.where((expense) => expense.userId == userId).toList();
      }

      // Apply filters
      if (filter != null) {
        allExpenses = _applyFilter(allExpenses, filter);
      }

      return allExpenses.length;
    } catch (e) {
      throw CacheException('Failed to get expense count: ${e.toString()}');
    }
  }

  @override
  Future<List<ExpenseModel>> getAllExpensesForUser(String userId) async {
    try {
      final box = await expensesBox;
      return box.values.where((expense) => expense.userId == userId).toList();
    } catch (e) {
      throw CacheException('Failed to get all expenses: ${e.toString()}');
    }
  }

  List<ExpenseModel> _applyFilter(List<ExpenseModel> expenses, ExpenseFilter filter) {
    List<ExpenseModel> filteredExpenses = List.from(expenses);

    // Apply date filter
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
        // No date filtering
        break;
    }

    if (startDate != null && endDate != null) {
      filteredExpenses = filteredExpenses.where((expense) =>
          expense.date.isAfter(startDate!) && expense.date.isBefore(endDate!)).toList();
    }

    // Apply category filter
    if (filter.categories != null && filter.categories!.isNotEmpty) {
      filteredExpenses = filteredExpenses.where((expense) =>
          filter.categories!.contains(expense.category)).toList();
    }

    // Apply amount range filter
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
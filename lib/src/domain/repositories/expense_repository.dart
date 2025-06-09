import 'package:dartz/dartz.dart';
import '../entities/expense.dart';
import '../../core/error/failures.dart';
import '../entities/expense_filter.dart';
import '../entities/expense_summary.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, Expense>> addExpense({
    required String category,
    required double amount,
    required String currency,
    required DateTime date,
    String? description,
    String? receiptPath,
    required String categoryIcon,
  });

  Future<Either<Failure, List<Expense>>> getExpenses({
    ExpenseFilter? filter,
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, Expense>> updateExpense(Expense expense);

  Future<Either<Failure, void>> deleteExpense(String expenseId);

  Future<Either<Failure, ExpenseSummary>> getExpenseSummary({
    ExpenseFilter? filter,
  });

  Future<Either<Failure, int>> getTotalExpenseCount({
    ExpenseFilter? filter,
  });
}




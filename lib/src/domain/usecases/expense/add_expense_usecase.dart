import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/src/domain/usecases/usecase.dart';
import '../../entities/expense.dart';
import '../../repositories/expense_repository.dart';
import '../../../core/error/failures.dart';

class AddExpenseUseCase implements UseCase<Expense, AddExpenseParams> {
  final ExpenseRepository repository;

  AddExpenseUseCase(this.repository);

  @override
  Future<Either<Failure, Expense>> call(AddExpenseParams params) async {
    return await repository.addExpense(
      category: params.category,
      amount: params.amount,
      currency: params.currency,
      date: params.date,
      description: params.description,
      receiptPath: params.receiptPath,
      categoryIcon: params.categoryIcon,
    );
  }
}

class AddExpenseParams extends Equatable {
  final String category;
  final double amount;
  final String currency;
  final DateTime date;
  final String? description;
  final String? receiptPath;
  final String categoryIcon;

  const AddExpenseParams({
    required this.category,
    required this.amount,
    required this.currency,
    required this.date,
    this.description,
    this.receiptPath,
    required this.categoryIcon,
  });

  @override
  List<Object?> get props => [
        category,
        amount,
        currency,
        date,
        description,
        receiptPath,
        categoryIcon,
      ];
}
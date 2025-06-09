import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/src/domain/usecases/usecase.dart';
import '../../entities/expense.dart';
import '../../repositories/expense_repository.dart';
import '../../../core/error/failures.dart';

class UpdateExpenseUseCase implements UseCase<Expense, UpdateExpenseParams> {
  final ExpenseRepository repository;

  UpdateExpenseUseCase(this.repository);

  @override
  Future<Either<Failure, Expense>> call(UpdateExpenseParams params) async {
    return await repository.updateExpense(params.expense);
  }
}

class UpdateExpenseParams extends Equatable {
  final Expense expense;

  const UpdateExpenseParams({required this.expense});

  @override
  List<Object> get props => [expense];
}
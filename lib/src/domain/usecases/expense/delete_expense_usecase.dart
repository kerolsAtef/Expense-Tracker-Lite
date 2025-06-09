import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/src/domain/usecases/usecase.dart';
import '../../repositories/expense_repository.dart';
import '../../../core/error/failures.dart';
class DeleteExpenseUseCase implements UseCase<void, DeleteExpenseParams> {
  final ExpenseRepository repository;

  DeleteExpenseUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteExpenseParams params) async {
    return await repository.deleteExpense(params.expenseId);
  }
}

class DeleteExpenseParams extends Equatable {
  final String expenseId;

  const DeleteExpenseParams({required this.expenseId});

  @override
  List<Object> get props => [expenseId];
}
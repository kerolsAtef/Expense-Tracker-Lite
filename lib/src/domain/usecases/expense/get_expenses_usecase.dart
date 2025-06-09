import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/src/domain/usecases/usecase.dart';
import '../../entities/expense.dart';
import '../../entities/expense_filter.dart';
import '../../repositories/expense_repository.dart';
import '../../../core/error/failures.dart';

class GetExpensesUseCase implements UseCase<List<Expense>, GetExpensesParams> {
  final ExpenseRepository repository;

  GetExpensesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Expense>>> call(GetExpensesParams params) async {
    return await repository.getExpenses(
      filter: params.filter,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetExpensesParams extends Equatable {
  final ExpenseFilter? filter;
  final int page;
  final int limit;

  const GetExpensesParams({
    this.filter,
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [filter, page, limit];
}

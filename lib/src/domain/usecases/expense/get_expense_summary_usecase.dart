import 'package:expense_tracker/src/domain/entities/expense_filter.dart';
import '../../entities/expense_summary.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/src/domain/usecases/usecase.dart';
import '../../repositories/expense_repository.dart';
import '../../../core/error/failures.dart';
class GetExpenseSummaryUseCase implements UseCase<ExpenseSummary, GetExpenseSummaryParams> {
  final ExpenseRepository repository;

  GetExpenseSummaryUseCase(this.repository);

  @override
  Future<Either<Failure, ExpenseSummary>> call(GetExpenseSummaryParams params) async {
    return await repository.getExpenseSummary(filter: params.filter);
  }
}

class GetExpenseSummaryParams extends Equatable {
  final ExpenseFilter? filter;

  const GetExpenseSummaryParams({this.filter});

  @override
  List<Object?> get props => [filter];
}

import 'package:expense_tracker/src/domain/entities/expense_filter.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/src/domain/usecases/usecase.dart';
import '../../repositories/expense_repository.dart';
import '../../../core/error/failures.dart';
class GetTotalExpenseCountUseCase implements UseCase<int, GetTotalExpenseCountParams> {
  final ExpenseRepository repository;

  GetTotalExpenseCountUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(GetTotalExpenseCountParams params) async {
    return await repository.getTotalExpenseCount(filter: params.filter);
  }
}

class GetTotalExpenseCountParams extends Equatable {
  final ExpenseFilter? filter;

  const GetTotalExpenseCountParams({this.filter});

  @override
  List<Object?> get props => [filter];
}
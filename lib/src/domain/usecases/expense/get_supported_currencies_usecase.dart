import 'package:dartz/dartz.dart';
import 'package:expense_tracker/src/domain/usecases/usecase.dart';
import '../../repositories/currency_repository.dart';
import '../../../core/error/failures.dart';
class GetSupportedCurrenciesUseCase implements UseCase<List<String>, NoParams> {
  final CurrencyRepository repository;

  GetSupportedCurrenciesUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) async {
    return await repository.getSupportedCurrencies();
  }
}
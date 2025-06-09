import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/src/domain/usecases/usecase.dart';
import '../../entities/exchange_rate.dart';
import '../../repositories/currency_repository.dart';
import '../../../core/error/failures.dart';

class GetExchangeRatesUseCase implements UseCase<ExchangeRate, GetExchangeRatesParams> {
  final CurrencyRepository repository;

  GetExchangeRatesUseCase(this.repository);

  @override
  Future<Either<Failure, ExchangeRate>> call(GetExchangeRatesParams params) async {
    return await repository.getExchangeRates(baseCurrency: params.baseCurrency);
  }
}

class GetExchangeRatesParams extends Equatable {
  final String baseCurrency;

  const GetExchangeRatesParams({this.baseCurrency = 'USD'});

  @override
  List<Object> get props => [baseCurrency];
}
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/src/domain/usecases/usecase.dart';
import '../../repositories/currency_repository.dart';
import '../../../core/error/failures.dart';

class ConvertCurrencyUseCase implements UseCase<double, ConvertCurrencyParams> {
  final CurrencyRepository repository;

  ConvertCurrencyUseCase(this.repository);

  @override
  Future<Either<Failure, double>> call(ConvertCurrencyParams params) async {
    return await repository.convertCurrency(
      amount: params.amount,
      fromCurrency: params.fromCurrency,
      toCurrency: params.toCurrency,
    );
  }
}

class ConvertCurrencyParams extends Equatable {
  final double amount;
  final String fromCurrency;
  final String toCurrency;

  const ConvertCurrencyParams({
    required this.amount,
    required this.fromCurrency,
    required this.toCurrency,
  });

  @override
  List<Object> get props => [amount, fromCurrency, toCurrency];
}
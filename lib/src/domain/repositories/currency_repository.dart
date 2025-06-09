import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/exchange_rate.dart';

abstract class CurrencyRepository {
  Future<Either<Failure, ExchangeRate>> getExchangeRates({
    String baseCurrency = 'USD',
  });

  Future<Either<Failure, double>> convertCurrency({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  });

  Future<Either<Failure, List<String>>> getSupportedCurrencies();
}
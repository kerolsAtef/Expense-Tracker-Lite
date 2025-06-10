import 'package:dartz/dartz.dart';
import 'package:expense_tracker/src/data/data_sources/local/currency_local_datasource.dart';
import 'package:expense_tracker/src/data/data_sources/remote/currency_remote_datasource.dart';
import '../../domain/entities/exchange_rate.dart';
import '../../domain/repositories/currency_repository.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final CurrencyRemoteDataSource remoteDataSource;
  final CurrencyLocalDataSource localDataSource;

  CurrencyRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, ExchangeRate>> getExchangeRates({
    String baseCurrency = 'USD',
  }) async {
    try {
      print('📈 CurrencyRepository: Getting exchange rates for $baseCurrency');

      // Check if we have valid cached data
      final isCacheValid = await localDataSource.isExchangeRateCacheValid(baseCurrency);

      if (isCacheValid) {
        print('✅ Using cached exchange rates for $baseCurrency');
        final cachedRates = await localDataSource.getCachedExchangeRates(baseCurrency);
        if (cachedRates != null) {
          return Right(cachedRates.toEntity());
        }
      }

      print('🌐 Fetching fresh exchange rates for $baseCurrency from API');
      // Fetch from remote API
      final remoteRates = await remoteDataSource.getExchangeRates(
        baseCurrency: baseCurrency,
      );

      // Cache the new data
      await localDataSource.cacheExchangeRates(remoteRates);
      print('💾 Cached fresh exchange rates for $baseCurrency');

      return Right(remoteRates.toEntity());
    } on ServerException catch (e) {
      print('❌ ServerException: ${e.message}');
      // Try to return cached data as fallback
      try {
        final cachedRates = await localDataSource.getCachedExchangeRates(baseCurrency);
        if (cachedRates != null) {
          print('🔄 Using stale cached data as fallback for $baseCurrency');
          return Right(cachedRates.toEntity());
        }
      } catch (_) {
        print('❌ No cached data available as fallback');
      }

      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      print('❌ NetworkException: ${e.message}');
      // Try to return cached data as fallback
      try {
        final cachedRates = await localDataSource.getCachedExchangeRates(baseCurrency);
        if (cachedRates != null) {
          print('🔄 Using cached data due to network error for $baseCurrency');
          return Right(cachedRates.toEntity());
        }
      } catch (_) {
        print('❌ No cached data available during network error');
      }

      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      print('❌ CacheException: ${e.message}');
      return Left(CacheFailure(e.message));
    } catch (e) {
      print('❌ Unexpected error in getExchangeRates: $e');
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, double>> convertCurrency({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    try {
      print('💱 CurrencyRepository: Converting $amount $fromCurrency to $toCurrency');

      // Validation
      if (amount <= 0) {
        print('❌ Invalid amount: $amount');
        return const Left(ValidationFailure('Amount must be greater than zero'));
      }

      if (fromCurrency == toCurrency) {
        print('✅ Same currency conversion: $amount');
        return Right(amount);
      }

      // Get exchange rates with the from currency as base
      final exchangeRateResult = await getExchangeRates(baseCurrency: fromCurrency);

      return exchangeRateResult.fold(
            (failure) {
          print('❌ Failed to get exchange rates: $failure');
          return Left(failure);
        },
            (exchangeRate) {
          final rate = exchangeRate.getRate(toCurrency);
          if (rate == null) {
            print('❌ Exchange rate not available for $toCurrency');
            return Left(ServerFailure('Exchange rate not available for $toCurrency'));
          }

          final convertedAmount = amount * rate;
          print('✅ Conversion successful: $amount $fromCurrency = $convertedAmount $toCurrency (rate: $rate)');
          return Right(convertedAmount);
        },
      );
    } catch (e) {
      print('❌ Error in convertCurrency: $e');
      return Left(ServerFailure('Failed to convert currency: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getSupportedCurrencies() async {
    try {
      print('🌍 CurrencyRepository: Getting supported currencies');

      final currencies = await remoteDataSource.getSupportedCurrencies();
      print('✅ Loaded ${currencies.length} supported currencies');
      return Right(currencies);
    } on ServerException catch (e) {
      print('❌ ServerException in getSupportedCurrencies: ${e.message}');
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      print('❌ NetworkException in getSupportedCurrencies: ${e.message}');
      return Left(NetworkFailure(e.message));
    } catch (e) {
      print('❌ Unexpected error in getSupportedCurrencies: $e');
      return Left(ServerFailure('Failed to get supported currencies: ${e.toString()}'));
    }
  }
}
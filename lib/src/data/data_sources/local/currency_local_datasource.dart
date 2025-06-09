import 'package:expense_tracker/src/core/error/exceptions.dart';
import 'package:expense_tracker/src/data/models/exchange_rate_model.dart';
import 'package:hive/hive.dart';

abstract class CurrencyLocalDataSource {
  Future<ExchangeRateModel?> getCachedExchangeRates(String baseCurrency);
  Future<void> cacheExchangeRates(ExchangeRateModel exchangeRate);
  Future<bool> isExchangeRateCacheValid(String baseCurrency, {Duration maxAge = const Duration(hours: 1)});
}

class CurrencyLocalDataSourceImpl implements CurrencyLocalDataSource {
  static const String EXCHANGE_RATES_BOX = 'exchange_rates';

  Box? _exchangeRatesBox;

  Future<Box> get exchangeRatesBox async {
    if (_exchangeRatesBox != null && _exchangeRatesBox!.isOpen) {
      return _exchangeRatesBox!;
    }
    _exchangeRatesBox = await Hive.openBox(EXCHANGE_RATES_BOX);
    return _exchangeRatesBox!;
  }

  @override
  Future<ExchangeRateModel?> getCachedExchangeRates(String baseCurrency) async {
    try {
      final box = await exchangeRatesBox;
      final cachedData = box.get(baseCurrency);

      if (cachedData != null) {
        return ExchangeRateModel.fromJson(Map<String, dynamic>.from(cachedData));
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached exchange rates: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheExchangeRates(ExchangeRateModel exchangeRate) async {
    try {
      final box = await exchangeRatesBox;
      await box.put(exchangeRate.baseCurrency, exchangeRate.toJson());
    } catch (e) {
      throw CacheException('Failed to cache exchange rates: ${e.toString()}');
    }
  }

  @override
  Future<bool> isExchangeRateCacheValid(
      String baseCurrency, {
        Duration maxAge = const Duration(hours: 1),
      }) async {
    try {
      final cachedRate = await getCachedExchangeRates(baseCurrency);
      if (cachedRate == null) return false;

      final now = DateTime.now();
      final cacheAge = now.difference(cachedRate.lastUpdated);

      return cacheAge <= maxAge;
    } catch (e) {
      return false;
    }
  }
}
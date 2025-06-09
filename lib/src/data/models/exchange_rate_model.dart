import 'package:expense_tracker/src/domain/entities/exchange_rate.dart';

class ExchangeRateModel {
  final String baseCurrency;
  final Map<String, double> rates;
  final DateTime lastUpdated;

  ExchangeRateModel({
    required this.baseCurrency,
    required this.rates,
    required this.lastUpdated,
  });

  factory ExchangeRateModel.fromJson(Map<String, dynamic> json) {
    return ExchangeRateModel(
      baseCurrency: json['base_code'] ?? json['base'] ?? 'USD',
      rates: Map<String, double>.from(
        (json['conversion_rates'] ?? json['rates'] ?? {})
            .map((key, value) => MapEntry(key, value.toDouble())),
      ),
      lastUpdated: json['time_last_update_unix'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              json['time_last_update_unix'] * 1000,
            )
          : DateTime.now(),
    );
  }

  ExchangeRate toEntity() {
    return ExchangeRate(
      baseCurrency: baseCurrency,
      rates: rates,
      lastUpdated: lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base_code': baseCurrency,
      'conversion_rates': rates,
      'time_last_update_unix': lastUpdated.millisecondsSinceEpoch ~/ 1000,
    };
  }
  List<String> get supportedCurrencies {
    return rates.keys.toList()..sort();
  }
}
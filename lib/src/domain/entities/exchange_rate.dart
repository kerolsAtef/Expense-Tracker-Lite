
import 'package:equatable/equatable.dart';

class ExchangeRate extends Equatable {
  final String baseCurrency;
  final Map<String, double> rates;
  final DateTime lastUpdated;

  const ExchangeRate({
    required this.baseCurrency,
    required this.rates,
    required this.lastUpdated,
  });

  double? getRate(String toCurrency) {
    return rates[toCurrency];
  }

  @override
  List<Object> get props => [baseCurrency, rates, lastUpdated];
}

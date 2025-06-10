import 'dart:convert';
import 'package:expense_tracker/src/core/error/exceptions.dart';
import 'package:expense_tracker/src/data/models/exchange_rate_model.dart';
import 'package:http/http.dart' as http;

abstract class CurrencyRemoteDataSource {
  Future<ExchangeRateModel> getExchangeRates({String baseCurrency = 'USD'});
  Future<List<String>> getSupportedCurrencies();
}

class CurrencyRemoteDataSourceFreeImpl implements CurrencyRemoteDataSource {
  final http.Client client;
  static const String baseUrl = 'https://open.er-api.com/v6/latest';

  CurrencyRemoteDataSourceFreeImpl({required this.client});

  @override
  Future<ExchangeRateModel> getExchangeRates({String baseCurrency = 'USD'}) async {
    try {
      print('🌐 Fetching exchange rates for $baseCurrency from: $baseUrl/$baseCurrency');

      final response = await client.get(
        Uri.parse('$baseUrl/$baseCurrency'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'ExpenseTracker/1.0',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw NetworkException('Request timeout');
        },
      );

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('✅ Exchange rates received: ${jsonData['rates']?.length ?? 0} currencies');

        if (jsonData['result'] == 'success') {
          return ExchangeRateModel.fromJson(jsonData);
        } else {
          throw ServerException('API Error: ${jsonData['error'] ?? 'Unknown error'}');
        }
      } else if (response.statusCode == 404) {
        throw ServerException('Currency not supported: $baseCurrency');
      } else if (response.statusCode == 429) {
        throw ServerException('Rate limit exceeded. Please try again later.');
      } else {
        throw ServerException('Failed to fetch exchange rates. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching exchange rates: $e');
      if (e is ServerException || e is NetworkException) rethrow;
      throw NetworkException('Network error: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getSupportedCurrencies() async {
    try {
      // Get the latest USD rates to extract supported currencies
      final exchangeRates = await getExchangeRates(baseCurrency: 'USD');
      return exchangeRates.supportedCurrencies;
    } catch (e) {
      print('⚠️ Could not fetch supported currencies dynamically, using fallback list');
      // Fallback list of common currencies
      return [
        'USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 'CHF', 'CNY', 'SEK', 'NZD',
        'MXN', 'SGD', 'HKD', 'NOK', 'TRY', 'RUB', 'INR', 'BRL', 'ZAR', 'KRW',
        'EGP', 'AED', 'SAR', 'QAR', 'KWD', 'BHD', 'OMR', 'JOD', 'LBP', 'ILS',
        'DKK', 'PLN', 'CZK', 'HUF', 'BGN', 'RON', 'HRK', 'RSD', 'UAH', 'MYR',
        'THB', 'IDR', 'PHP', 'VND', 'PKR', 'BDT', 'LKR', 'MMK', 'KHR', 'NPR',
        'AFN', 'ALL', 'AMD', 'ANG', 'AOA', 'ARS', 'AWG', 'AZN', 'BAM', 'BBD',
        'BIF', 'BMD', 'BND', 'BOB', 'BSD', 'BTN', 'BWP', 'BYN', 'BZD', 'CDF',
        'CLP', 'COP', 'CRC', 'CUP', 'CVE', 'DJF', 'DOP', 'DZD', 'ERN', 'ETB',
        'FJD', 'FKP', 'GEL', 'GGP', 'GHS', 'GIP', 'GMD', 'GNF', 'GTQ', 'GYD',
        'HNL', 'HTG', 'IMP', 'IQD', 'IRR', 'ISK', 'JEP', 'JMD', 'KES', 'KGS',
        'KMF', 'KPW', 'KYD', 'KZT', 'LAK', 'LRD', 'LSL', 'LYD', 'MAD', 'MDL',
        'MGA', 'MKD', 'MNT', 'MOP', 'MRU', 'MUR', 'MVR', 'MWK', 'MZN', 'NAD',
        'NGN', 'NIO', 'PEN', 'PGK', 'PYG', 'SBD', 'SCR', 'SDG', 'SHP', 'SLE',
        'SLL', 'SOS', 'SRD', 'SSP', 'STN', 'SYP', 'SZL', 'TJS', 'TMT', 'TND',
        'TOP', 'TTD', 'TVD', 'TWD', 'TZS', 'UGX', 'UYU', 'UZS', 'VES', 'VUV',
        'WST', 'XAF', 'XCD', 'XDR', 'XOF', 'XPF', 'YER', 'ZMW', 'ZWL',
      ];
    }
  }
}

// Premium implementation using exchangerate-api.com (requires API key)
class CurrencyRemoteDataSourceImpl implements CurrencyRemoteDataSource {
  final http.Client client;
  static const String baseUrl = 'https://v6.exchangerate-api.com/v6';
  static const String apiKey = 'YOUR_API_KEY'; // Replace with actual API key

  CurrencyRemoteDataSourceImpl({required this.client});

  @override
  Future<ExchangeRateModel> getExchangeRates({String baseCurrency = 'USD'}) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/$apiKey/latest/$baseCurrency'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['result'] == 'success') {
          return ExchangeRateModel.fromJson(jsonData);
        } else {
          throw ServerException('API Error: ${jsonData['error-type']}');
        }
      } else {
        throw ServerException('Failed to fetch exchange rates. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Network error: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getSupportedCurrencies() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/$apiKey/codes'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['result'] == 'success') {
          final List<dynamic> codes = jsonData['supported_codes'];
          return codes.map((code) => code[0] as String).toList();
        } else {
          throw ServerException('API Error: ${jsonData['error-type']}');
        }
      } else {
        throw ServerException('Failed to fetch supported currencies. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Network error: ${e.toString()}');
    }
  }
}
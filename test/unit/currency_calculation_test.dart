import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/src/domain/usecases/expense/convert_currency_usecase.dart';
import 'package:expense_tracker/src/domain/repositories/currency_repository.dart';
import 'package:expense_tracker/src/domain/entities/exchange_rate.dart';
import 'package:expense_tracker/src/core/error/failures.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate mocks
@GenerateMocks([CurrencyRepository])
import 'currency_calculation_test.mocks.dart';

void main() {
  group('Currency Calculation Tests', () {
    late ConvertCurrencyUseCase convertCurrencyUseCase;
    late MockCurrencyRepository mockRepository;

    setUp(() {
      mockRepository = MockCurrencyRepository();
      convertCurrencyUseCase = ConvertCurrencyUseCase(mockRepository);
    });

    group('Basic Currency Conversion', () {
      test('should return same amount when converting same currency', () async {
        // Arrange
        const amount = 100.0;
        const currency = 'USD';
        final params = ConvertCurrencyParams(
          amount: amount,
          fromCurrency: currency,
          toCurrency: currency,
        );

        when(mockRepository.convertCurrency(
          amount: amount,
          fromCurrency: currency,
          toCurrency: currency,
        )).thenAnswer((_) async => const Right(amount));

        // Act
        final result = await convertCurrencyUseCase(params);

        // Assert
        expect(result, const Right<Failure, double>(amount));
        verify(mockRepository.convertCurrency(
          amount: amount,
          fromCurrency: currency,
          toCurrency: currency,
        )).called(1);
      });

      test('should convert USD to EUR correctly', () async {
        // Arrange
        const amount = 100.0;
        const expectedResult = 85.0; // Simulated EUR conversion
        final params = ConvertCurrencyParams(
          amount: amount,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
        );

        when(mockRepository.convertCurrency(
          amount: amount,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
        )).thenAnswer((_) async => const Right(expectedResult));

        // Act
        final result = await convertCurrencyUseCase(params);

        // Assert
        expect(result, const Right<Failure, double>(expectedResult));
        verify(mockRepository.convertCurrency(
          amount: amount,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
        )).called(1);
      });

      test('should convert EUR to USD correctly', () async {
        // Arrange
        const amount = 85.0;
        const expectedResult = 100.0; // Simulated USD conversion
        final params = ConvertCurrencyParams(
          amount: amount,
          fromCurrency: 'EUR',
          toCurrency: 'USD',
        );

        when(mockRepository.convertCurrency(
          amount: amount,
          fromCurrency: 'EUR',
          toCurrency: 'USD',
        )).thenAnswer((_) async => const Right(expectedResult));

        // Act
        final result = await convertCurrencyUseCase(params);

        // Assert
        expect(result, const Right<Failure, double>(expectedResult));
      });
    });

    group('Edge Cases', () {
      test('should handle very small amounts correctly', () async {
        // Arrange
        const amount = 0.01;
        const expectedResult = 0.008; // Very small conversion
        final params = ConvertCurrencyParams(
          amount: amount,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
        );

        when(mockRepository.convertCurrency(
          amount: amount,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
        )).thenAnswer((_) async => const Right(expectedResult));

        // Act
        final result = await convertCurrencyUseCase(params);

        // Assert
        expect(result, const Right<Failure, double>(expectedResult));
      });

      test('should handle very large amounts correctly', () async {
        // Arrange
        const amount = 1000000.0; // 1 million
        const expectedResult = 850000.0; // Converted amount
        final params = ConvertCurrencyParams(
          amount: amount,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
        );

        when(mockRepository.convertCurrency(
          amount: amount,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
        )).thenAnswer((_) async => const Right(expectedResult));

        // Act
        final result = await convertCurrencyUseCase(params);

        // Assert
        expect(result, const Right<Failure, double>(expectedResult));
      });

      test('should handle decimal precision correctly', () async {
        // Arrange
        const amount = 99.99;
        const expectedResult = 84.9915; // Precise conversion
        final params = ConvertCurrencyParams(
          amount: amount,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
        );

        when(mockRepository.convertCurrency(
          amount: amount,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
        )).thenAnswer((_) async => const Right(expectedResult));

        // Act
        final result = await convertCurrencyUseCase(params);

        // Assert
        expect(result, const Right<Failure, double>(expectedResult));
      });
    });

    group('Error Handling', () {
      test('should return ValidationFailure for zero amount', () async {
        // Arrange
        const amount = 0.0;
        final params = ConvertCurrencyParams(
          amount: amount,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
        );

        when(mockRepository.convertCurrency(
          amount: amount,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
        )).thenAnswer((_) async => const Left(ValidationFailure('Amount must be greater than zero')));

        // Act
        final result = await convertCurrencyUseCase(params);

        // Assert
        expect(result, isA<Left<Failure, double>>());
        result.fold(
              (failure) => expect(failure, isA<ValidationFailure>()),
              (amount) => fail('Expected ValidationFailure'),
        );
      });

      test('should return ValidationFailure for negative amount', () async {
        // Arrange
        const amount = -10.0;
        final params = ConvertCurrencyParams(
          amount: amount,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
        );

        when(mockRepository.convertCurrency(
          amount: amount,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
        )).thenAnswer((_) async => const Left(ValidationFailure('Amount must be greater than zero')));

        // Act
        final result = await convertCurrencyUseCase(params);

        // Assert
        expect(result, isA<Left<Failure, double>>());
        result.fold(
              (failure) => expect(failure, isA<ValidationFailure>()),
              (amount) => fail('Expected ValidationFailure'),
        );
      });

      test('should return ServerFailure when exchange rate not available', () async {
        // Arrange
        const amount = 100.0;
        final params = ConvertCurrencyParams(
          amount: amount,
          fromCurrency: 'USD',
          toCurrency: 'XYZ', // Invalid currency
        );

        when(mockRepository.convertCurrency(
          amount: amount,
          fromCurrency: 'USD',
          toCurrency: 'XYZ',
        )).thenAnswer((_) async => const Left(ServerFailure('Exchange rate not available for XYZ')));

        // Act
        final result = await convertCurrencyUseCase(params);

        // Assert
        expect(result, isA<Left<Failure, double>>());
        result.fold(
              (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains('Exchange rate not available'));
          },
              (amount) => fail('Expected ServerFailure'),
        );
      });

      test('should return NetworkFailure when network is unavailable', () async {
        // Arrange
        const amount = 100.0;
        final params = ConvertCurrencyParams(
          amount: amount,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
        );

        when(mockRepository.convertCurrency(
          amount: amount,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
        )).thenAnswer((_) async => const Left(NetworkFailure('Network error. Please check your connection')));

        // Act
        final result = await convertCurrencyUseCase(params);

        // Assert
        expect(result, isA<Left<Failure, double>>());
        result.fold(
              (failure) {
            expect(failure, isA<NetworkFailure>());
            expect(failure.message, contains('Network error'));
          },
              (amount) => fail('Expected NetworkFailure'),
        );
      });
    });

    group('Multiple Currency Conversions', () {
      test('should handle multiple different currency pairs', () async {
        // Test data with different currency pairs and rates
        final testCases = [
          {'from': 'USD', 'to': 'EUR', 'amount': 100.0, 'expected': 85.0},
          {'from': 'EUR', 'to': 'GBP', 'amount': 85.0, 'expected': 75.0},
          {'from': 'GBP', 'to': 'JPY', 'amount': 75.0, 'expected': 10000.0},
          {'from': 'JPY', 'to': 'USD', 'amount': 10000.0, 'expected': 90.0},
        ];

        for (final testCase in testCases) {
          // Arrange
          final amount = testCase['amount'] as double;
          final fromCurrency = testCase['from'] as String;
          final toCurrency = testCase['to'] as String;
          final expectedResult = testCase['expected'] as double;

          final params = ConvertCurrencyParams(
            amount: amount,
            fromCurrency: fromCurrency,
            toCurrency: toCurrency,
          );

          when(mockRepository.convertCurrency(
            amount: amount,
            fromCurrency: fromCurrency,
            toCurrency: toCurrency,
          )).thenAnswer((_) async => Right(expectedResult));

          // Act
          final result = await convertCurrencyUseCase(params);

          // Assert
          expect(result, Right<Failure, double>(expectedResult));
        }
      });
    });

    group('Real-world Exchange Rate Calculations', () {
      test('should calculate conversion with realistic exchange rates', () async {
        // Arrange - Real-world-like exchange rates
        const usdToEurRate = 0.85;
        const amount = 100.0;
        const expectedResult = amount * usdToEurRate;

        final params = ConvertCurrencyParams(
          amount: amount,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
        );

        when(mockRepository.convertCurrency(
          amount: amount,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
        )).thenAnswer((_) async => const Right(expectedResult));

        // Act
        final result = await convertCurrencyUseCase(params);

        // Assert
        expect(result, const Right<Failure, double>(expectedResult));

        result.fold(
              (failure) => fail('Expected success'),
              (convertedAmount) {
            expect(convertedAmount, expectedResult);
            expect(convertedAmount, lessThan(amount)); // EUR should be less than USD
          },
        );
      });

      test('should handle rounding correctly for currency conversion', () async {
        // Arrange
        const amount = 33.33;
        const rate = 0.857; // Rate that would cause rounding
        const expectedResult = 28.55481; // 33.33 * 0.857

        final params = ConvertCurrencyParams(
          amount: amount,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
        );

        when(mockRepository.convertCurrency(
          amount: amount,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
        )).thenAnswer((_) async => const Right(expectedResult));

        // Act
        final result = await convertCurrencyUseCase(params);

        // Assert
        expect(result, const Right<Failure, double>(expectedResult));

        result.fold(
              (failure) => fail('Expected success'),
              (convertedAmount) {
            // Check that the result maintains reasonable precision
            expect(convertedAmount.toStringAsFixed(2), '28.55');
          },
        );
      });
    });
  });
}
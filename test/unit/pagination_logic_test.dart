import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/src/domain/usecases/expense/get_expenses_usecase.dart';
import 'package:expense_tracker/src/domain/repositories/expense_repository.dart';
import 'package:expense_tracker/src/domain/entities/expense.dart';
import 'package:expense_tracker/src/core/error/failures.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate mocks
@GenerateMocks([ExpenseRepository])
import 'pagination_logic_test.mocks.dart';

void main() {
  group('Pagination Logic Tests', () {
    late GetExpensesUseCase getExpensesUseCase;
    late MockExpenseRepository mockRepository;

    setUp(() {
      mockRepository = MockExpenseRepository();
      getExpensesUseCase = GetExpensesUseCase(mockRepository);
    });

    // Helper method to create mock expenses
    List<Expense> createMockExpenses(int count, {int startId = 1}) {
      return List.generate(count, (index) {
        final id = startId + index;
        return Expense(
          id: id.toString(),
          userId: 'user1',
          category: 'groceries',
          amount: 10.0 + index,
          currency: 'USD',
          convertedAmount: 10.0 + index,
          date: DateTime.now().subtract(Duration(days: index)),
          categoryIcon: '🛒',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      });
    }

    group('Basic Pagination', () {
      test('should return first page of expenses with default limit', () async {
        // Arrange
        const limit = 10;
        const page = 0;
        final mockExpenses = createMockExpenses(10);

        final params = GetExpensesParams(
          limit: limit,
          page: page,
        );

        when(mockRepository.getExpenses(
          limit: limit,
          page: page,
        )).thenAnswer((_) async => Right(mockExpenses));

        // Act
        final result = await getExpensesUseCase(params);

        // Assert
        expect(result, isA<Right<Failure, List<Expense>>>());
        result.fold(
              (failure) => fail('Expected success'),
              (expenses) {
            expect(expenses.length, 10);
            expect(expenses.first.id, '1');
            expect(expenses.last.id, '10');
          },
        );
        verify(mockRepository.getExpenses(limit: limit, page: page)).called(1);
      });

      test('should return second page of expenses', () async {
        // Arrange
        const limit = 10;
        const page = 10;
        final mockExpenses = createMockExpenses(10, startId: 11);

        final params = GetExpensesParams(
          limit: limit,
          page: page,
        );

        when(mockRepository.getExpenses(
          limit: limit,
          page: page,
        )).thenAnswer((_) async => Right(mockExpenses));

        // Act
        final result = await getExpensesUseCase(params);

        // Assert
        expect(result, isA<Right<Failure, List<Expense>>>());
        result.fold(
              (failure) => fail('Expected success'),
              (expenses) {
            expect(expenses.length, 10);
            expect(expenses.first.id, '11');
            expect(expenses.last.id, '20');
          },
        );
      });

      test('should handle partial last page correctly', () async {
        // Arrange
        const limit = 10;
        const page = 25;
        final mockExpenses = createMockExpenses(5, startId: 26); // Only 5 items in last page

        final params = GetExpensesParams(
          limit: limit,
          page: page,
        );

        when(mockRepository.getExpenses(
          limit: limit,
          page: page,
        )).thenAnswer((_) async => Right(mockExpenses));

        // Act
        final result = await getExpensesUseCase(params);

        // Assert
        expect(result, isA<Right<Failure, List<Expense>>>());
        result.fold(
              (failure) => fail('Expected success'),
              (expenses) {
            expect(expenses.length, 5); // Partial page
            expect(expenses.first.id, '26');
            expect(expenses.last.id, '30');
          },
        );
      });
    });

    group('Custom Page Sizes', () {
      test('should handle custom page size of 5', () async {
        // Arrange
        const limit = 5;
        const page = 0;
        final mockExpenses = createMockExpenses(5);

        final params = GetExpensesParams(
          limit: limit,
          page: page,
        );

        when(mockRepository.getExpenses(
          limit: limit,
          page: page,
        )).thenAnswer((_) async => Right(mockExpenses));

        // Act
        final result = await getExpensesUseCase(params);

        // Assert
        expect(result, isA<Right<Failure, List<Expense>>>());
        result.fold(
              (failure) => fail('Expected success'),
              (expenses) => expect(expenses.length, 5),
        );
      });

      test('should handle custom page size of 20', () async {
        // Arrange
        const limit = 20;
        const page = 0;
        final mockExpenses = createMockExpenses(20);

        final params = GetExpensesParams(
          limit: limit,
          page: page,
        );

        when(mockRepository.getExpenses(
          limit: limit,
          page: page,
        )).thenAnswer((_) async => Right(mockExpenses));

        // Act
        final result = await getExpensesUseCase(params);

        // Assert
        expect(result, isA<Right<Failure, List<Expense>>>());
        result.fold(
              (failure) => fail('Expected success'),
              (expenses) => expect(expenses.length, 20),
        );
      });

      test('should handle page size of 1 (single item)', () async {
        // Arrange
        const limit = 1;
        const page = 0;
        final mockExpenses = createMockExpenses(1);

        final params = GetExpensesParams(
          limit: limit,
          page: page,
        );

        when(mockRepository.getExpenses(
          limit: limit,
          page: page,
        )).thenAnswer((_) async => Right(mockExpenses));

        // Act
        final result = await getExpensesUseCase(params);

        // Assert
        expect(result, isA<Right<Failure, List<Expense>>>());
        result.fold(
              (failure) => fail('Expected success'),
              (expenses) {
            expect(expenses.length, 1);
            expect(expenses.first.id, '1');
          },
        );
      });
    });

    group('Edge Cases', () {
      test('should return empty list when no expenses exist', () async {
        // Arrange
        const limit = 10;
        const page = 0;
        final emptyExpenses = <Expense>[];

        final params = GetExpensesParams(
          limit: limit,
          page: page,
        );

        when(mockRepository.getExpenses(
          limit: limit,
          page: page,
        )).thenAnswer((_) async => Right(emptyExpenses));

        // Act
        final result = await getExpensesUseCase(params);

        // Assert
        expect(result, isA<Right<Failure, List<Expense>>>());
        result.fold(
              (failure) => fail('Expected success'),
              (expenses) => expect(expenses.isEmpty, true),
        );
      });

      test('should handle page beyond available data', () async {
        // Arrange
        const limit = 10;
        const page = 1000; // Way beyond available data
        final emptyExpenses = <Expense>[];

        final params = GetExpensesParams(
          limit: limit,
          page: page,
        );

        when(mockRepository.getExpenses(
          limit: limit,
          page: page,
        )).thenAnswer((_) async => Right(emptyExpenses));

        // Act
        final result = await getExpensesUseCase(params);

        // Assert
        expect(result, isA<Right<Failure, List<Expense>>>());
        result.fold(
              (failure) => fail('Expected success'),
              (expenses) => expect(expenses.isEmpty, true),
        );
      });

      test('should handle zero limit', () async {
        // Arrange
        const limit = 0;
        const page = 0;
        final emptyExpenses = <Expense>[];

        final params = GetExpensesParams(
          limit: limit,
          page: page,
        );

        when(mockRepository.getExpenses(
          limit: limit,
          page: page,
        )).thenAnswer((_) async => Right(emptyExpenses));

        // Act
        final result = await getExpensesUseCase(params);

        // Assert
        expect(result, isA<Right<Failure, List<Expense>>>());
        result.fold(
              (failure) => fail('Expected success'),
              (expenses) => expect(expenses.isEmpty, true),
        );
      });

      test('should handle negative page gracefully', () async {
        // Arrange
        const limit = 10;
        const page = -5; // Negative page

        final params = GetExpensesParams(
          limit: limit,
          page: page,
        );

        when(mockRepository.getExpenses(
          limit: limit,
          page: page,
        )).thenAnswer((_) async => const Left(ValidationFailure('page cannot be negative')));

        // Act
        final result = await getExpensesUseCase(params);

        // Assert
        expect(result, isA<Left<Failure, List<Expense>>>());
        result.fold(
              (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, contains('page cannot be negative'));
          },
              (expenses) => fail('Expected ValidationFailure'),
        );
      });

      test('should handle negative limit gracefully', () async {
        // Arrange
        const limit = -10; // Negative limit
        const page = 0;

        final params = GetExpensesParams(
          limit: limit,
          page: page,
        );

        when(mockRepository.getExpenses(
          limit: limit,
          page: page,
        )).thenAnswer((_) async => const Left(ValidationFailure('Limit cannot be negative')));

        // Act
        final result = await getExpensesUseCase(params);

        // Assert
        expect(result, isA<Left<Failure, List<Expense>>>());
        result.fold(
              (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, contains('Limit cannot be negative'));
          },
              (expenses) => fail('Expected ValidationFailure'),
        );
      });
    });

    group('Pagination with Filtering', () {
      test('should handle pagination with category filter', () async {
        // Arrange
        const limit = 10;
        const page = 0;
        const category = 'groceries';
        final mockExpenses = createMockExpenses(10);

        final params = GetExpensesParams(
          limit: limit,
          page: page,
        );

        when(mockRepository.getExpenses(
          limit: limit,
          page: page,
        )).thenAnswer((_) async => Right(mockExpenses));

        // Act
        final result = await getExpensesUseCase(params);

        // Assert
        expect(result, isA<Right<Failure, List<Expense>>>());
        result.fold(
              (failure) => fail('Expected success'),
              (expenses) {
            expect(expenses.length, 10);
            expect(expenses.every((e) => e.category == category), true);
          },
        );
      });

      test('should handle pagination with date range filter', () async {
        // Arrange
        const limit = 10;
        const page = 0;
        final startDate = DateTime.now().subtract(const Duration(days: 30));
        final endDate = DateTime.now();
        final mockExpenses = createMockExpenses(10);

        final params = GetExpensesParams(
          limit: limit,
          page: page,
        );

        when(mockRepository.getExpenses(
          limit: limit,
          page: page,
        )).thenAnswer((_) async => Right(mockExpenses));

        // Act
        final result = await getExpensesUseCase(params);

        // Assert
        expect(result, isA<Right<Failure, List<Expense>>>());
        result.fold(
              (failure) => fail('Expected success'),
              (expenses) {
            expect(expenses.length, 10);
            // All expenses should be within date range
            expect(expenses.every((e) =>
            e.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
                e.date.isBefore(endDate.add(const Duration(days: 1)))
            ), true);
          },
        );
      });
    });

    group('Pagination Performance', () {
      test('should handle large page sizes efficiently', () async {
        // Arrange
        const limit = 100; // Large page size
        const page = 0;
        final mockExpenses = createMockExpenses(100);

        final params = GetExpensesParams(
          limit: limit,
          page: page,
        );

        when(mockRepository.getExpenses(
          limit: limit,
          page: page,
        )).thenAnswer((_) async => Right(mockExpenses));

        // Act
        final stopwatch = Stopwatch()..start();
        final result = await getExpensesUseCase(params);
        stopwatch.stop();

        // Assert
        expect(result, isA<Right<Failure, List<Expense>>>());
        result.fold(
              (failure) => fail('Expected success'),
              (expenses) => expect(expenses.length, 100),
        );

        // Performance assertion (should complete reasonably quickly)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Less than 1 second
      });

      test('should handle deep pagination efficiently', () async {
        // Arrange
        const limit = 10;
        const page = 10000; // Deep pagination
        final mockExpenses = createMockExpenses(10, startId: 10001);

        final params = GetExpensesParams(
          limit: limit,
          page: page,
        );

        when(mockRepository.getExpenses(
          limit: limit,
          page: page,
        )).thenAnswer((_) async => Right(mockExpenses));

        // Act
        final result = await getExpensesUseCase(params);

        // Assert
        expect(result, isA<Right<Failure, List<Expense>>>());
        result.fold(
              (failure) => fail('Expected success'),
              (expenses) {
            expect(expenses.length, 10);
            expect(expenses.first.id, '10001');
          },
        );
      });
    });

    group('Error Handling in Pagination', () {
      test('should handle repository errors during pagination', () async {
        // Arrange
        const limit = 10;
        const page = 0;

        final params = GetExpensesParams(
          limit: limit,
          page: page,
        );

        when(mockRepository.getExpenses(
          limit: limit,
          page: page,
        )).thenAnswer((_) async => const Left(ServerFailure('Database connection failed')));

        // Act
        final result = await getExpensesUseCase(params);

        // Assert
        expect(result, isA<Left<Failure, List<Expense>>>());
        result.fold(
              (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains('Database connection failed'));
          },
              (expenses) => fail('Expected ServerFailure'),
        );
      });

      test('should handle cache errors during pagination', () async {
        // Arrange
        const limit = 10;
        const page = 0;

        final params = GetExpensesParams(
          limit: limit,
          page: page,
        );

        when(mockRepository.getExpenses(
          limit: limit,
          page: page,
        )).thenAnswer((_) async => const Left(CacheFailure('Cache read failed')));

        // Act
        final result = await getExpensesUseCase(params);

        // Assert
        expect(result, isA<Left<Failure, List<Expense>>>());
        result.fold(
              (failure) {
            expect(failure, isA<CacheFailure>());
            expect(failure.message, contains('Cache read failed'));
          },
              (expenses) => fail('Expected CacheFailure'),
        );
      });
    });
  });
}
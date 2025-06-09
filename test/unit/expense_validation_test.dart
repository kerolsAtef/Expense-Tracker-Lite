import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:expense_tracker/src/domain/usecases/expense/add_expense_usecase.dart';
import 'package:expense_tracker/src/core/error/failures.dart';
import 'package:expense_tracker/src/domain/entities/expense.dart';
import 'package:expense_tracker/src/domain/repositories/expense_repository.dart';

import 'expense_validation_test.mocks.dart';

@GenerateMocks([ExpenseRepository])
void main() {
  late AddExpenseUseCase useCase;
  late MockExpenseRepository mockRepository;

  setUp(() {
    mockRepository = MockExpenseRepository();
    useCase = AddExpenseUseCase(mockRepository);
  });

  // Helper function to create a valid expense
  Expense createExpense({
    String id = '1',
    double amount = 25.99,
    String category = 'groceries',
  }) {
    final now = DateTime.now();
    return Expense(
      id: id,
      userId: 'user1',
      category: category,
      amount: amount,
      currency: 'USD',
      convertedAmount: amount,
      date: now,
      categoryIcon: '🛒',
      createdAt: now,
      updatedAt: now,
    );
  }

  group('AddExpenseUseCase', () {
    test('should add expense successfully with valid params', () async {
      // Arrange
      final params = AddExpenseParams(
        category: 'groceries',
        amount: 25.99,
        currency: 'USD',
        date: DateTime.now(),
        categoryIcon: '🛒',
      );

      final expectedExpense = createExpense();

      when(mockRepository.addExpense(
        category: anyNamed('category'),
        amount: anyNamed('amount'),
        currency: anyNamed('currency'),
        date: anyNamed('date'),
        description: anyNamed('description'),
        receiptPath: anyNamed('receiptPath'),
        categoryIcon: anyNamed('categoryIcon'),
      )).thenAnswer((_) async => Right(expectedExpense));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, Right(expectedExpense));
      verify(mockRepository.addExpense(
        category: params.category,
        amount: params.amount,
        currency: params.currency,
        date: params.date,
        description: params.description,
        receiptPath: params.receiptPath,
        categoryIcon: params.categoryIcon,
      )).called(1);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      final params = AddExpenseParams(
        category: 'groceries',
        amount: 25.99,
        currency: 'USD',
        date: DateTime.now(),
        categoryIcon: '🛒',
      );

      when(mockRepository.addExpense(
        category: anyNamed('category'),
        amount: anyNamed('amount'),
        currency: anyNamed('currency'),
        date: anyNamed('date'),
        description: anyNamed('description'),
        receiptPath: anyNamed('receiptPath'),
        categoryIcon: anyNamed('categoryIcon'),
      )).thenAnswer((_) async => const Left(ServerFailure('Failed to add expense')));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, const Left(ServerFailure('Failed to add expense')));
    });

    test('should pass description when provided', () async {
      // Arrange
      final params = AddExpenseParams(
        category: 'groceries',
        amount: 25.99,
        currency: 'USD',
        date: DateTime.now(),
        description: 'Weekly shopping',
        categoryIcon: '🛒',
      );

      final expectedExpense = createExpense();

      when(mockRepository.addExpense(
        category: anyNamed('category'),
        amount: anyNamed('amount'),
        currency: anyNamed('currency'),
        date: anyNamed('date'),
        description: anyNamed('description'),
        receiptPath: anyNamed('receiptPath'),
        categoryIcon: anyNamed('categoryIcon'),
      )).thenAnswer((_) async => Right(expectedExpense));

      // Act
      await useCase(params);

      // Assert
      verify(mockRepository.addExpense(
        category: params.category,
        amount: params.amount,
        currency: params.currency,
        date: params.date,
        description: 'Weekly shopping',
        receiptPath: null,
        categoryIcon: params.categoryIcon,
      )).called(1);
    });

    test('should pass receipt path when provided', () async {
      // Arrange
      final params = AddExpenseParams(
        category: 'groceries',
        amount: 25.99,
        currency: 'USD',
        date: DateTime.now(),
        receiptPath: '/path/to/receipt.jpg',
        categoryIcon: '🛒',
      );

      final expectedExpense = createExpense();

      when(mockRepository.addExpense(
        category: anyNamed('category'),
        amount: anyNamed('amount'),
        currency: anyNamed('currency'),
        date: anyNamed('date'),
        description: anyNamed('description'),
        receiptPath: anyNamed('receiptPath'),
        categoryIcon: anyNamed('categoryIcon'),
      )).thenAnswer((_) async => Right(expectedExpense));

      // Act
      await useCase(params);

      // Assert
      verify(mockRepository.addExpense(
        category: params.category,
        amount: params.amount,
        currency: params.currency,
        date: params.date,
        description: null,
        receiptPath: '/path/to/receipt.jpg',
        categoryIcon: params.categoryIcon,
      )).called(1);
    });
  });
}

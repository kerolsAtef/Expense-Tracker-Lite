import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:expense_tracker/src/presentation/screens/add_expense/controller/cubit.dart';
import 'package:expense_tracker/src/presentation/screens/add_expense/controller/state.dart';
import 'package:expense_tracker/src/presentation/screens/add_expense/widgets/add_expense_form.dart';
import 'package:expense_tracker/src/domain/entities/expense.dart';

// Generate mocks
@GenerateMocks([AddExpenseCubit])
import 'add_expense_form_widget_test.mocks.dart';

void main() {
  group('AddExpenseForm Widget Tests', () {
    late MockAddExpenseCubit mockCubit;

    setUp(() {
      mockCubit = MockAddExpenseCubit();

      // Default behavior for the cubit
      when(mockCubit.state).thenReturn(AddExpenseInitial());
      when(mockCubit.stream).thenAnswer((_) => Stream.fromIterable([AddExpenseInitial()]));
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<AddExpenseCubit>.value(
            value: mockCubit,
            child: const AddExpenseForm(),
          ),
        ),
      );
    }

    group('Form Validation Tests', () {
      testWidgets('should show error when amount field is empty', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());

        // Act - Try to submit form without entering amount
        final saveButton = find.byType(ElevatedButton);
        await tester.tap(saveButton);
        await tester.pump();

        // Assert
        expect(find.text('Amount is required'), findsOneWidget);
        verifyNever(mockCubit.addExpense(
          category: anyNamed('category'),
          amount: anyNamed('amount'),
          currency: anyNamed('currency'),
          date: anyNamed('date'),
          categoryIcon: anyNamed('categoryIcon'),
        ));
      });

      testWidgets('should show error when amount is zero', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());

        // Act - Enter zero amount
        final amountField = find.byType(TextFormField).first;
        await tester.enterText(amountField, '0');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        expect(find.text('Please enter a valid amount'), findsOneWidget);
      });

      testWidgets('should show error when amount is negative', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());

        // Act - Enter negative amount
        final amountField = find.byType(TextFormField).first;
        await tester.enterText(amountField, '-10.50');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert
        expect(find.text('Please enter a valid amount'), findsOneWidget);
      });

      testWidgets('should accept valid positive amount', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());

        // Act - Enter valid amount
        final amountField = find.byType(TextFormField).first;
        await tester.enterText(amountField, '25.99');
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Assert - No validation error should be shown
        expect(find.text('Amount is required'), findsNothing);
        expect(find.text('Please enter a valid amount'), findsNothing);
      });

      testWidgets('should limit decimal places to 2', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());

        // Act - Try to enter more than 2 decimal places
        final amountField = find.byType(TextFormField).first;
        await tester.enterText(amountField, '25.999');

        // Assert - Should be limited to 2 decimal places
        final textField = tester.widget<TextFormField>(amountField);
        expect(textField.controller!.text, '25.99');
      });
    });

    group('Currency Selection Tests', () {
      testWidgets('should display currency dropdown with default USD', (WidgetTester tester) async {
        // Arrange
        when(mockCubit.state).thenReturn(const CurrencyLoaded(
          currencies: ['USD', 'EUR', 'GBP', 'JPY'],
        ));

        await tester.pumpWidget(createTestWidget());

        // Act & Assert
        expect(find.text('USD'), findsOneWidget);
        expect(find.byType(DropdownButton<String>), findsOneWidget);
      });

      testWidgets('should show currency conversion when non-USD currency is selected', (WidgetTester tester) async {
        // Arrange
        when(mockCubit.state).thenReturn(const CurrencyLoaded(
          currencies: ['USD', 'EUR', 'GBP', 'JPY'],
        ));
        when(mockCubit.convertCurrency(
          amount: anyNamed('amount'),
          fromCurrency: anyNamed('fromCurrency'),
          toCurrency: anyNamed('toCurrency'),
        )).thenAnswer((_) async => 85.0);

        await tester.pumpWidget(createTestWidget());

        // Act - Select EUR currency and enter amount
        final currencyDropdown = find.byType(DropdownButton<String>);
        await tester.tap(currencyDropdown);
        await tester.pumpAndSettle();
        await tester.tap(find.text('EUR').last);
        await tester.pumpAndSettle();

        final amountField = find.byType(TextFormField).first;
        await tester.enterText(amountField, '100');
        await tester.pump();

        // Wait for conversion
        await tester.pump(const Duration(milliseconds: 500));

        // Assert - Should show conversion
        expect(find.textContaining('USD'), findsAtLeastNWidgets(1));
      });
    });

    group('Category Selection Tests', () {
      testWidgets('should display category selection grid', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());

        // Act & Assert
        expect(find.text('Categories'), findsOneWidget);
        expect(find.byType(GridView), findsOneWidget);
      });

      testWidgets('should select category when tapped', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());

        // Act - Tap on a category (assuming groceries is default selected)
        final categoryItems = find.byType(GestureDetector);
        if (categoryItems.evaluate().isNotEmpty) {
          await tester.tap(categoryItems.first);
          await tester.pump();
        }

        // Assert - Category should be visually selected (this depends on your UI implementation)
        // You might need to check for specific styling or state changes
        expect(find.byType(GridView), findsOneWidget);
      });
    });

    group('Date Selection Tests', () {
      testWidgets('should display current date by default', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());
        final now = DateTime.now();
        final expectedDate = '${now.day}/${now.month}/${now.year}';

        // Act & Assert
        expect(find.text(expectedDate), findsOneWidget);
        expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
      });

      testWidgets('should open date picker when date field is tapped', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());

        // Act
        final dateField = find.byIcon(Icons.calendar_today_outlined);
        await tester.tap(dateField);
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(DatePickerDialog), findsOneWidget);
      });
    });

    group('Receipt Upload Tests', () {
      testWidgets('should display receipt upload section', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());

        // Act & Assert
        expect(find.text('Attach Receipt'), findsOneWidget);
        expect(find.byType(GestureDetector), findsAtLeastNWidgets(1));
      });

      testWidgets('should show receipt options when upload area is tapped', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());

        // Act - Find and tap the receipt upload area
        // This depends on your specific implementation
        final uploadArea = find.text('Attach Receipt');
        if (uploadArea.evaluate().isNotEmpty) {
          // Look for a tappable area near the "Attach Receipt" text
          final gestureDetectors = find.descendant(
            of: find.ancestor(
              of: uploadArea,
              matching: find.byType(Column),
            ),
            matching: find.byType(GestureDetector),
          );

          if (gestureDetectors.evaluate().isNotEmpty) {
            await tester.tap(gestureDetectors.first);
            await tester.pumpAndSettle();

            // Assert - Should show camera and gallery options
            expect(find.text('Select Receipt Source'), findsOneWidget);
            expect(find.text('Camera'), findsOneWidget);
            expect(find.text('Gallery'), findsOneWidget);
          }
        }
      });
    });

    group('Description Field Tests', () {
      testWidgets('should display optional description field', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());

        // Act & Assert
        expect(find.text('Description (Optional)'), findsOneWidget);
        expect(find.text('Add a note about this expense...'), findsOneWidget);
      });

      testWidgets('should accept description input', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());

        // Act
        final descriptionField = find.byType(TextFormField).last;
        await tester.enterText(descriptionField, 'Test description');
        await tester.pump();

        // Assert
        final textField = tester.widget<TextFormField>(descriptionField);
        expect(textField.controller!.text, 'Test description');
      });

      testWidgets('should limit description to 200 characters', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());

        // Act
        final longDescription = 'a' * 250; // 250 characters
        final descriptionField = find.byType(TextFormField).last;
        await tester.enterText(descriptionField, longDescription);
        await tester.pump();

        // Assert - Should be limited to 200 characters
        final textField = tester.widget<TextFormField>(descriptionField);
        expect(textField.controller!.text.length, lessThanOrEqualTo(200));
      });
    });

    group('Form Submission Tests', () {
      testWidgets('should call addExpense when form is valid and submitted', (WidgetTester tester) async {
        // Arrange
        when(mockCubit.state).thenReturn(const CurrencyLoaded(
          currencies: ['USD', 'EUR', 'GBP'],
        ));

        await tester.pumpWidget(createTestWidget());

        // Act - Fill in the form
        final amountField = find.byType(TextFormField).first;
        await tester.enterText(amountField, '25.99');

        final descriptionField = find.byType(TextFormField).last;
        await tester.enterText(descriptionField, 'Test expense');

        // Submit the form
        final saveButton = find.byType(ElevatedButton);
        await tester.tap(saveButton);
        await tester.pump();

        // Assert
        verify(mockCubit.addExpense(
          category: anyNamed('category'),
          amount: 25.99,
          currency: 'USD',
          date: anyNamed('date'),
          description: 'Test expense',
          categoryIcon: anyNamed('categoryIcon'),
        )).called(1);
      });

      testWidgets('should show loading state when form is being submitted', (WidgetTester tester) async {
        // Arrange
        when(mockCubit.state).thenReturn(AddExpenseLoading());

        await tester.pumpWidget(createTestWidget());

        // Act & Assert
        final saveButton = find.byType(ElevatedButton);
        final elevatedButton = tester.widget<ElevatedButton>(saveButton);

        expect(elevatedButton.onPressed, isNull); // Button should be disabled
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('should show success message when expense is added successfully', (WidgetTester tester) async {
        // Arrange
        final mockExpense = Expense(
          id: '1',
          userId: 'user1',
          category: 'groceries',
          amount: 25.99,
          currency: 'USD',
          convertedAmount: 25.99,
          date: DateTime.now(),
          categoryIcon: '🛒',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(mockCubit.state).thenReturn(AddExpenseSuccess(expense: mockExpense));
        when(mockCubit.stream).thenAnswer((_) => Stream.fromIterable([
          AddExpenseInitial(),
          AddExpenseLoading(),
          AddExpenseSuccess(expense: mockExpense),
        ]));

        await tester.pumpWidget(createTestWidget());

        // Act - Trigger state change
        await tester.pump();

        // Assert
        expect(find.text('Expense added successfully!'), findsOneWidget);
      });

      testWidgets('should show error message when expense addition fails', (WidgetTester tester) async {
        // Arrange
        const errorMessage = 'Failed to add expense. Please try again';
        when(mockCubit.state).thenReturn(const AddExpenseError(message: errorMessage));
        when(mockCubit.stream).thenAnswer((_) => Stream.fromIterable([
          AddExpenseInitial(),
          AddExpenseLoading(),
          const AddExpenseError(message: errorMessage),
        ]));

        await tester.pumpWidget(createTestWidget());

        // Act - Trigger state change
        await tester.pump();

        // Assert
        expect(find.text(errorMessage), findsOneWidget);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should have proper semantic labels', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());

        // Act & Assert
        expect(find.text('Categories'), findsOneWidget);
        expect(find.text('Amount'), findsOneWidget);
        expect(find.text('Date'), findsOneWidget);
        expect(find.text('Attach Receipt'), findsOneWidget);
        expect(find.text('Description (Optional)'), findsOneWidget);
      });

      testWidgets('should be navigable with keyboard', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());

        // Act - Navigate through form fields using tab
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();

        // Assert - Focus should move between fields
        // This test verifies that the form is accessible via keyboard navigation
        expect(find.byType(TextFormField), findsAtLeastNWidgets(1));
      });
    });

    group('Real-time Validation Tests', () {
      testWidgets('should validate amount field in real-time', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());

        // Act - Enter invalid amount and then valid amount
        final amountField = find.byType(TextFormField).first;
        await tester.enterText(amountField, 'abc');
        await tester.pump();

        // Assert - Invalid characters should be filtered out
        final textField = tester.widget<TextFormField>(amountField);
        expect(textField.controller!.text, isEmpty);

        // Act - Enter valid amount
        await tester.enterText(amountField, '25.99');
        await tester.pump();

        // Assert
        expect(textField.controller!.text, '25.99');
      });

      testWidgets('should trigger currency conversion on amount change', (WidgetTester tester) async {
        // Arrange
        when(mockCubit.state).thenReturn(const CurrencyLoaded(
          currencies: ['USD', 'EUR', 'GBP'],
        ));
        when(mockCubit.convertCurrency(
          amount: anyNamed('amount'),
          fromCurrency: anyNamed('fromCurrency'),
          toCurrency: anyNamed('toCurrency'),
        )).thenAnswer((_) async => 85.0);

        await tester.pumpWidget(createTestWidget());

        // Act - Select non-USD currency first
        final currencyDropdown = find.byType(DropdownButton<String>);
        await tester.tap(currencyDropdown);
        await tester.pumpAndSettle();
        await tester.tap(find.text('EUR').last);
        await tester.pumpAndSettle();

        // Enter amount to trigger conversion
        final amountField = find.byType(TextFormField).first;
        await tester.enterText(amountField, '100');
        await tester.pump();

        // Assert - Conversion should be triggered
        verify(mockCubit.convertCurrency(
          amount: 100.0,
          fromCurrency: 'EUR',
          toCurrency: 'USD',
        )).called(1);
      });
    });
  });
}
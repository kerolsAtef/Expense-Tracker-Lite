import 'package:equatable/equatable.dart';
import 'package:expense_tracker/src/domain/entities/expense.dart';

abstract class AddExpenseState extends Equatable {
  const AddExpenseState();

  @override
  List<Object?> get props => [];
}

class AddExpenseInitial extends AddExpenseState {}

class AddExpenseLoading extends AddExpenseState {}

class AddExpenseSuccess extends AddExpenseState {
  final Expense expense;

  const AddExpenseSuccess({required this.expense});

  @override
  List<Object> get props => [expense];
}

class AddExpenseError extends AddExpenseState {
  final String message;

  const AddExpenseError({required this.message});

  @override
  List<Object> get props => [message];
}

class CurrencyLoading extends AddExpenseState {}

class CurrencyLoaded extends AddExpenseState {
  final List<String> currencies;

  const CurrencyLoaded({required this.currencies});

  @override
  List<Object> get props => [currencies];
}
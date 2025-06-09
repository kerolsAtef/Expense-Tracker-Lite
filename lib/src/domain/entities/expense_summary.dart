import 'package:equatable/equatable.dart';

class ExpenseSummary extends Equatable {
  final double totalBalance;
  final double totalIncome;
  final double totalExpenses;
  final List<CategorySummary> categoryBreakdown;
  final String currency;

  const ExpenseSummary({
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpenses,
    required this.categoryBreakdown,
    required this.currency,
  });

  @override
  List<Object> get props => [
    totalBalance,
    totalIncome,
    totalExpenses,
    categoryBreakdown,
    currency,
  ];
}

class CategorySummary extends Equatable {
  final String category;
  final double amount;
  final String categoryIcon;
  final int count;

  const CategorySummary({
    required this.category,
    required this.amount,
    required this.categoryIcon,
    required this.count,
  });

  @override
  List<Object> get props => [category, amount, categoryIcon, count];
}

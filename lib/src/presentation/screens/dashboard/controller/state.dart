import 'package:equatable/equatable.dart';
import 'package:expense_tracker/src/domain/entities/expense.dart';
import 'package:expense_tracker/src/domain/entities/expense_filter.dart';
import 'package:expense_tracker/src/domain/entities/expense_summary.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final ExpenseSummary summary;
  final List<Expense> recentExpenses;
  final ExpenseFilter currentFilter;
  final bool hasMoreExpenses;
  final int currentPage;

  const DashboardLoaded({
    required this.summary,
    required this.recentExpenses,
    required this.currentFilter,
    required this.hasMoreExpenses,
    required this.currentPage,
  });

  DashboardLoaded copyWith({
    ExpenseSummary? summary,
    List<Expense>? recentExpenses,
    ExpenseFilter? currentFilter,
    bool? hasMoreExpenses,
    int? currentPage,
  }) {
    return DashboardLoaded(
      summary: summary ?? this.summary,
      recentExpenses: recentExpenses ?? this.recentExpenses,
      currentFilter: currentFilter ?? this.currentFilter,
      hasMoreExpenses: hasMoreExpenses ?? this.hasMoreExpenses,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object> get props => [
        summary,
        recentExpenses,
        currentFilter,
        hasMoreExpenses,
        currentPage,
      ];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object> get props => [message];
}

class DashboardLoadingMore extends DashboardLoaded {
  const DashboardLoadingMore({
    required ExpenseSummary summary,
    required List<Expense> recentExpenses,
    required ExpenseFilter currentFilter,
    required bool hasMoreExpenses,
    required int currentPage,
  }) : super(
          summary: summary,
          recentExpenses: recentExpenses,
          currentFilter: currentFilter,
          hasMoreExpenses: hasMoreExpenses,
          currentPage: currentPage,
        );
}

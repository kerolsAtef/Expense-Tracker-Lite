import 'package:expense_tracker/src/domain/entities/expense_filter.dart';
import 'package:expense_tracker/src/domain/usecases/expense/get_expense_summary_usecase.dart';
import 'package:expense_tracker/src/domain/usecases/expense/get_expenses_usecase.dart';
import 'package:expense_tracker/src/domain/usecases/expense/get_total_expense_count_usecase.dart';
import 'package:expense_tracker/src/presentation/screens/dashboard/controller/state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class DashboardCubit extends Cubit<DashboardState> {
  final GetExpensesUseCase getExpensesUseCase;
  final GetExpenseSummaryUseCase getExpenseSummaryUseCase;
  final GetTotalExpenseCountUseCase getTotalExpenseCountUseCase;

  static const int _pageSize = 10;

  DashboardCubit({
    required this.getExpensesUseCase,
    required this.getExpenseSummaryUseCase,
    required this.getTotalExpenseCountUseCase,
  }) : super(DashboardInitial());

  // Load dashboard data with filter
  Future<void> loadDashboard({
    ExpenseFilter? filter,
    bool refresh = false,
  }) async {
    if (refresh || state is DashboardInitial) {
      emit(DashboardLoading());
    }

    final currentFilter = filter ?? const ExpenseFilter(type: FilterType.thisMonth);

    try {
      // Get summary
      final summaryResult = await getExpenseSummaryUseCase(
        GetExpenseSummaryParams(filter: currentFilter),
      );

      // Get recent expenses (first page)
      final expensesResult = await getExpensesUseCase(
        GetExpensesParams(
          filter: currentFilter,
          page: 1,
          limit: _pageSize,
        ),
      );

      // Get total count to determine if there are more expenses
      final totalCountResult = await getTotalExpenseCountUseCase(
        GetTotalExpenseCountParams(filter: currentFilter),
      );

      // Combine results
      final summary = summaryResult.fold(
        (failure) => throw Exception(failure.message),
        (summary) => summary,
      );

      final expenses = expensesResult.fold(
        (failure) => throw Exception(failure.message),
        (expenses) => expenses,
      );

      final totalCount = totalCountResult.fold(
        (failure) => throw Exception(failure.message),
        (count) => count,
      );

      final hasMoreExpenses = totalCount > _pageSize;

      emit(DashboardLoaded(
        summary: summary,
        recentExpenses: expenses,
        currentFilter: currentFilter,
        hasMoreExpenses: hasMoreExpenses,
        currentPage: 1,
      ));
    } catch (e) {
      emit(DashboardError(message: _mapErrorToMessage(e.toString())));
    }
  }

  // Load more expenses (pagination)
  Future<void> loadMoreExpenses() async {
    final currentState = state;
    if (currentState is! DashboardLoaded || !currentState.hasMoreExpenses) {
      return;
    }

    emit(DashboardLoadingMore(
      summary: currentState.summary,
      recentExpenses: currentState.recentExpenses,
      currentFilter: currentState.currentFilter,
      hasMoreExpenses: currentState.hasMoreExpenses,
      currentPage: currentState.currentPage,
    ));

    try {
      final nextPage = currentState.currentPage + 1;
      
      final expensesResult = await getExpensesUseCase(
        GetExpensesParams(
          filter: currentState.currentFilter,
          page: nextPage,
          limit: _pageSize,
        ),
      );

      final newExpenses = expensesResult.fold(
        (failure) => throw Exception(failure.message),
        (expenses) => expenses,
      );

      final allExpenses = [...currentState.recentExpenses, ...newExpenses];
      final hasMoreExpenses = newExpenses.length == _pageSize;

      emit(currentState.copyWith(
        recentExpenses: allExpenses,
        hasMoreExpenses: hasMoreExpenses,
        currentPage: nextPage,
      ));
    } catch (e) {
      emit(DashboardError(message: _mapErrorToMessage(e.toString())));
    }
  }

  // Apply filter
  Future<void> applyFilter(ExpenseFilter filter) async {
    await loadDashboard(filter: filter, refresh: true);
  }

  // Refresh dashboard
  Future<void> refresh() async {
    final currentState = state;
    final currentFilter = currentState is DashboardLoaded
        ? currentState.currentFilter
        : const ExpenseFilter(type: FilterType.thisMonth);
    
    await loadDashboard(filter: currentFilter, refresh: true);
  }

  // Get expenses for specific filter without changing dashboard state
  Future<void> getFilteredExpenses(ExpenseFilter filter) async {
    try {
      final expensesResult = await getExpensesUseCase(
        GetExpensesParams(
          filter: filter,
          page: 1,
          limit: _pageSize,
        ),
      );

      final summaryResult = await getExpenseSummaryUseCase(
        GetExpenseSummaryParams(filter: filter),
      );

      final totalCountResult = await getTotalExpenseCountUseCase(
        GetTotalExpenseCountParams(filter: filter),
      );

      final summary = summaryResult.fold(
        (failure) => throw Exception(failure.message),
        (summary) => summary,
      );

      final expenses = expensesResult.fold(
        (failure) => throw Exception(failure.message),
        (expenses) => expenses,
      );

      final totalCount = totalCountResult.fold(
        (failure) => throw Exception(failure.message),
        (count) => count,
      );

      final hasMoreExpenses = totalCount > _pageSize;

      emit(DashboardLoaded(
        summary: summary,
        recentExpenses: expenses,
        currentFilter: filter,
        hasMoreExpenses: hasMoreExpenses,
        currentPage: 1,
      ));
    } catch (e) {
      emit(DashboardError(message: _mapErrorToMessage(e.toString())));
    }
  }

  String _mapErrorToMessage(String error) {
    if (error.contains('User not authenticated')) {
      return 'Please login to view your expenses';
    } else if (error.contains('Network')) {
      return 'Network error. Please check your connection';
    } else if (error.contains('Cache')) {
      return 'Storage error occurred';
    } else {
      return 'An unexpected error occurred';
    }
  }
}

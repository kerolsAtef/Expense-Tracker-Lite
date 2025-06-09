
import 'package:equatable/equatable.dart';

enum FilterType {
  thisMonth,
  lastWeek,
  last30Days,
  last90Days,
  thisYear,
  custom,
  all,
}

class ExpenseFilter extends Equatable {
  final FilterType type;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? categories;
  final double? minAmount;
  final double? maxAmount;

  const ExpenseFilter({
    required this.type,
    this.startDate,
    this.endDate,
    this.categories,
    this.minAmount,
    this.maxAmount,
  });

  ExpenseFilter copyWith({
    FilterType? type,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? categories,
    double? minAmount,
    double? maxAmount,
  }) {
    return ExpenseFilter(
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      categories: categories ?? this.categories,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
    );
  }

  @override
  List<Object?> get props => [
    type,
    startDate,
    endDate,
    categories,
    minAmount,
    maxAmount,
  ];
}
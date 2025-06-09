// lib/presentation/screens/dashboard/widgets/filter_tabs.dart
import 'package:flutter/material.dart';
import '../../../../domain/entities/expense_filter.dart';

class FilterTabs extends StatelessWidget {
  final ExpenseFilter? currentFilter;
  final Function(ExpenseFilter) onFilterChanged;

  const FilterTabs({
    Key? key,
    required this.currentFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filters = [
      FilterOption(
        type: FilterType.thisMonth,
        label: 'This Month',
      ),
      FilterOption(
        type: FilterType.lastWeek,
        label: 'Last 7 Days',
      ),
      FilterOption(
        type: FilterType.last30Days,
        label: 'Last 30 Days',
      ),
      FilterOption(
        type: FilterType.last90Days,
        label: 'Last 3 Months',
      ),
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = currentFilter?.type == filter.type;
          
          return Padding(
            padding: EdgeInsets.only(
              right: index < filters.length - 1 ? 12 : 0,
            ),
            child: GestureDetector(
              onTap: () => onFilterChanged(ExpenseFilter(type: filter.type)),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? const Color(0xFF6C5CE7) 
                      : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected 
                        ? const Color(0xFF6C5CE7) 
                        : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: const Color(0xFF6C5CE7).withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ] : null,
                ),
                child: Text(
                  filter.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF718096),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FilterOption {
  final FilterType type;
  final String label;

  FilterOption({
    required this.type,
    required this.label,
  });
}

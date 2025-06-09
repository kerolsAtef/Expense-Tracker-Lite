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
        icon: Icons.calendar_month,
      ),
      FilterOption(
        type: FilterType.lastWeek,
        label: 'Last Week',
        icon: Icons.calendar_view_week,
      ),
      FilterOption(
        type: FilterType.last30Days,
        label: 'Last 30 Days',
        icon: Icons.date_range,
      ),
      FilterOption(
        type: FilterType.last90Days,
        label: 'Last 3 Months',
        icon: Icons.calendar_view_month,
      ),
      FilterOption(
        type: FilterType.all,
        label: 'All Time',
        icon: Icons.all_inclusive,
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter by Period',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
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
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
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
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: const Color(0xFF6C5CE7).withOpacity(0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ] : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            filter.icon,
                            size: 16,
                            color: isSelected ? Colors.white : const Color(0xFF718096),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            filter.label,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF718096),
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FilterOption {
  final FilterType type;
  final String label;
  final IconData icon;

  FilterOption({
    required this.type,
    required this.label,
    required this.icon,
  });
}

// lib/presentation/screens/dashboard/widgets/recent_expenses_header.dart
class RecentExpensesHeader extends StatelessWidget {
  final VoidCallback? onSeeAll;

  const RecentExpensesHeader({
    Key? key,
    this.onSeeAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Color(0xFF6C5CE7),
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Recent Expenses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'See all',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6C5CE7),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
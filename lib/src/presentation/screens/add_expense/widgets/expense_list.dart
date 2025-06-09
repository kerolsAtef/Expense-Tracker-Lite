import 'package:expense_tracker/src/core/constants/ategory_constants.dart';
import 'package:flutter/material.dart';
import '../../../../domain/entities/expense.dart';
import '../../../../core/constants/currency_constants.dart';
import '../../../../core/utils/date_utils.dart';

class ExpenseList extends StatelessWidget {
  final List<Expense> expenses;
  final bool isLoadingMore;
  final bool hasMoreExpenses;

  const ExpenseList({
    Key? key,
    required this.expenses,
    required this.isLoadingMore,
    required this.hasMoreExpenses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // Show loading indicator at the end if loading more
          if (index == expenses.length) {
            return isLoadingMore
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : hasMoreExpenses
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            'Scroll to load more',
                            style: TextStyle(
                              color: Color(0xFF718096),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    : const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            'No more expenses',
                            style: TextStyle(
                              color: Color(0xFF718096),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
          }

          final expense = expenses[index];
          return ExpenseItem(expense: expense);
        },
        childCount: expenses.length + 1,
      ),
    );
  }
}

class ExpenseItem extends StatelessWidget {
  final Expense expense;

  const ExpenseItem({
    Key? key,
    required this.expense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // Category Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getCategoryColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                expense.categoryIcon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Expense Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      expense.category.substring(0, 1).toUpperCase() + 
                      expense.category.substring(1),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '-${CurrencyConstants.formatCurrency(expense.amount, expense.currency)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF56565),
                          ),
                        ),
                        if (expense.currency != 'USD')
                          Text(
                            'USD ${expense.convertedAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF718096),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (expense.description != null && expense.description!.isNotEmpty)
                      Expanded(
                        child: Text(
                          expense.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF718096),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    else
                      const Expanded(child: SizedBox()),
                    
                    Row(
                      children: [
                        if (expense.receiptPath != null)
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(
                              Icons.attach_file,
                              size: 14,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        Text(
                          AppDateUtils.formatDate(expense.date),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF718096),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor() {
    final colorString = CategoryConstants.getCategoryColor(expense.category);
    final colorValue = int.parse(colorString.substring(2), radix: 16);
    return Color(colorValue);
  }
}


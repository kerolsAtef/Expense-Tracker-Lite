import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  final String id;
  final String userId;
  final String category;
  final double amount;
  final String currency;
  final double convertedAmount; // Amount in USD
  final DateTime date;
  final String? description;
  final String? receiptPath;
  final String categoryIcon;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Expense({
    required this.id,
    required this.userId,
    required this.category,
    required this.amount,
    required this.currency,
    required this.convertedAmount,
    required this.date,
    this.description,
    this.receiptPath,
    required this.categoryIcon,
    required this.createdAt,
    required this.updatedAt,
  });

  Expense copyWith({
    String? id,
    String? userId,
    String? category,
    double? amount,
    String? currency,
    double? convertedAmount,
    DateTime? date,
    String? description,
    String? receiptPath,
    String? categoryIcon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      convertedAmount: convertedAmount ?? this.convertedAmount,
      date: date ?? this.date,
      description: description ?? this.description,
      receiptPath: receiptPath ?? this.receiptPath,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    category,
    amount,
    currency,
    convertedAmount,
    date,
    description,
    receiptPath,
    categoryIcon,
    createdAt,
    updatedAt,
  ];
}

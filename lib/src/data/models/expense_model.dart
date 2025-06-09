import 'package:hive/hive.dart';
import '../../domain/entities/expense.dart';

@HiveType(typeId: 1)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final String currency;

  @HiveField(5)
  final double convertedAmount;

  @HiveField(6)
  final DateTime date;

  @HiveField(7)
  final String? description;

  @HiveField(8)
  final String? receiptPath;

  @HiveField(9)
  final String categoryIcon;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime updatedAt;

  ExpenseModel({
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

  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      userId: expense.userId,
      category: expense.category,
      amount: expense.amount,
      currency: expense.currency,
      convertedAmount: expense.convertedAmount,
      date: expense.date,
      description: expense.description,
      receiptPath: expense.receiptPath,
      categoryIcon: expense.categoryIcon,
      createdAt: expense.createdAt,
      updatedAt: expense.updatedAt,
    );
  }

  Expense toEntity() {
    return Expense(
      id: id,
      userId: userId,
      category: category,
      amount: amount,
      currency: currency,
      convertedAmount: convertedAmount,
      date: date,
      description: description,
      receiptPath: receiptPath,
      categoryIcon: categoryIcon,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      userId: json['userId'],
      category: json['category'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      convertedAmount: json['convertedAmount'].toDouble(),
      date: DateTime.parse(json['date']),
      description: json['description'],
      receiptPath: json['receiptPath'],
      categoryIcon: json['categoryIcon'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'category': category,
      'amount': amount,
      'currency': currency,
      'convertedAmount': convertedAmount,
      'date': date.toIso8601String(),
      'description': description,
      'receiptPath': receiptPath,
      'categoryIcon': categoryIcon,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ExpenseModel copyWith({
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
    return ExpenseModel(
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
}

// Manual Hive Adapter for ExpenseModel
class ExpenseModelAdapter extends TypeAdapter<ExpenseModel> {
  @override
  final int typeId = 1;

  @override
  ExpenseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      category: fields[2] as String,
      amount: fields[3] as double,
      currency: fields[4] as String,
      convertedAmount: fields[5] as double,
      date: fields[6] as DateTime,
      description: fields[7] as String?,
      receiptPath: fields[8] as String?,
      categoryIcon: fields[9] as String,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.currency)
      ..writeByte(5)
      ..write(obj.convertedAmount)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.receiptPath)
      ..writeByte(9)
      ..write(obj.categoryIcon)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
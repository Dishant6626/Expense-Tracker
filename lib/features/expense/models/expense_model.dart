// lib/features/expense/models/expense_model.dart

import 'package:hive/hive.dart';
import '../../../core/constants/app_constants.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 0)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String categoryStr;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String? note;

  @HiveField(6)
  final String? receiptImagePath;

  @HiveField(7)
  final String? merchantName;

  @HiveField(8)
  final bool isAiExtracted;

  @HiveField(9)
  final DateTime createdAt;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryStr,
    required this.date,
    this.note,
    this.receiptImagePath,
    this.merchantName,
    this.isAiExtracted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  ExpenseCategory get category => ExpenseCategory.fromString(categoryStr);

  ExpenseModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? categoryStr,
    DateTime? date,
    String? note,
    String? receiptImagePath,
    String? merchantName,
    bool? isAiExtracted,
    DateTime? createdAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryStr: categoryStr ?? this.categoryStr,
      date: date ?? this.date,
      note: note ?? this.note,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      merchantName: merchantName ?? this.merchantName,
      isAiExtracted: isAiExtracted ?? this.isAiExtracted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'category': categoryStr,
        'date': date.toIso8601String(),
        'note': note,
        'receiptImagePath': receiptImagePath,
        'merchantName': merchantName,
        'isAiExtracted': isAiExtracted,
        'createdAt': createdAt.toIso8601String(),
      };
}

// Extracted receipt data model (not persisted)
class ExtractedReceiptData {
  final String? merchantName;
  final DateTime? date;
  final double? amount;
  final ExpenseCategory? category;
  final String? rawResponse;
  final bool isValid;
  final String? errorMessage;

  const ExtractedReceiptData({
    this.merchantName,
    this.date,
    this.amount,
    this.category,
    this.rawResponse,
    this.isValid = false,
    this.errorMessage,
  });

  factory ExtractedReceiptData.invalid(String error) => ExtractedReceiptData(
        isValid: false,
        errorMessage: error,
      );
}

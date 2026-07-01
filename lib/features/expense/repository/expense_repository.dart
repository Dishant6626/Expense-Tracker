// lib/features/expense/repository/expense_repository.dart

import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/hive_storage_service.dart';
import '../models/expense_model.dart';

class ExpenseRepository {
  const ExpenseRepository();

  final _uuid = const Uuid();

  // ── CRUD ────────────────────────────────────────────────────────────────────

  Future<List<ExpenseModel>> getAllExpenses() async {
    final box = HiveStorageService().expenseBox;
    final expenses = box.values.toList();
    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  Future<ExpenseModel> addExpense(ExpenseModel expense) async {
    final box = HiveStorageService().expenseBox;
    final newExpense = expense.copyWith(id: _uuid.v4());
    await box.put(newExpense.id, newExpense);
    return newExpense;
  }

  Future<ExpenseModel> updateExpense(ExpenseModel expense) async {
    final box = HiveStorageService().expenseBox;
    await box.put(expense.id, expense);
    return expense;
  }

  Future<void> deleteExpense(String id) async {
    final box = HiveStorageService().expenseBox;
    await box.delete(id);
  }

  Future<ExpenseModel?> getExpenseById(String id) async {
    final box = HiveStorageService().expenseBox;
    return box.get(id);
  }

  // ── Filters ─────────────────────────────────────────────────────────────────

  Future<List<ExpenseModel>> getExpensesByCategory(ExpenseCategory category) async {
    final all = await getAllExpenses();
    return all.where((e) => e.category == category).toList();
  }

  Future<List<ExpenseModel>> getExpensesByDateRange(
    DateTime from,
    DateTime to,
  ) async {
    final all = await getAllExpenses();
    return all.where((e) => e.date.isAfter(from) && e.date.isBefore(to)).toList();
  }

  Future<List<ExpenseModel>> getThisMonthExpenses() async {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, 1);
    final to = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return getExpensesByDateRange(from, to);
  }

  // ── Stats ───────────────────────────────────────────────────────────────────

  Future<double> getTotalAmount() async {
    final all = await getAllExpenses();
    return all.fold<double>(0, (sum, e) => sum + e.amount);
  }

  Future<Map<ExpenseCategory, double>> getCategoryTotals() async {
    final all = await getAllExpenses();
    final map = <ExpenseCategory, double>{};
    for (final e in all) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }
}

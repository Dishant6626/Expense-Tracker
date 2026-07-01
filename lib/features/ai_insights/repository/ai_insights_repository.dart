// lib/features/ai_insights/repository/ai_insights_repository.dart

import '../../../core/constants/app_constants.dart';
import '../../../core/services/gemini_service.dart';
import '../../../core/services/hive_storage_service.dart';
import '../../expense/models/expense_model.dart';
import '../../expense/repository/expense_repository.dart';

class AiInsightsRepository {
  const AiInsightsRepository();

  static const String _insightKey = 'latest_insight';
  static const String _insightDateKey = 'insight_date';

  Future<String> generateInsights() async {
    final expenses = await ExpenseRepository().getAllExpenses();
    final insight = await GeminiService().generateSpendingInsights(expenses);

    // Cache result
    final box = HiveStorageService().insightsBox;
    await box.put(_insightKey, insight);
    await box.put(_insightDateKey, DateTime.now().toIso8601String());

    return insight;
  }

  Future<String?> getCachedInsight() async {
    final box = HiveStorageService().insightsBox;
    return box.get(_insightKey);
  }

  Future<DateTime?> getLastInsightDate() async {
    final box = HiveStorageService().insightsBox;
    final dateStr = box.get(_insightDateKey);
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }

  Future<ExtractedReceiptData> scanReceipt(dynamic imageFile) async {
    return GeminiService().scanReceipt(imageFile);
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final all = await ExpenseRepository().getAllExpenses();
    final thisMonth = await ExpenseRepository().getThisMonthExpenses();
    final categoryTotals = await ExpenseRepository().getCategoryTotals();

    return {
      'total': all.fold<double>(0, (s, e) => s + e.amount),
      'thisMonth': thisMonth.fold<double>(0, (s, e) => s + e.amount),
      'count': all.length,
      'categoryTotals': categoryTotals,
      'recentExpenses': all.take(5).toList(),
    };
  }
}

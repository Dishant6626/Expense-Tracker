// lib/core/constants/app_constants.dart

abstract class AppConstants {
  static const String appName = 'ExpenseAI';
  static const String hiveExpenseBox = 'expenses_box';
  static const String hiveInsightsBox = 'insights_box';
  static const String hiveSettingsBox = 'settings_box';
}

abstract class StorageKeys {
  static const String lastInsightDate = 'last_insight_date';
  static const String totalExpenses = 'total_expenses';
}

enum ExpenseCategory {
  food,
  shopping,
  travel,
  utilities,
  entertainment,
  others;

  String get label {
    switch (this) {
      case food: return 'Food';
      case shopping: return 'Shopping';
      case travel: return 'Travel';
      case utilities: return 'Utilities';
      case entertainment: return 'Entertainment';
      case others: return 'Others';
    }
  }

  String get emoji {
    switch (this) {
      case food: return '🍔';
      case shopping: return '🛍️';
      case travel: return '✈️';
      case utilities: return '⚡';
      case entertainment: return '🎬';
      case others: return '📦';
    }
  }

  static ExpenseCategory fromString(String value) {
    return ExpenseCategory.values.firstWhere(
      (e) => e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => ExpenseCategory.others,
    );
  }
}

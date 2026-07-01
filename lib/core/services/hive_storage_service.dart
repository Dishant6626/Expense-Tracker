// lib/core/services/hive_storage_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import '../../features/expense/models/expense_model.dart';
import '../constants/app_constants.dart';

class HiveStorageService {
  static final HiveStorageService _instance = HiveStorageService._internal();
  factory HiveStorageService() => _instance;
  HiveStorageService._internal();

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ExpenseModelAdapter());
    await Hive.openBox<ExpenseModel>(AppConstants.hiveExpenseBox);
    await Hive.openBox<String>(AppConstants.hiveInsightsBox);
    await Hive.openBox(AppConstants.hiveSettingsBox);
  }

  Box<ExpenseModel> get expenseBox =>
      Hive.box<ExpenseModel>(AppConstants.hiveExpenseBox);

  Box<String> get insightsBox =>
      Hive.box<String>(AppConstants.hiveInsightsBox);

  Box get settingsBox => Hive.box(AppConstants.hiveSettingsBox);
}

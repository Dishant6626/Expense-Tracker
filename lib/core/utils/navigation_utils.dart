// lib/core/utils/navigation_utils.dart

import 'package:flutter/material.dart';

import '../../config/routes/app_routes.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/expense/screens/add_edit_expense_screen.dart';
import '../../features/expense/screens/expense_detail_screen.dart';
import '../../features/ai_insights/screens/ai_insights_screen.dart';
import '../../features/expense/models/expense_model.dart';
import '../../features/splash/screens/splash_screen.dart';

class NavigationUtils {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return _buildRoute(const SplashScreen(), settings);

      case RouteNames.dashboard:
        return _buildRoute(const DashboardScreen(), settings);

      case RouteNames.addExpense:
        return _buildRoute(const AddEditExpenseScreen(), settings);

      case RouteNames.editExpense:
        final expense = settings.arguments as ExpenseModel?;
        return _buildRoute(AddEditExpenseScreen(expense: expense), settings);

      case RouteNames.expenseDetail:
        final expense = settings.arguments as ExpenseModel;
        return _buildRoute(ExpenseDetailScreen(expense: expense), settings);

      case RouteNames.aiInsights:
        return _buildRoute(const AiInsightsScreen(), settings);

      default:
        return _buildRoute(const DashboardScreen(), settings);
    }
  }

  static MaterialPageRoute _buildRoute(Widget widget, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => widget, settings: settings);
  }
}

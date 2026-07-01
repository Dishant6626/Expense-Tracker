// lib/features/dashboard/bloc/dashboard_state.dart

import 'package:built_value/built_value.dart';
import 'package:built_collection/built_collection.dart';

import '../../../core/base/base_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../expense/models/expense_model.dart';

part 'dashboard_state.g.dart';

abstract class DashboardState
    implements Built<DashboardState, DashboardStateBuilder> {
  factory DashboardState([void Function(DashboardStateBuilder) updates]) =
      _$DashboardState;

  DashboardState._();

  ScreenState get state;

  @BuiltValueField(wireName: 'expenses')
  BuiltList<ExpenseModel> get expenses;

  double get totalAmount;
  double get thisMonthAmount;

  @BuiltValueField(wireName: 'categoryTotals')
  BuiltMap<String, double> get categoryTotals;

  String? get errorMessage;
  String? get selectedCategoryFilter;
  bool get isDeleting;
}

// ── Events ──────────────────────────────────────────────────────────────────

abstract class DashboardEvent {}

class LoadDashboardEvent extends DashboardEvent {}

class DeleteExpenseEvent extends DashboardEvent {
  final String expenseId;
  DeleteExpenseEvent(this.expenseId);
}

class FilterByCategoryEvent extends DashboardEvent {
  final String? category;
  FilterByCategoryEvent(this.category);
}

class RefreshDashboardEvent extends DashboardEvent {}

class UpdateDashboardState extends DashboardEvent {
  final DashboardState state;
  UpdateDashboardState(this.state);
}

// ── Navigation targets ──────────────────────────────────────────────────────

abstract class DashboardTarget {
  static const String addExpense = 'add_expense';
  static const String editExpense = 'edit_expense';
  static const String expenseDetail = 'expense_detail';
  static const String aiInsights = 'ai_insights';
}

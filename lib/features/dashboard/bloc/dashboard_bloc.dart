// lib/features/dashboard/bloc/dashboard_bloc.dart

import 'package:built_collection/built_collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/base/base_bloc.dart';
import '../../../core/base/event_bus.dart';
import '../../ai_insights/repository/ai_insights_repository.dart';
import '../../expense/models/expense_model.dart';
import '../../expense/repository/expense_repository.dart';
import 'dashboard_state.dart';

class DashboardBloc extends BaseBloc<DashboardEvent, DashboardState> {
  DashboardBloc(this._expenseRepo, this._insightsRepo, this._eventBus)
      : super(initState) {
    on<LoadDashboardEvent>(_onLoad);
    on<DeleteExpenseEvent>(_onDelete);
    on<FilterByCategoryEvent>(_onFilter);
    on<RefreshDashboardEvent>(_onRefresh);
    on<UpdateDashboardState>((event, emit) => emit(event.state));

    _eventBus.events.listen(_onBusEvent).bindToLifecycle(this);
  }

  final ExpenseRepository _expenseRepo;
  final AiInsightsRepository _insightsRepo;
  final EventBus _eventBus;

  static DashboardState get initState => (DashboardStateBuilder()
        ..state = ScreenState.loading
        ..expenses = ListBuilder()
        ..categoryTotals = MapBuilder()
        ..totalAmount = 0.0
        ..thisMonthAmount = 0.0
        ..isDeleting = false)
      .build();

  Future<void> _onLoad(
    LoadDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.rebuild((b) => b..state = ScreenState.loading));
    await _loadData(emit);
  }

  Future<void> _onRefresh(
    RefreshDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<DashboardState> emit) async {
    try {
      final stats = await _insightsRepo.getDashboardStats();

      // Fix: key is now 'allExpenses' (full list) not 'recentExpenses'
      final expenses = stats['allExpenses'] as List<ExpenseModel>;

      // Fix: categoryTotals is already Map<String, double> from the repo
      final categoryTotals = stats['categoryTotals'] as Map<String, double>;

      emit(state.rebuild((b) => b
        ..state = expenses.isEmpty ? ScreenState.empty : ScreenState.content
        ..expenses = ListBuilder(expenses)
        ..totalAmount = stats['total'] as double
        ..thisMonthAmount = stats['thisMonth'] as double
        ..categoryTotals = MapBuilder(categoryTotals)
        ..errorMessage = null));
    } catch (e) {
      emit(state.rebuild((b) => b
        ..state = ScreenState.error
        ..errorMessage = e.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteExpenseEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.rebuild((b) => b..isDeleting = true));
    try {
      await _expenseRepo.deleteExpense(event.expenseId);
      _eventBus.sendEvent(ExpenseDeletedEvent(expenseId: event.expenseId));
      dispatchViewEvent(
          DisplayMessage(message: 'Expense deleted successfully'));
      await _loadData(emit);
    } catch (e) {
      dispatchViewEvent(DisplayMessage(message: 'Failed to delete expense'));
      emit(state.rebuild((b) => b..isDeleting = false));
    }
  }

  void _onFilter(FilterByCategoryEvent event, Emitter<DashboardState> emit) {
    emit(state.rebuild((b) => b..selectedCategoryFilter = event.category));
  }

  void _onBusEvent(BusEvent event) {
    switch (event.runtimeType) {
      case const (ExpenseAddedEvent):
      case const (ExpenseUpdatedEvent):
      case const (ExpenseDeletedEvent):
        add(RefreshDashboardEvent());
        break;
    }
  }

  List<ExpenseModel> get filteredExpenses {
    if (state.selectedCategoryFilter == null) return state.expenses.toList();
    return state.expenses
        .where((e) => e.category.label == state.selectedCategoryFilter)
        .toList();
  }
}

// lib/features/expense/bloc/expense_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../core/base/base_bloc.dart';
import '../../../core/base/event_bus.dart';
import '../../../core/constants/app_constants.dart';
import '../models/expense_model.dart';
import '../repository/expense_repository.dart';
import '../../ai_insights/repository/ai_insights_repository.dart';
import 'expense_state.dart';

class ExpenseBloc extends BaseBloc<ExpenseEvent, ExpenseState> {
  ExpenseBloc(this._repo, this._insightsRepo, this._eventBus)
      : super(initState) {
    on<InitExpenseEvent>(_onInit);
    on<UpdateTitleEvent>((e, emit) => emit(state.rebuild((b) => b..title = e.title)));
    on<UpdateAmountEvent>((e, emit) => emit(state.rebuild((b) => b..amount = e.amount)));
    on<UpdateCategoryEvent>((e, emit) => emit(state.rebuild((b) => b..category = e.category)));
    on<UpdateNoteEvent>((e, emit) => emit(state.rebuild((b) => b..note = e.note)));
    on<UpdateDateEvent>((e, emit) => emit(state.rebuild((b) => b..date = e.date)));
    on<ScanReceiptEvent>(_onScanReceipt);
    on<ApplyExtractedDataEvent>(_onApplyExtracted);
    on<SaveExpenseEvent>(_onSave);
    on<UpdateExpenseScreenState>((event, emit) => emit(event.state));
  }

  final ExpenseRepository _repo;
  final AiInsightsRepository _insightsRepo;
  final EventBus _eventBus;
  ExpenseModel? _existingExpense;

  static ExpenseState get initState => (ExpenseStateBuilder()
        ..state = ScreenState.content
        ..title = ''
        ..amount = ''
        ..category = ExpenseCategory.others.label
        ..note = ''
        ..date = _todayStr()
        ..isScanning = false
        ..isScanComplete = false
        ..isSaving = false
        ..isEditMode = false)
      .build();

  static String _todayStr() =>
      DateTime.now().toIso8601String().split('T')[0];

  void _onInit(InitExpenseEvent event, Emitter<ExpenseState> emit) {
    final exp = event.existingExpense;
    _existingExpense = exp;
    if (exp != null) {
      emit(state.rebuild((b) => b
        ..isEditMode = true
        ..title = exp.title
        ..amount = exp.amount.toStringAsFixed(2)
        ..category = exp.category.label
        ..note = exp.note ?? ''
        ..date = exp.date.toIso8601String().split('T')[0]));
    }
  }

  Future<void> _onScanReceipt(ScanReceiptEvent event, Emitter<ExpenseState> emit) async {
    emit(state.rebuild((b) => b
      ..isScanning = true
      ..isScanComplete = false
      ..scanError = null
      ..extractedData = null));

    final result = await _insightsRepo.scanReceipt(event.imageFile);

    emit(state.rebuild((b) => b
      ..isScanning = false
      ..isScanComplete = true
      ..extractedData = result
      ..scanError = result.isValid ? null : result.errorMessage));
  }

  void _onApplyExtracted(ApplyExtractedDataEvent event, Emitter<ExpenseState> emit) {
    final data = state.extractedData;
    if (data == null || !data.isValid) return;

    emit(state.rebuild((b) => b
      ..title = data.merchantName ?? state.title
      ..amount = data.amount?.toStringAsFixed(2) ?? state.amount
      ..category = data.category?.label ?? state.category
      ..date = data.date?.toIso8601String().split('T')[0] ?? state.date
      ..isScanComplete = false
      ..extractedData = null));
  }

  Future<void> _onSave(SaveExpenseEvent event, Emitter<ExpenseState> emit) async {
    // Validation
    if (state.title.trim().isEmpty) {
      dispatchViewEvent(DisplayMessage(message: 'Please enter a title'));
      return;
    }
    final parsedAmount = double.tryParse(state.amount);
    if (parsedAmount == null || parsedAmount <= 0) {
      dispatchViewEvent(DisplayMessage(message: 'Please enter a valid amount'));
      return;
    }

    emit(state.rebuild((b) => b..isSaving = true));

    try {
      final parsedDate = DateTime.tryParse(state.date) ?? DateTime.now();
      final isAi = state.extractedData != null;

      if (state.isEditMode && _existingExpense != null) {
        final updated = _existingExpense!.copyWith(
          title: state.title.trim(),
          amount: parsedAmount,
          categoryStr: state.category,
          date: parsedDate,
          note: state.note.trim().isEmpty ? null : state.note.trim(),
          isAiExtracted: _existingExpense!.isAiExtracted || isAi,
        );
        await _repo.updateExpense(updated);
        _eventBus.sendEvent(ExpenseUpdatedEvent(expenseId: updated.id));
        dispatchViewEvent(DisplayMessage(message: 'Expense updated!'));
      } else {
        final newExpense = ExpenseModel(
          id: const Uuid().v4(),
          title: state.title.trim(),
          amount: parsedAmount,
          categoryStr: state.category,
          date: parsedDate,
          note: state.note.trim().isEmpty ? null : state.note.trim(),
          isAiExtracted: isAi,
        );
        await _repo.addExpense(newExpense);
        _eventBus.sendEvent(ExpenseAddedEvent(expenseId: newExpense.id));
        dispatchViewEvent(DisplayMessage(message: 'Expense saved!'));
      }

      emit(state.rebuild((b) => b..isSaving = false));
      dispatchViewEvent(CloseScreen());
    } catch (e) {
      emit(state.rebuild((b) => b..isSaving = false));
      dispatchViewEvent(DisplayMessage(message: 'Failed to save: ${e.toString()}'));
    }
  }
}

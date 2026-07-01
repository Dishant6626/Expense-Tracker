// lib/features/expense/bloc/expense_state.dart

import 'package:built_value/built_value.dart';
import 'dart:io';

import '../../../core/base/base_bloc.dart';
import '../models/expense_model.dart';
import '../../../core/constants/app_constants.dart';

part 'expense_state.g.dart';

abstract class ExpenseState
    implements Built<ExpenseState, ExpenseStateBuilder> {
  factory ExpenseState([void Function(ExpenseStateBuilder) updates]) =
      _$ExpenseState;

  ExpenseState._();

  ScreenState get state;

  // Form fields
  String get title;
  String get amount;
  String get category;
  String get note;
  String get date;

  // AI receipt scanning
  bool get isScanning;
  bool get isScanComplete;
  String? get scanError;
  ExtractedReceiptData? get extractedData;

  // Submission
  bool get isSaving;
  bool get isEditMode;

  String? get errorMessage;
}

// ── Events ───────────────────────────────────────────────────────────────────

abstract class ExpenseEvent {}

class InitExpenseEvent extends ExpenseEvent {
  final ExpenseModel? existingExpense;
  InitExpenseEvent({this.existingExpense});
}

class UpdateTitleEvent extends ExpenseEvent {
  final String title;
  UpdateTitleEvent(this.title);
}

class UpdateAmountEvent extends ExpenseEvent {
  final String amount;
  UpdateAmountEvent(this.amount);
}

class UpdateCategoryEvent extends ExpenseEvent {
  final String category;
  UpdateCategoryEvent(this.category);
}

class UpdateNoteEvent extends ExpenseEvent {
  final String note;
  UpdateNoteEvent(this.note);
}

class UpdateDateEvent extends ExpenseEvent {
  final String date;
  UpdateDateEvent(this.date);
}

class ScanReceiptEvent extends ExpenseEvent {
  final File imageFile;
  ScanReceiptEvent(this.imageFile);
}

class ApplyExtractedDataEvent extends ExpenseEvent {}

class SaveExpenseEvent extends ExpenseEvent {}

class UpdateExpenseScreenState extends ExpenseEvent {
  final ExpenseState state;
  UpdateExpenseScreenState(this.state);
}

// ── Navigation targets ────────────────────────────────────────────────────────

abstract class ExpenseTarget {
  static const String back = 'back';
  static const String scanReceipt = 'scan_receipt';
}

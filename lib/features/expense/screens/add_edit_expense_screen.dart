// lib/features/expense/screens/add_edit_expense_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/base/base_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/color_constants.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_state.dart';
import '../models/expense_model.dart';

class AddEditExpenseScreen extends StatefulWidget {
  const AddEditExpenseScreen({super.key, this.expense});
  final ExpenseModel? expense;

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState
    extends BaseState<ExpenseBloc, AddEditExpenseScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _amountCtrl = TextEditingController();
    _noteCtrl = TextEditingController();
    bloc.add(InitExpenseEvent(existingExpense: widget.expense));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  void onViewEvent(ViewAction event) {
    if (event is DisplayMessage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(event.message ?? ''),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        ),
      );
    } else if (event is CloseScreen) {
      Navigator.pop(context);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
      );
      if (picked != null) {
        bloc.add(ScanReceiptEvent(File(picked.path)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not access camera/gallery: $e')),
      );
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Scan Receipt', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: _SourceButton(
                      icon: Icons.camera_alt_outlined,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _SourceButton(
                      icon: Icons.photo_library_outlined,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, ExpenseState data) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(data.date) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(primary: ColorConstants.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      bloc.add(UpdateDateEvent(picked.toIso8601String().split('T')[0]));
    }
  }

  void _syncControllersFromState(ExpenseState data) {
    if (_titleCtrl.text != data.title) {
      _titleCtrl.text = data.title;
      _titleCtrl.selection = TextSelection.collapsed(offset: _titleCtrl.text.length);
    }
    if (_amountCtrl.text != data.amount) {
      _amountCtrl.text = data.amount;
      _amountCtrl.selection = TextSelection.collapsed(offset: _amountCtrl.text.length);
    }
    if (_noteCtrl.text != data.note) {
      _noteCtrl.text = data.note;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExpenseBloc>(
      create: (_) => bloc,
      child: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, data) {
          _syncControllersFromState(data);

          // Show extracted data banner
          if (data.isScanComplete && data.extractedData != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showExtractedDataSheet(context, data);
            });
          }

          return Scaffold(
            backgroundColor: ColorConstants.background,
            appBar: AppBar(
              title: Text(data.isEditMode ? 'Edit Expense' : 'Add Expense'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                if (!data.isSaving)
                  TextButton(
                    onPressed: () => bloc.add(SaveExpenseEvent()),
                    child: Text('Save',
                        style: TextStyle(
                          color: ColorConstants.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15.sp,
                        )),
                  ),
                if (data.isSaving)
                  Padding(
                    padding: EdgeInsets.all(12.r),
                    child: SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(strokeWidth: 2, color: ColorConstants.primary),
                    ),
                  ),
              ],
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16.r),
                children: [
                  // ── AI Scanner CTA ──────────────────────────────────────
                  if (!data.isEditMode) _ScanReceiptCard(
                    isScanning: data.isScanning,
                    onTap: _showImageSourceSheet,
                  ),
                  if (data.isScanning) ...[
                    SizedBox(height: 12.h),
                    _ScanningIndicator(),
                  ],
                  if (data.scanError != null) ...[
                    SizedBox(height: 12.h),
                    _ScanErrorBanner(error: data.scanError!),
                  ],
                  SizedBox(height: 16.h),

                  // ── Title ───────────────────────────────────────────────
                  _FormField(
                    label: 'Title *',
                    child: TextFormField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(hintText: 'e.g. Lunch at Subway'),
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (v) => bloc.add(UpdateTitleEvent(v)),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // ── Amount ──────────────────────────────────────────────
                  _FormField(
                    label: 'Amount (₹) *',
                    child: TextFormField(
                      controller: _amountCtrl,
                      decoration: const InputDecoration(hintText: '0.00', prefixText: '₹ '),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                      onChanged: (v) => bloc.add(UpdateAmountEvent(v)),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Amount is required';
                        if (double.tryParse(v) == null || double.parse(v) <= 0) return 'Enter a valid amount';
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // ── Category ────────────────────────────────────────────
                  _FormField(
                    label: 'Category',
                    child: _CategorySelector(selected: data.category, onChanged: (c) => bloc.add(UpdateCategoryEvent(c))),
                  ),
                  SizedBox(height: 12.h),

                  // ── Date ────────────────────────────────────────────────
                  _FormField(
                    label: 'Date',
                    child: GestureDetector(
                      onTap: () => _pickDate(context, data),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                        decoration: BoxDecoration(
                          color: ColorConstants.inputFill,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 18.sp, color: ColorConstants.textSecondary),
                            SizedBox(width: 12.w),
                            Text(
                              DateFormat('MMMM d, yyyy').format(
                                DateTime.tryParse(data.date) ?? DateTime.now(),
                              ),
                              style: TextStyle(fontSize: 14.sp, color: ColorConstants.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // ── Note ────────────────────────────────────────────────
                  _FormField(
                    label: 'Note (optional)',
                    child: TextFormField(
                      controller: _noteCtrl,
                      decoration: const InputDecoration(hintText: 'Add a note...'),
                      maxLines: 3,
                      onChanged: (v) => bloc.add(UpdateNoteEvent(v)),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // ── Save Button ──────────────────────────────────────────
                  ElevatedButton(
                    onPressed: data.isSaving ? null : () => bloc.add(SaveExpenseEvent()),
                    child: data.isSaving
                        ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(data.isEditMode ? 'Update Expense' : 'Save Expense'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showExtractedDataSheet(BuildContext context, ExpenseState data) {
    final extracted = data.extractedData!;
    if (!extracted.isValid) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20.r, 16.r, 20.r, 32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w, height: 4.h,
                decoration: BoxDecoration(color: ColorConstants.divider, borderRadius: BorderRadius.circular(2.r)),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Icon(Icons.auto_awesome, color: ColorConstants.primary, size: 20.sp),
                SizedBox(width: 8.w),
                Text('AI Extracted Data', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
              ],
            ),
            SizedBox(height: 12.h),
            if (extracted.merchantName != null)
              _ExtractedRow(label: 'Merchant', value: extracted.merchantName!),
            if (extracted.amount != null)
              _ExtractedRow(label: 'Amount', value: '₹${extracted.amount!.toStringAsFixed(2)}'),
            if (extracted.category != null)
              _ExtractedRow(label: 'Category', value: '${extracted.category!.emoji} ${extracted.category!.label}'),
            if (extracted.date != null)
              _ExtractedRow(label: 'Date', value: DateFormat('MMM d, yyyy').format(extracted.date!)),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Discard'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      bloc.add(ApplyExtractedDataEvent());
                    },
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: ColorConstants.textSecondary,
            )),
        SizedBox(height: 6.h),
        child,
      ],
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({required this.selected, required this.onChanged});
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: ExpenseCategory.values.map((cat) {
        final isSelected = cat.label == selected;
        return GestureDetector(
          onTap: () => onChanged(cat.label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected ? ColorConstants.primary.withOpacity(0.12) : ColorConstants.inputFill,
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(
                color: isSelected ? ColorConstants.primary : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(cat.emoji, style: TextStyle(fontSize: 14.sp)),
                SizedBox(width: 6.w),
                Text(
                  cat.label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isSelected ? ColorConstants.primary : ColorConstants.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ScanReceiptCard extends StatelessWidget {
  const _ScanReceiptCard({required this.isScanning, required this.onTap});
  final bool isScanning;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isScanning ? null : onTap,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [ColorConstants.primary.withOpacity(0.08), ColorConstants.primary.withOpacity(0.04)],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: ColorConstants.primary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: ColorConstants.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.document_scanner_outlined, color: ColorConstants.primary, size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Scan Receipt with AI',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: ColorConstants.primary)),
                  Text('Auto-fill form from your receipt',
                      style: TextStyle(fontSize: 12.sp, color: ColorConstants.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14.sp, color: ColorConstants.primary),
          ],
        ),
      ),
    );
  }
}

class _ScanningIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20.w,
            height: 20.w,
            child: CircularProgressIndicator(strokeWidth: 2, color: ColorConstants.primary),
          ),
          SizedBox(width: 12.w),
          Text('Analyzing receipt with AI...', style: TextStyle(fontSize: 13.sp, color: ColorConstants.textSecondary)),
        ],
      ),
    );
  }
}

class _ScanErrorBanner extends StatelessWidget {
  const _ScanErrorBanner({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: ColorConstants.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: ColorConstants.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_outlined, color: ColorConstants.error, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(child: Text(error, style: TextStyle(fontSize: 12.sp, color: ColorConstants.error))),
        ],
      ),
    );
  }
}

class _ExtractedRow extends StatelessWidget {
  const _ExtractedRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          SizedBox(
            width: 80.w,
            child: Text(label, style: TextStyle(fontSize: 13.sp, color: ColorConstants.textSecondary)),
          ),
          Text('•  ', style: TextStyle(color: ColorConstants.textHint)),
          Expanded(child: Text(value, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: ColorConstants.textPrimary))),
        ],
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: ColorConstants.inputFill,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28.sp, color: ColorConstants.primary),
            SizedBox(height: 8.h),
            Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

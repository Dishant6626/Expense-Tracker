// lib/features/expense/screens/expense_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../config/routes/app_routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/color_constants.dart';
import '../models/expense_model.dart';

class ExpenseDetailScreen extends StatelessWidget {
  const ExpenseDetailScreen({super.key, required this.expense});
  final ExpenseModel expense;

  Color _catColor(ExpenseCategory c) {
    switch (c) {
      case ExpenseCategory.food: return ColorConstants.food;
      case ExpenseCategory.shopping: return ColorConstants.shopping;
      case ExpenseCategory.travel: return ColorConstants.travel;
      case ExpenseCategory.utilities: return ColorConstants.utilities;
      case ExpenseCategory.entertainment: return ColorConstants.entertainment;
      default: return ColorConstants.others;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final cat = expense.category;
    final color = _catColor(cat);

    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: AppBar(
        title: const Text('Expense Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.pushNamed(
              context, RouteNames.editExpense, arguments: expense,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            // Hero amount card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.8), color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                children: [
                  Text(cat.emoji, style: TextStyle(fontSize: 40.sp)),
                  SizedBox(height: 8.h),
                  Text(
                    fmt.format(expense.amount),
                    style: TextStyle(fontSize: 36.sp, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  SizedBox(height: 4.h),
                  Text(expense.title, style: TextStyle(fontSize: 16.sp, color: Colors.white70, fontWeight: FontWeight.w500)),
                  if (expense.isAiExtracted) ...[
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, size: 14.sp, color: Colors.white),
                          SizedBox(width: 4.w),
                          Text('AI extracted', style: TextStyle(fontSize: 12.sp, color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Details card
            Container(
              decoration: BoxDecoration(
                color: ColorConstants.cardBackground,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _DetailRow(icon: Icons.category_outlined, label: 'Category', value: '${cat.emoji} ${cat.label}'),
                  Divider(height: 1, color: ColorConstants.divider, indent: 52.w),
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date',
                    value: DateFormat('EEEE, MMMM d yyyy').format(expense.date),
                  ),
                  if (expense.merchantName != null) ...[
                    Divider(height: 1, color: ColorConstants.divider, indent: 52.w),
                    _DetailRow(icon: Icons.store_outlined, label: 'Merchant', value: expense.merchantName!),
                  ],
                  Divider(height: 1, color: ColorConstants.divider, indent: 52.w),
                  _DetailRow(
                    icon: Icons.access_time_outlined,
                    label: 'Added on',
                    value: DateFormat('MMM d, yyyy • h:mm a').format(expense.createdAt),
                  ),
                  if (expense.note != null && expense.note!.isNotEmpty) ...[
                    Divider(height: 1, color: ColorConstants.divider, indent: 52.w),
                    _DetailRow(icon: Icons.note_outlined, label: 'Note', value: expense.note!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: ColorConstants.primary),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11.sp, color: ColorConstants.textHint)),
                SizedBox(height: 2.h),
                Text(value, style: TextStyle(fontSize: 14.sp, color: ColorConstants.textPrimary, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

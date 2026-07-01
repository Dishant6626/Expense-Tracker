// lib/features/dashboard/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../config/routes/app_routes.dart';
import '../../../core/base/base_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/color_constants.dart';
import '../../expense/models/expense_model.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_state.dart';
import 'widgets/category_chip_filter.dart';
import 'widgets/expense_list_tile.dart';
import 'widgets/spending_summary_card.dart';
import 'widgets/category_pie_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends BaseState<DashboardBloc, DashboardScreen> {
  @override
  void initState() {
    super.initState();
    bloc.add(LoadDashboardEvent());
  }

  @override
  void onViewEvent(ViewAction event) {
    if (event is DisplayMessage) {
      _showSnackBar(event.message ?? '');
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardBloc>(
      create: (_) => bloc,
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, data) {
          return Scaffold(
            backgroundColor: ColorConstants.background,
            body: _Body(data: data, bloc: bloc),
            floatingActionButton: _AddButton(bloc: bloc),
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.data, required this.bloc});
  final DashboardState data;
  final DashboardBloc bloc;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => bloc.add(RefreshDashboardEvent()),
      child: CustomScrollView(
        slivers: [
          _AppBar(data: data, bloc: bloc),
          if (data.state == ScreenState.loading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (data.state == ScreenState.error)
            SliverFillRemaining(child: _ErrorView(message: data.errorMessage, bloc: bloc))
          else ...[
            SliverToBoxAdapter(child: SpendingSummaryCard(data: data)),
            if (data.categoryTotals.isNotEmpty)
              SliverToBoxAdapter(child: CategoryPieChart(categoryTotals: data.categoryTotals.toMap())),
            SliverToBoxAdapter(child: CategoryChipFilter(data: data, bloc: bloc)),
            if (data.state == ScreenState.empty || bloc.filteredExpenses.isEmpty)
              const SliverFillRemaining(child: _EmptyView())
            else
              _ExpenseList(expenses: bloc.filteredExpenses, bloc: bloc),
          ],
          SliverToBoxAdapter(child: SizedBox(height: 100.h)),
        ],
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({required this.data, required this.bloc});
  final DashboardState data;
  final DashboardBloc bloc;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120.h,
      floating: true,
      pinned: true,
      backgroundColor: ColorConstants.primary,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: 20.w, bottom: 16.h),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ExpenseAI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [ColorConstants.primary, const Color(0xFF9C63FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.pushNamed(context, RouteNames.aiInsights),
          icon: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: Colors.white, size: 16.sp),
                SizedBox(width: 4.w),
                Text('AI', style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        SizedBox(width: 8.w),
      ],
    );
  }
}

class _ExpenseList extends StatelessWidget {
  const _ExpenseList({required this.expenses, required this.bloc});
  final List<ExpenseModel> expenses;
  final DashboardBloc bloc;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          if (i == 0) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Expenses',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: ColorConstants.textPrimary)),
                  Text('${expenses.length} items',
                      style: TextStyle(fontSize: 12.sp, color: ColorConstants.textSecondary)),
                ],
              ),
            );
          }
          final expense = expenses[i - 1];
          return ExpenseListTile(
            expense: expense,
            onTap: () => Navigator.pushNamed(context, RouteNames.expenseDetail, arguments: expense),
            onEdit: () => Navigator.pushNamed(context, RouteNames.editExpense, arguments: expense),
            onDelete: () => _confirmDelete(context, expense),
          );
        },
        childCount: expenses.length + 1,
      ),
    );
  }

  void _confirmDelete(BuildContext context, ExpenseModel expense) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Delete Expense'),
        content: Text('Delete "${expense.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              bloc.add(DeleteExpenseEvent(expense.id));
            },
            child: Text('Delete', style: TextStyle(color: ColorConstants.error)),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.bloc});
  final DashboardBloc bloc;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        await Navigator.pushNamed(context, RouteNames.addExpense);
        bloc.add(RefreshDashboardEvent());
      },
      backgroundColor: ColorConstants.primary,
      icon: const Icon(Icons.add, color: Colors.white),
      label: Text('Add Expense',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14.sp)),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64.sp, color: ColorConstants.textHint),
          SizedBox(height: 16.h),
          Text('No expenses yet', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: ColorConstants.textSecondary)),
          SizedBox(height: 8.h),
          Text('Tap + to add your first expense', style: TextStyle(fontSize: 14.sp, color: ColorConstants.textHint)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({this.message, required this.bloc});
  final String? message;
  final DashboardBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48.sp, color: ColorConstants.error),
          SizedBox(height: 12.h),
          Text(message ?? 'Something went wrong', textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: ColorConstants.textSecondary)),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => bloc.add(LoadDashboardEvent()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

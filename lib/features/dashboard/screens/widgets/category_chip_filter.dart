// lib/features/dashboard/screens/widgets/category_chip_filter.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/color_constants.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../bloc/dashboard_state.dart';

class CategoryChipFilter extends StatelessWidget {
  const CategoryChipFilter({super.key, required this.data, required this.bloc});
  final DashboardState data;
  final DashboardBloc bloc;

  @override
  Widget build(BuildContext context) {
    final categories = ['All', ...ExpenseCategory.values.map((e) => e.label)];
    return SizedBox(
      height: 44.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final cat = categories[i];
          final isAll = cat == 'All';
          final isSelected = isAll
              ? data.selectedCategoryFilter == null
              : data.selectedCategoryFilter == cat;

          return FilterChip(
            selected: isSelected,
            label: Text(cat),
            onSelected: (_) {
              bloc.add(FilterByCategoryEvent(isAll ? null : cat));
            },
            selectedColor: ColorConstants.primary.withOpacity(0.15),
            checkmarkColor: ColorConstants.primary,
            labelStyle: TextStyle(
              fontSize: 13.sp,
              color: isSelected ? ColorConstants.primary : ColorConstants.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            side: BorderSide(
              color: isSelected ? ColorConstants.primary : ColorConstants.divider,
            ),
          );
        },
      ),
    );
  }
}

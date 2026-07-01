// lib/features/dashboard/screens/widgets/category_pie_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/color_constants.dart';

class CategoryPieChart extends StatefulWidget {
  const CategoryPieChart({super.key, required this.categoryTotals});
  final Map<String, double> categoryTotals;

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int _touchedIndex = -1;

  Color _colorFor(String category) {
    switch (category) {
      case 'Food': return ColorConstants.food;
      case 'Shopping': return ColorConstants.shopping;
      case 'Travel': return ColorConstants.travel;
      case 'Utilities': return ColorConstants.utilities;
      case 'Entertainment': return ColorConstants.entertainment;
      default: return ColorConstants.others;
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.categoryTotals.values.fold<double>(0, (a, b) => a + b);
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final entries = widget.categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Category Breakdown',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: ColorConstants.textPrimary)),
          SizedBox(height: 16.h),
          Row(
            children: [
              SizedBox(
                height: 160.h,
                width: 160.w,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40.r,
                    sections: entries.asMap().entries.map((entry) {
                      final i = entry.key;
                      final cat = entry.value.key;
                      final val = entry.value.value;
                      final isTouched = i == _touchedIndex;
                      return PieChartSectionData(
                        color: _colorFor(cat),
                        value: val,
                        radius: isTouched ? 55.r : 45.r,
                        title: '${(val / total * 100).toStringAsFixed(0)}%',
                        titleStyle: TextStyle(
                          fontSize: isTouched ? 13.sp : 11.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: entries.map((entry) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Row(
                        children: [
                          Container(
                            width: 10.w,
                            height: 10.w,
                            decoration: BoxDecoration(
                              color: _colorFor(entry.key),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(entry.key,
                                style: TextStyle(fontSize: 12.sp, color: ColorConstants.textSecondary)),
                          ),
                          Text(fmt.format(entry.value),
                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: ColorConstants.textPrimary)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// lib/features/ai_insights/screens/ai_insights_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/base/base_bloc.dart';
import '../../../core/constants/color_constants.dart';
import '../bloc/ai_insights_bloc.dart';
import '../bloc/ai_insights_state.dart';

class AiInsightsScreen extends StatefulWidget {
  const AiInsightsScreen({super.key});

  @override
  State<AiInsightsScreen> createState() => _AiInsightsScreenState();
}

class _AiInsightsScreenState
    extends BaseState<AiInsightsBloc, AiInsightsScreen> {
  @override
  void initState() {
    super.initState();
    bloc.add(LoadInsightsEvent());
  }

  @override
  void onViewEvent(ViewAction event) {
    if (event is DisplayMessage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(event.message ?? ''), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AiInsightsBloc>(
      create: (_) => bloc,
      child: BlocBuilder<AiInsightsBloc, AiInsightsState>(
        builder: (context, data) {
          return Scaffold(
            backgroundColor: ColorConstants.background,
            appBar: AppBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, color: ColorConstants.primary, size: 18.sp),
                  SizedBox(width: 6.w),
                  const Text('AI Insights'),
                ],
              ),
            ),
            body: _Body(data: data, bloc: bloc),
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.data, required this.bloc});
  final AiInsightsState data;
  final AiInsightsBloc bloc;

  @override
  Widget build(BuildContext context) {
    if (data.state == ScreenState.loading && !data.isGenerating) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF9C63FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🤖 AI Spending Analysis',
                    style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w700)),
                SizedBox(height: 6.h),
                Text(
                  'Get personalized insights powered by Gemini AI',
                  style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                ),
                if (data.lastGeneratedDate != null) ...[
                  SizedBox(height: 10.h),
                  Text('Last updated: ${data.lastGeneratedDate}',
                      style: TextStyle(color: Colors.white54, fontSize: 11.sp)),
                ],
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Generate button
          ElevatedButton.icon(
            onPressed: data.isGenerating ? null : () => bloc.add(GenerateInsightsEvent()),
            icon: data.isGenerating
                ? SizedBox(width: 18.w, height: 18.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Icon(Icons.refresh, size: 18.sp),
            label: Text(data.isGenerating
                ? 'Generating insights...'
                : (data.insightText != null ? 'Regenerate Insights' : 'Generate Insights')),
          ),
          SizedBox(height: 20.h),

          // Insight content
          if (data.state == ScreenState.empty && !data.isGenerating)
            _EmptyView()
          else if (data.insightText != null)
            _InsightCard(text: data.insightText!)
          else if (data.isGenerating)
            _GeneratingCard(),

          if (data.errorMessage != null) ...[
            SizedBox(height: 12.h),
            _ErrorBanner(message: data.errorMessage!),
          ],
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: ColorConstants.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.insights, color: ColorConstants.primary, size: 18.sp),
              ),
              SizedBox(width: 10.w),
              Text('Your Spending Report',
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: ColorConstants.textPrimary)),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: ColorConstants.textPrimary,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneratingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          SizedBox(height: 8.h),
          CircularProgressIndicator(color: ColorConstants.primary),
          SizedBox(height: 16.h),
          Text('Analyzing your expenses...', style: TextStyle(fontSize: 14.sp, color: ColorConstants.textSecondary)),
          SizedBox(height: 4.h),
          Text('This may take a few seconds', style: TextStyle(fontSize: 12.sp, color: ColorConstants.textHint)),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32.r),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(Icons.bar_chart_outlined, size: 56.sp, color: ColorConstants.textHint),
          SizedBox(height: 16.h),
          Text('No Insights Yet', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: ColorConstants.textSecondary)),
          SizedBox(height: 8.h),
          Text(
            'Add some expenses and tap "Generate Insights" to get AI-powered spending analysis.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: ColorConstants.textHint, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

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
          Icon(Icons.error_outline, color: ColorConstants.error, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(child: Text(message, style: TextStyle(fontSize: 12.sp, color: ColorConstants.error))),
        ],
      ),
    );
  }
}

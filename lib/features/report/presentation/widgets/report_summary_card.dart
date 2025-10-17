// features/reports/presentation/widgets/report_summary_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../cubit/report_cubit.dart';
import '../cubit/report_state.dart';
import 'summary_item.dart';

class ReportSummaryCard extends StatelessWidget {
  const ReportSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportCubit, ReportState>(
      builder: (context, state) {
        if (state is ReportLoading) {
          return _buildLoadingCard();
        }

        if (state is ReportError) {
          return _buildErrorCard(state.message);
        }

        if (state is ReportLoaded) {
          return _buildSummaryCard(state.summary);
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Center(
        child: Text(
          'تعذر تحميل الملخص: $message',
          style: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          // صف الإيرادات والصافي
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SummaryItem(
                value: '${summary.totalRevenue.toStringAsFixed(0)} ر.س',
                label: 'إجمالي الإيرادات',
                color: AppColors.gold,
              ),
              SummaryItem(
                value: '${summary.netProfit.toStringAsFixed(0)} ر.س',
                label: 'صافي الربح',
                color: AppColors.paleGold,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // صف المصروفات والهامش
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SummaryItem(
                value: '${summary.totalExpenses.toStringAsFixed(0)} ر.س',
                label: 'إجمالي المصروفات',
                color: AppColors.deepRed,
              ),
              SummaryItem(
                value: '${summary.profitMargin.toStringAsFixed(1)}%',
                label: 'هامش الربح',
                color: AppColors.gold,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // عدد الحفلات
          _buildEventsCount(summary.totalEvents),
        ],
      ),
    );
  }

  Widget _buildEventsCount(int totalEvents) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.event, size: 16, color: AppColors.gray500),
          const SizedBox(width: 8),
          Text(
            '$totalEvents    عدد حفلات      ',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.gray500,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: AppColors.gray200,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

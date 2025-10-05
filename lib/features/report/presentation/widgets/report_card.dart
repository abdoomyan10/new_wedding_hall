import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/report_entity.dart';
import 'report_metric.dart';

class ReportCard extends StatelessWidget {
  final ReportEntity report;
  final String period;

  const ReportCard({
    super.key,
    required this.report,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildFirstMetricsRow(),
            const SizedBox(height: 12),
            _buildSecondMetricsRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'تقرير ${_getPeriodText(report.period)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        Text(
          _formatDate(),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.gray500,
          ),
        ),
      ],
    );
  }

  Widget _buildFirstMetricsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ReportMetric(
          value: '${report.totalRevenue.toStringAsFixed(0)} ر.س',
          label: 'الإيرادات',
          color: AppColors.success,
        ),
        ReportMetric(
          value: '${report.expenses.toStringAsFixed(0)} ر.س',
          label: 'المصروفات',
          color: AppColors.warning,
        ),
        ReportMetric(
          value: '${report.netProfit.toStringAsFixed(0)} ر.س',
          label: 'صافي الربح',
          color: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildSecondMetricsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ReportMetric(
          value: '${report.totalPayments.toStringAsFixed(0)} ر.س',
          label: 'المدفوعات',
          color: AppColors.info,
        ),
        ReportMetric(
          value: '${report.eventsCount}',
          label: 'عدد الحفلات',
          color: AppColors.gray500,
        ),
        ReportMetric(
          value: '${report.profitMargin.toStringAsFixed(1)}%',
          label: 'هامش الربح',
          color: AppColors.success,
        ),
      ],
    );
  }

  String _getPeriodText(String period) {
    switch (period) {
      case 'daily':
        return 'يومي';
      case 'weekly':
        return 'أسبوعي';
      case 'monthly':
        return 'شهري';
      default:
        return period;
    }
  }

  String _formatDate() {
    switch (period) {
      case 'daily':
        return DateFormat('yyyy-MM-dd').format(report.date);
      case 'weekly':
        return 'أسبوع ${DateFormat('MM-dd').format(report.date)}';
      case 'monthly':
        return DateFormat('yyyy-MM').format(report.date);
      case 'yearly': // ✅ إضافة الحالة السنوية
        return DateFormat('yyyy').format(report.date);
      default:
        return DateFormat('yyyy-MM-dd').format(report.date);
    }
  }

}

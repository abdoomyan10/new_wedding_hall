// features/reports/presentation/widgets/report_details_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:new_wedding_hall/core/constants/app_colors.dart';
import '../../domain/entities/report_entity.dart';
import '../cubit/report_cubit.dart';

class ReportDetailsDialog extends StatelessWidget {
  final ReportEntity report;
  final String period;

  const ReportDetailsDialog({
    super.key,
    required this.report,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildDetailSection(),
            const SizedBox(height: 20),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.analytics, color: AppColors.deepRed, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'تفاصيل التقرير',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.deepRed,
            ),
          ),
        ),
        IconButton(
          color: AppColors.deepRed,
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildDetailSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          _buildDetailRow('الفترة:', _getPeriodText(period)),
          _buildDetailRow('التاريخ:', _formatDate(report.date)),
          _buildDetailRow(
            'الإيرادات:',
            '${report.totalRevenue.toStringAsFixed(2)} ر.س',
          ),
          _buildDetailRow(
            'المصروفات:',
            '${report.expenses.toStringAsFixed(2)} ر.س',
          ),
          _buildDetailRow(
            'صافي الربح:',
            '${report.netProfit.toStringAsFixed(2)} ر.س',
          ),
          _buildDetailRow(
            'المدفوعات:',
            '${report.totalPayments.toStringAsFixed(2)} ر.س',
          ),
          _buildDetailRow('عدد الحفلات:', report.eventsCount.toString()),
          _buildDetailRow(
            'هامش الربح:',
            '${report.profitMargin.toStringAsFixed(1)}%',
          ),
          _buildDetailRow('المعرف:', report.id),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text(
                  'حفظ PDF',
                  style: TextStyle(color: AppColors.gold),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  context.read<ReportCubit>().generateAndSaveSingleReportPdf(
                    report,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.gold,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: AppColors.deepRed),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.print),
                label: const Text(
                  'طباعة',
                  style: TextStyle(color: AppColors.gold),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  context.read<ReportCubit>().generateSingleReportPdf(report);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepRed,
                  foregroundColor: AppColors.gold,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
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
      case 'yearly':
        return 'سنوي';
      default:
        return period;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd - HH:mm').format(date);
  }
}

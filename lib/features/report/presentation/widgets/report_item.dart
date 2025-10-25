// features/reports/presentation/widgets/report_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:new_wedding_hall/core/constants/app_colors.dart';
import '../../domain/entities/report_entity.dart';
import '../cubit/report_cubit.dart';

class ReportItem extends StatelessWidget {
  final ReportEntity report;
  final String period;
  final VoidCallback onTap;

  const ReportItem({
    super.key,
    required this.report,
    required this.period,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: _buildProfitIndicator(),
        title: Text(
          'تقرير ${_getPeriodText(period)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatDate(report.date)),
            Text(
              'صافي الربح: ${report.netProfit.toStringAsFixed(2)} ر.س',
              style: TextStyle(
                color: report.netProfit >= 0
                    ? AppColors.deepRed
                    : AppColors.deepRed.copyWith(0.5),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: _buildTrailingButtons(context),
        onTap: onTap,
      ),
    );
  }

  Widget _buildProfitIndicator() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: report.netProfit >= 0
            ? Colors.green.shade50
            : Colors.red.shade50,
        shape: BoxShape.circle,
      ),
      child: Text(
        '${report.netProfit.toStringAsFixed(0)} ر.س',
        style: TextStyle(
          color: report.netProfit >= 0
              ? AppColors.deepRed
              : AppColors.deepRed.copyWith(0.5),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTrailingButtons(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: AppColors.gold),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'details',
          child: Row(
            children: [
              Icon(Icons.info, color: AppColors.deepRed),
              const SizedBox(width: 8),
              const Text('تفاصيل', style: TextStyle(color: AppColors.gold)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'save_pdf',
          child: Row(
            children: [
              Icon(Icons.save, color: AppColors.deepRed),
              const SizedBox(width: 8),
              const Text('حفظ PDF', style: TextStyle(color: AppColors.gold)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'print_pdf',
          child: Row(
            children: [
              Icon(Icons.print, color: AppColors.deepRed),
              const SizedBox(width: 8),
              const Text('طباعة PDF', style: TextStyle(color: AppColors.gold)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'details':
            onTap();
            break;
          case 'save_pdf':
            _generateAndSavePdf(context);
            break;
          case 'print_pdf':
            _generateAndPrintPdf(context);
            break;
        }
      },
    );
  }

  void _generateAndSavePdf(BuildContext context) {
    context.read<ReportCubit>().generateAndSaveSingleReportPdf(report);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'تم حفظ التقرير كملف PDF على جهازك',
          style: TextStyle(color: AppColors.gold),
        ),
        backgroundColor: AppColors.deepRed,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _generateAndPrintPdf(BuildContext context) {
    context.read<ReportCubit>().generateSingleReportPdf(report);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'جاري إعداد التقرير للطباعة',
          style: TextStyle(color: AppColors.gold),
        ),
        backgroundColor: AppColors.deepRed,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
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
    switch (period) {
      case 'daily':
        return DateFormat('yyyy-MM-dd').format(date);
      case 'weekly':
        return 'أسبوع ${DateFormat('MM-dd').format(date)}';
      case 'monthly':
        return DateFormat('yyyy-MM').format(date);
      case 'yearly':
        return DateFormat('yyyy').format(date);
      default:
        return DateFormat('yyyy-MM-dd').format(date);
    }
  }
}

extension on Color {
  copyWith(double d) {}
}

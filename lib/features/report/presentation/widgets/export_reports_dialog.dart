// features/reports/presentation/widgets/export_reports_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/report_cubit.dart';
import '../cubit/report_state.dart';

class ExportReportsDialog {
  static void show(BuildContext context) {
    final cubit = context.read<ReportCubit>();
    final state = cubit.state;

    // التحقق من وجود تقارير لتصديرها
    if (state is! ReportLoaded || state.reports.isEmpty) {
      _showErrorSnackBar(context, 'لا توجد تقارير لتصديرها');
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'تصدير التقارير',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('تصدير كـ PDF'),
              subtitle: const Text('ملف PDF قابل للطباعة'),
              onTap: () {
                Navigator.pop(context);
                cubit.exportToPdf(); // ✅ استدعاء الدالة المضافة
                _showExportSnackBar(context, 'PDF');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('تصدير كـ Excel'),
              subtitle: const Text('ملف Excel للتحليل'),
              onTap: () {
                Navigator.pop(context);
                cubit.exportToExcel();
                _showExportSnackBar(context, 'Excel');
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
          ],
        ),
      ),
    );
  }

  static void _showExportSnackBar(BuildContext context, String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('جاري تصدير التقارير كـ $format...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
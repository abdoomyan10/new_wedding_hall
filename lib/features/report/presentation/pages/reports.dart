// features/reports/presentation/pages/reports_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/dependencies.dart';
import '../../../../injection_container.dart';
import '../cubit/report_cubit.dart';
import '../cubit/report_state.dart';
import '../widgets/export_reports_dialog.dart';
import '../widgets/time_period_selector.dart';
import '../widgets/report_summary_card.dart';
import '../widgets/reports_list.dart';
import 'saved_reports_page.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ReportCubit>()..loadDailyReports(),
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: const _ReportsBody(),
        floatingActionButton: _buildFloatingActionButton(context),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'التقارير',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      backgroundColor: Colors.blue.shade700,
      foregroundColor: Colors.white,
      elevation: 2,
      actions: [
        IconButton(
          icon: const Icon(Icons.folder),
          tooltip: 'التقارير المحفوظة',
          onPressed: () => _navigateToSavedReports(context),
        ),
        BlocBuilder<ReportCubit, ReportState>(
          builder: (context, state) {
            return PopupMenuButton<String>(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'تصدير PDF',
              onSelected: (value) {
                switch (value) {
                  case 'save_report':
                    _savePdfReport(context);
                    break;
                  case 'print_report':
                    _printPdfReport(context);
                    break;
                  case 'saved_reports':
                    _navigateToSavedReports(context);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'save_report',
                  child: Row(children: [
                    Icon(Icons.save, color: Colors.green),
                    SizedBox(width: 8),
                    Text('حفظ PDF على الجهاز'),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'print_report',
                  child: Row(children: [
                    Icon(Icons.print, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('طباعة مباشرة'),
                  ]),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'saved_reports',
                  child: Row(children: [
                    Icon(Icons.folder_open, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('التقارير المحفوظة'),
                  ]),
                ),
              ],
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'تحديث البيانات',
          onPressed: () => context.read<ReportCubit>().loadDailyReports(),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => ExportReportsDialog.show(context),
      backgroundColor: Colors.blue.shade700,
      foregroundColor: Colors.white,
      child: const Icon(Icons.download),
    );
  }

  void _savePdfReport(BuildContext context) async {
    try {
      final cubit = context.read<ReportCubit>();
      await cubit.generateAndSavePdfReport();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ تقرير PDF بنجاح'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في حفظ التقرير: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _printPdfReport(BuildContext context) async {
    try {
      final cubit = context.read<ReportCubit>();
      await cubit.generatePdfReport();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إعداد التقرير للطباعة بنجاح'),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في طباعة التقرير: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _navigateToSavedReports(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SavedReportsPage(),
      ),
    );
  }
}

class _ReportsBody extends StatelessWidget {
  const _ReportsBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportCubit, ReportState>(
      builder: (context, state) {
        return const Column(
          children: [
            TimePeriodSelector(),
            ReportSummaryCard(),
            Expanded(child: ReportsList()),
          ],
        );
      },
    );
  }
}
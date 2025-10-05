// features/reports/presentation/pages/reports_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart';
import '../cubit/report_cubit.dart';
import '../widgets/export_reports_dialog.dart';
import '../widgets/time_period_selector.dart';
import '../widgets/report_summary_card.dart';
import '../widgets/reports_list.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ReportCubit>()..loadDailyReports(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التقارير'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => ExportReportsDialog.show(context),
              tooltip: 'تصدير التقارير',
            ),
          ],
        ),
        body: const Column(
          children: [
            TimePeriodSelector(),
            ReportSummaryCard(),
            Expanded(child: ReportsList()),
          ],
        ),
      ),
    );
  }
}
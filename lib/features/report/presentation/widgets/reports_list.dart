// features/reports/presentation/widgets/reports_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/report_entity.dart';
import '../cubit/report_cubit.dart';
import '../cubit/report_state.dart';
import 'report_details_dialog.dart';
import 'report_item.dart';

class ReportsList extends StatelessWidget {
  const ReportsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportCubit, ReportState>(
      builder: (context, state) {
        if (state is ReportLoading) {
          return _buildLoadingState();
        } else if (state is ReportLoaded) {
          return _buildLoadedState(context, state);
        } else if (state is ReportError) {
          return _buildErrorState(context, state);
        }
        return _buildInitialState();
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('جاري تحميل التقارير...'),
        ],
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, ReportLoaded state) {
    if (state.reports.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        final cubit = context.read<ReportCubit>();
        switch (state.selectedPeriod) {
          case 'daily':
            cubit.loadDailyReports();
            break;
          case 'weekly':
            cubit.loadWeeklyReports();
            break;
          case 'monthly':
            cubit.loadMonthlyReports();
            break;
          case 'yearly':
            cubit.loadYearlyReports();
            break;
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.reports.length,
        itemBuilder: (context, index) {
          final report = state.reports[index];
          return ReportItem(
            report: report,
            period: state.selectedPeriod,
            onTap: () => _showReportDetails(context, report, state.selectedPeriod),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'لا توجد تقارير',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ReportError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            state.message,
            style: const TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<ReportCubit>().loadDailyReports();
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return const Center(
      child: Text('مرحباً بك في التقارير'),
    );
  }

  void _showReportDetails(BuildContext context, ReportEntity report, String period) {
    showDialog(
      context: context,
      builder: (context) => ReportDetailsDialog(report: report, period: period),
    );
  }
}
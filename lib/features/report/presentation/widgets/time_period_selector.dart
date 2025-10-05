// features/reports/presentation/widgets/time_period_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../cubit/report_cubit.dart';
import '../cubit/report_state.dart';
import 'period_button.dart';

class TimePeriodSelector extends StatelessWidget {
  const TimePeriodSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportCubit, ReportState>(
      builder: (context, state) {
        final currentPeriod = state is ReportLoaded ? state.selectedPeriod : 'daily';

        // استخدام نموذج بيانات آمن بدلاً من Map
        final periods = [
          _PeriodOption(key: 'daily', text: 'يومي', icon: Icons.today),
          _PeriodOption(key: 'weekly', text: 'أسبوعي', icon: Icons.date_range),
          _PeriodOption(key: 'monthly', text: 'شهري', icon: Icons.calendar_today),
          _PeriodOption(key: 'yearly', text: 'سنوي', icon: Icons.calendar_view_day), // ✅ إضافة سنوي
        ];

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          color: AppColors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: periods.map((period) {
              return PeriodButton(
                text: period.text,
                icon: period.icon,
                isSelected: period.key == currentPeriod,
                onTap: () {
                  _handlePeriodSelection(context, period.key);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _handlePeriodSelection(BuildContext context, String periodKey) {
    final cubit = context.read<ReportCubit>();

    switch (periodKey) {
      case 'daily':
        cubit.loadDailyReports();
        break;
      case 'weekly':
        cubit.loadWeeklyReports();
        break;
      case 'monthly':
        cubit.loadMonthlyReports();
        break;
      case 'yearly': // ✅ إضافة الحالة السنوية
        cubit.loadYearlyReports();
        break;
    }
  }
}

// نموذج بيانات آمن لتجنب أخطاء null
class _PeriodOption {
  final String key;
  final String text;
  final IconData icon;

  const _PeriodOption({
    required this.key,
    required this.text,
    required this.icon,
  });
}
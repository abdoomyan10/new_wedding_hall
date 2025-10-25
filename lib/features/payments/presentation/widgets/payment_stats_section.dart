// features/payments/presentation/widgets/payment_stats_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../cubit/payment_cubit.dart';
import 'stat_item.dart';

class PaymentStatsSection extends StatelessWidget {
  const PaymentStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentCubit, PaymentState>(
      builder: (context, state) {
        if (state is PaymentLoaded && state.stats != null) {
          final stats = state.stats!;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.deepRed.withOpacity(0.04),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // الصف الأول من الإحصائيات
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    StatItem(
                      value: '${stats.totalReceived.toStringAsFixed(0)} ر.س',
                      label: 'إجمالي المستلم',
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepRed,
                      ),
                      icon: Icons.check_circle,
                      color: AppColors.gold,
                    ),
                    StatItem(
                      value: '${stats.totalPending.toStringAsFixed(0)} ر.س',
                      label: 'المدفوعات المعلقة',
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepRed,
                      ),
                      icon: Icons.pending,
                      color: AppColors.gold,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // الصف الثاني من الإحصائيات
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    StatItem(
                      value: stats.completedPayments.toString(),
                      label: 'مدفوعات مكتملة',
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepRed,
                      ),
                      icon: Icons.payment,
                      color: AppColors.paleGold,
                    ),
                    StatItem(
                      value: stats.pendingPayments.toString(),
                      label: 'مدفوعات معلقة',
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepRed,
                      ),
                      icon: Icons.schedule,
                      color: AppColors.gold,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // شريط التقدم
                LinearProgressIndicator(
                  value: stats.totalExpected > 0
                      ? stats.totalReceived / stats.totalExpected
                      : 0,
                  backgroundColor: AppColors.gray200,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                ),
                const SizedBox(height: 8),
                Text(
                  'نسبة الإنجاز: ${((stats.totalReceived / stats.totalExpected) * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.deepRed,
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}

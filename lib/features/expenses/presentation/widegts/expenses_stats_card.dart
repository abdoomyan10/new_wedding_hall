// features/expenses/presentation/widgets/expense_stats_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/expense_cubit.dart';
import '../cubit/expense_state.dart';

class ExpenseStatsCard extends StatelessWidget {
  const ExpenseStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseCubit, ExpenseState>(
      builder: (context, state) {
        // حالة التحميل الأولي فقط
        if (state is ExpenseLoading && state.expenses.isEmpty) {
          return _buildLoadingStats();
        }

        // في جميع الحالات الأخرى، عرض البيانات المتاحة
        final totalExpenses = state.expenses.fold(
            0.0,
                (sum, expense) => sum + expense.amount
        );

        // TODO: استبدل بقيمة حقيقية من PaymentCubit
        const totalRevenue = 15000.0;
        final profit = totalRevenue - totalExpenses;

        return _buildStatsContent(totalExpenses, totalRevenue, profit);
      },
    );
  }

  Widget _buildStatsContent(double totalExpenses, double totalRevenue, double profit) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'ر.س',
      decimalDigits: 2,
    );

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // العنوان
          const Text(
            'ملخص المالية',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 16),

          // شبكة الإحصائيات
          Row(
            children: [
              // الإيرادات
              Expanded(
                child: _buildStatItem(
                  'الإيرادات',
                  currencyFormat.format(totalRevenue),
                  Colors.green,
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 12),

              // التكاليف
              Expanded(
                child: _buildStatItem(
                  'التكاليف',
                  currencyFormat.format(totalExpenses),
                  Colors.red,
                  Icons.trending_down,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // الفائض
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: profit >= 0 ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: profit >= 0 ? Colors.green.shade200 : Colors.red.shade200,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  profit >= 0 ? Icons.thumb_up : Icons.thumb_down,
                  color: profit >= 0 ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'الفائض: ${currencyFormat.format(profit)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: profit >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingStats() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 8),
          Text('جاري تحميل الإحصائيات...'),
        ],
      ),
    );
  }
}
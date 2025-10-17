// features/expenses/presentation/widgets/expenses_stats_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/expense_stats_entity.dart';
import '../../domain/entities/profit_entity.dart';
import '../cubit/expense_cubit.dart';
import '../cubit/expense_state.dart';

class ExpenseStatsCard extends StatelessWidget {
  const ExpenseStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseCubit, ExpenseState>(
      builder: (context, state) {
        if (state is! ExpenseLoaded) {
          return const _LoadingStatsCard();
        }

        final stats = state.filteredStats;
        final profit = state.profit;

        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade50,
          child: Column(
            children: [
              _buildStatsRow(stats, profit),
              const SizedBox(height: 12),
              if (profit != null) _buildProfitIndicator(profit),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsRow(ExpenseStatsEntity stats, ProfitEntity? profit) {
    return Row(
      children: [
        _buildStatItem(
          'إجمالي التكاليف',
          '${stats.totalExpenses.toStringAsFixed(2)} ر.س',
          Colors.red,
          Icons.payments,
        ),
        const SizedBox(width: 12),
        _buildStatItem(
          'عدد التكاليف',
          stats.expenseCount.toString(),
          Colors.blue,
          Icons.list,
        ),
        const SizedBox(width: 12),
        _buildStatItem(
          'متوسط التكلفة',
          '${stats.averageExpense.toStringAsFixed(2)} ر.س',
          Colors.orange,
          Icons.trending_up,
        ),
      ],
    );
  }

  Widget _buildStatItem(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
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
      ),
    );
  }

  Widget _buildProfitIndicator(ProfitEntity profit) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: profit.isProfit ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: profit.isProfit ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profit.isProfit ? 'فائض' : 'عجز',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: profit.isProfit ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${profit.profit.toStringAsFixed(2)} ر.س',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: profit.isProfit ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          Icon(
            profit.isProfit ? Icons.arrow_upward : Icons.arrow_downward,
            color: profit.isProfit ? Colors.green : Colors.red,
            size: 24,
          ),
        ],
      ),
    );
  }
}

class _LoadingStatsCard extends StatelessWidget {
  const _LoadingStatsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          Row(
            children: [
              _buildLoadingStatItem(),
              const SizedBox(width: 12),
              _buildLoadingStatItem(),
              const SizedBox(width: 12),
              _buildLoadingStatItem(),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 16,
                      child: ColoredBox(color: Colors.grey),
                    ),
                    SizedBox(height: 4),
                    SizedBox(
                      width: 80,
                      height: 20,
                      child: ColoredBox(color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: ColoredBox(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingStatItem() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: ColoredBox(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const SizedBox(
              width: double.infinity,
              height: 12,
              child: ColoredBox(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            const SizedBox(
              width: double.infinity,
              height: 14,
              child: ColoredBox(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
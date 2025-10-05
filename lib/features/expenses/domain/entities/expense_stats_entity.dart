// features/expenses/domain/entities/expense_stats_entity.dart
class ExpenseStatsEntity {
  final double totalExpenses;
  final double todayExpenses;
  final double monthlyExpenses;
  final int expensesCount;

  const ExpenseStatsEntity({
    required this.totalExpenses,
    required this.todayExpenses,
    required this.monthlyExpenses,
    required this.expensesCount,
  });
}
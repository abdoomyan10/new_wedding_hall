// features/expenses/presentation/cubit/expense_state.dart
import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/expense_stats_entity.dart';
import '../../domain/entities/profit_entity.dart';

abstract class ExpenseState {
  final List<ExpenseEntity> expenses;
  final ExpenseStatsEntity? stats;
  final ProfitEntity? profit;

  const ExpenseState({
    required this.expenses,
    this.stats,
    this.profit,
  });
}

class ExpenseInitial extends ExpenseState {
  const ExpenseInitial() : super(expenses: const []);
}

class ExpenseLoading extends ExpenseState {
  const ExpenseLoading({required List<ExpenseEntity> expenses})
      : super(expenses: expenses);
}

class ExpenseLoaded extends ExpenseState {
  const ExpenseLoaded({
    required List<ExpenseEntity> expenses,
    required ExpenseStatsEntity stats,
    ProfitEntity? profit,
  }) : super(expenses: expenses, stats: stats, profit: profit);

  // يمكن إضافة filteredStats إذا كان هناك تصفية
  ExpenseStatsEntity get filteredStats => stats!;
}

class ExpenseError extends ExpenseState {
  final String message;

  const ExpenseError({
    required this.message,
    required List<ExpenseEntity> expenses,
  }) : super(expenses: expenses);
}
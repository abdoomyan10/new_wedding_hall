// features/expenses/presentation/cubit/expense_state.dart
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/expense_stats_entity.dart';
import '../../domain/entities/profit_entity.dart';

@immutable
abstract class ExpenseState extends Equatable {
  final List<ExpenseEntity> expenses;
  final ExpenseStatsEntity? stats;
  final ProfitEntity? profit;
  final String? filterCategory;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;

  const ExpenseState({
    this.expenses = const [],
    this.stats,
    this.profit,
    this.filterCategory,
    this.filterStartDate,
    this.filterEndDate,
  });

  @override
  List<Object?> get props => [
    expenses,
    stats,
    profit,
    filterCategory,
    filterStartDate,
    filterEndDate,
  ];
}

class ExpenseInitial extends ExpenseState {
  const ExpenseInitial() : super();
}

class ExpenseLoading extends ExpenseState {
  const ExpenseLoading({
    List<ExpenseEntity> expenses = const [],
    ExpenseStatsEntity? stats,
    ProfitEntity? profit,
  }) : super(expenses: expenses, stats: stats, profit: profit);
}

class ExpenseLoaded extends ExpenseState {
  const ExpenseLoaded({
    required List<ExpenseEntity> expenses,
    ExpenseStatsEntity? stats,
    ProfitEntity? profit,
    String? filterCategory,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
  }) : super(
    expenses: expenses,
    stats: stats,
    profit: profit,
    filterCategory: filterCategory,
    filterStartDate: filterStartDate,
    filterEndDate: filterEndDate,
  );

  List<ExpenseEntity> get filteredExpenses {
    List<ExpenseEntity> result = expenses;

    if (filterCategory != null && filterCategory!.isNotEmpty) {
      result = result.where((expense) => expense.category == filterCategory).toList();
    }

    if (filterStartDate != null) {
      result = result.where((expense) =>
          expense.date.isAfter(filterStartDate!.subtract(const Duration(days: 1)))
      ).toList();
    }

    if (filterEndDate != null) {
      result = result.where((expense) =>
          expense.date.isBefore(filterEndDate!.add(const Duration(days: 1)))
      ).toList();
    }

    return result;
  }

  ExpenseStatsEntity get filteredStats {
    final filtered = filteredExpenses;
    final totalExpenses = filtered.fold(0.0, (sum, expense) => sum + expense.amount);
    final todayExpenses = filtered
        .where((expense) => expense.date.day == DateTime.now().day &&
        expense.date.month == DateTime.now().month &&
        expense.date.year == DateTime.now().year)
        .fold(0.0, (sum, expense) => sum + expense.amount);
    final monthlyExpenses = filtered
        .where((expense) => expense.date.month == DateTime.now().month &&
        expense.date.year == DateTime.now().year)
        .fold(0.0, (sum, expense) => sum + expense.amount);

    return ExpenseStatsEntity(
      totalExpenses: totalExpenses,
      todayExpenses: todayExpenses,
      monthlyExpenses: monthlyExpenses,
      expensesCount: filtered.length,
    );
  }
}

class ExpenseError extends ExpenseState {
  final String message;

  const ExpenseError(
      this.message, {
        List<ExpenseEntity> expenses = const [],
        ExpenseStatsEntity? stats,
        ProfitEntity? profit,
      }) : super(expenses: expenses, stats: stats, profit: profit);

  @override
  List<Object?> get props => [message, ...super.props];
}

class ExpensePdfGenerating extends ExpenseState {
  const ExpensePdfGenerating({
    required List<ExpenseEntity> expenses,
    ExpenseStatsEntity? stats,
    ProfitEntity? profit,
  }) : super(expenses: expenses, stats: stats, profit: profit);
}

class ExpensePdfGenerated extends ExpenseState {
  final String filePath;

  const ExpensePdfGenerated({
    required this.filePath,
    required List<ExpenseEntity> expenses,
    ExpenseStatsEntity? stats,
    ProfitEntity? profit,
  }) : super(expenses: expenses, stats: stats, profit: profit);

  @override
  List<Object?> get props => [filePath, ...super.props];
}
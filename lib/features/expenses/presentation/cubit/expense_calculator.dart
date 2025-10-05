// features/expenses/presentation/cubit/expense_calculator.dart
import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/expense_stats_entity.dart';
import '../../domain/entities/profit_entity.dart';

class ExpenseCalculator {
  // حساب إحصائيات التكاليف
  static ExpenseStatsEntity calculateStats(List<ExpenseEntity> expenses) {
    final totalExpenses = expenses.fold(0.0, (sum, expense) => sum + expense.amount);

    final todayExpenses = expenses
        .where((expense) => _isSameDay(expense.date, DateTime.now()))
        .fold(0.0, (sum, expense) => sum + expense.amount);

    final monthlyExpenses = expenses
        .where((expense) => expense.date.month == DateTime.now().month &&
        expense.date.year == DateTime.now().year)
        .fold(0.0, (sum, expense) => sum + expense.amount);

    return ExpenseStatsEntity(
      totalExpenses: totalExpenses,
      todayExpenses: todayExpenses,
      monthlyExpenses: monthlyExpenses,
      expensesCount: expenses.length,
    );
  }

  // حساب الفائض
  static Future<ProfitEntity> calculateProfit(double totalRevenue, double totalExpenses) async {
    return ProfitEntity.calculate(
      totalRevenue: totalRevenue,
      totalExpenses: totalExpenses,
    );
  }

  // الحصول على التكاليف حسب الفئة
  static Map<String, double> getExpensesByCategory(List<ExpenseEntity> expenses) {
    final Map<String, double> categoryTotals = {};

    for (final expense in expenses) {
      categoryTotals.update(
        expense.category,
            (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    return categoryTotals;
  }

  // الحصول على التكاليف الشهرية
  static Map<String, double> getMonthlyExpenses(List<ExpenseEntity> expenses) {
    final Map<String, double> monthlyTotals = {};

    for (final expense in expenses) {
      final monthKey = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      monthlyTotals.update(
        monthKey,
            (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    return monthlyTotals;
  }

  // تصفية التكاليف
  static List<ExpenseEntity> filterExpenses({
    required List<ExpenseEntity> expenses,
    String? searchQuery,
  }) {
    if (searchQuery == null || searchQuery.isEmpty) {
      return expenses;
    }

    return expenses.where((expense) =>
    expense.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
        expense.workerName.toLowerCase().contains(searchQuery.toLowerCase()) ||
        expense.category.toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();
  }

  // التحقق من أن التاريخين في نفس اليوم
  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
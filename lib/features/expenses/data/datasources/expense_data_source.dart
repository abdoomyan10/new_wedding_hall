// features/expenses/data/datasources/expense_data_source.dart
import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/expense_stats_entity.dart';

abstract class ExpenseDataSource {
  Future<List<ExpenseEntity>> getExpenses();
  Future<void> addExpense(ExpenseEntity expense);
  Future<void> deleteExpense(String expenseId);
  Future<ExpenseStatsEntity> getExpenseStats();
}

class ExpenseLocalDataSource implements ExpenseDataSource {
  static List<ExpenseEntity> _expenses = [];

  // دالة لتهيئة البيانات التجريبية
  static void _initializeSampleData() {
    if (_expenses.isEmpty) {
      _expenses = [
        ExpenseEntity(
          id: '1',
          title: 'شراء مواد تنظيف',
          description: 'مواد تنظيف للقاعة الرئيسية',
          amount: 250.0,
          date: DateTime.now().subtract(const Duration(days: 2)),
          workerName: 'أحمد محمد',
          category: 'صيانة',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        ExpenseEntity(
          id: '2',
          title: 'إصلاح كراسي',
          description: 'إصلاح 10 كراسي مكسورة',
          amount: 150.0,
          date: DateTime.now().subtract(const Duration(days: 5)),
          workerName: 'محمد علي',
          category: 'أثاث',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        ExpenseEntity(
          id: '3',
          title: 'فاتورة كهرباء',
          description: 'فاتورة الكهرباء للشهر الحالي',
          amount: 800.0,
          date: DateTime.now().subtract(const Duration(days: 10)),
          workerName: 'فريق الصيانة',
          category: 'مرافق',
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
        ExpenseEntity(
          id: '4',
          title: 'رواتب العمال',
          description: 'رواتب العمال للأسبوع الحالي',
          amount: 2000.0,
          date: DateTime.now().subtract(const Duration(days: 1)),
          workerName: 'إدارة الموارد البشرية',
          category: 'رواتب',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        ExpenseEntity(
          id: '5',
          title: 'تجهيز حفل',
          description: 'تكاليف تجهيز حفل زفاف',
          amount: 1200.0,
          date: DateTime.now(),
          workerName: 'فريق التجهيز',
          category: 'حفلات',
          createdAt: DateTime.now(),
        ),
      ];
    }
  }

  @override
  Future<List<ExpenseEntity>> getExpenses() async {
    // محاكاة تأخير الشبكة
    await Future.delayed(const Duration(milliseconds: 500));

    // تهيئة البيانات التجريبية إذا كانت فارغة
    _initializeSampleData();

    // إرجاع نسخة من القائمة لتجنب التعديل المباشر
    return List.from(_expenses);
  }

  @override
  Future<void> addExpense(ExpenseEntity expense) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // التأكد من أن المعرف فريد
    final newExpense = ExpenseEntity(
      id: expense.id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : expense.id,
      title: expense.title,
      description: expense.description,
      amount: expense.amount,
      date: expense.date,
      workerName: expense.workerName,
      category: expense.category,
      createdAt: expense.createdAt,
    );

    _expenses.add(newExpense);
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _expenses.removeWhere((expense) => expense.id == expenseId);
  }

  @override
  Future<ExpenseStatsEntity> getExpenseStats() async {
    await Future.delayed(const Duration(milliseconds: 400));

    // التأكد من وجود البيانات
    _initializeSampleData();

    final totalExpenses = _expenses.fold(0.0, (sum, expense) => sum + expense.amount);

    final todayExpenses = _expenses
        .where((expense) =>
    expense.date.year == DateTime.now().year &&
        expense.date.month == DateTime.now().month &&
        expense.date.day == DateTime.now().day)
        .fold(0.0, (sum, expense) => sum + expense.amount);

    final monthlyExpenses = _expenses
        .where((expense) =>
    expense.date.year == DateTime.now().year &&
        expense.date.month == DateTime.now().month)
        .fold(0.0, (sum, expense) => sum + expense.amount);

    return ExpenseStatsEntity(
      totalExpenses: totalExpenses,
      todayExpenses: todayExpenses,
      monthlyExpenses: monthlyExpenses,
      expensesCount: _expenses.length,
    );
  }
}
// features/expenses/presentation/cubit/expense_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:printing/printing.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/expense_stats_entity.dart';
import '../../domain/entities/profit_entity.dart';
import '../../domain/usecases/add_expense_usecase.dart';
import '../../domain/usecases/get_expense_usecase.dart';
import '../../domain/usecases/delete_expense_usecase.dart';
import '../../domain/usecases/get_expense_stats_usecase.dart';
import 'expense_pdf_service.dart';
import 'expense_calculator.dart';
import 'expense_state.dart';

class ExpenseCubit extends Cubit<ExpenseState> {
  final GetExpensesUseCase getExpensesUseCase;
  final AddExpenseUseCase addExpenseUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;
  final GetExpenseStatsUseCase getExpenseStatsUseCase;

  static const double totalRevenue = 15000.0;

  ExpenseCubit({
    required this.getExpensesUseCase,
    required this.addExpenseUseCase,
    required this.deleteExpenseUseCase,
    required this.getExpenseStatsUseCase,
  }) : super(ExpenseInitial());

  // تحميل التكاليف
  Future<void> loadExpenses() async {
    try {
      emit(ExpenseLoading(
        expenses: state.expenses,
        stats: state.stats,
        profit: state.profit,
      ));

      final result = await getExpensesUseCase();

      result.fold(
            (failure) {
          // حتى في حالة الفشل، نعرض البيانات السابقة إذا كانت موجودة
          if (state.expenses.isNotEmpty) {
            emit(ExpenseLoaded(
              expenses: state.expenses,
              stats: state.stats,
              profit: state.profit,
              filterCategory: state.filterCategory,
              filterStartDate: state.filterStartDate,
              filterEndDate: state.filterEndDate,
            ));
          } else {
            emit(ExpenseError(
              failure.message,
              expenses: state.expenses,
              stats: state.stats,
              profit: state.profit,
            ));
          }
        },
            (expenses) async {
          final stats = ExpenseCalculator.calculateStats(expenses);
          final profit = await ExpenseCalculator.calculateProfit(totalRevenue, stats.totalExpenses);

          emit(ExpenseLoaded(
            expenses: expenses,
            stats: stats,
            profit: profit,
            filterCategory: state.filterCategory,
            filterStartDate: state.filterStartDate,
            filterEndDate: state.filterEndDate,
          ));
        },
      );
    } catch (e) {
      // حتى في حالة الخطأ، نعرض البيانات السابقة إذا كانت موجودة
      if (state.expenses.isNotEmpty) {
        emit(ExpenseLoaded(
          expenses: state.expenses,
          stats: state.stats,
          profit: state.profit,
          filterCategory: state.filterCategory,
          filterStartDate: state.filterStartDate,
          filterEndDate: state.filterEndDate,
        ));
      } else {
        emit(ExpenseError(
          e.toString(),
          expenses: state.expenses,
          stats: state.stats,
          profit: state.profit,
        ));
      }
    }
  }

  // إضافة تكلفة جديدة
  Future<void> addExpense(ExpenseEntity expense) async {
    try {
      final result = await addExpenseUseCase(expense);

      result.fold(
            (failure) => emit(ExpenseError(
          failure.message,
          expenses: state.expenses,
          stats: state.stats,
          profit: state.profit,
        )),
            (_) => loadExpenses(),
      );
    } catch (e) {
      emit(ExpenseError(
        e.toString(),
        expenses: state.expenses,
        stats: state.stats,
        profit: state.profit,
      ));
    }
  }

  // حذف تكلفة
  Future<void> deleteExpense(String expenseId) async {
    try {
      final result = await deleteExpenseUseCase(expenseId);

      result.fold(
            (failure) => emit(ExpenseError(
          failure.message,
          expenses: state.expenses,
          stats: state.stats,
          profit: state.profit,
        )),
            (_) => loadExpenses(),
      );
    } catch (e) {
      emit(ExpenseError(
        e.toString(),
        expenses: state.expenses,
        stats: state.stats,
        profit: state.profit,
      ));
    }
  }

  // تطبيق الفلاتر
  void applyFilters({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
  }) {
    if (state is ExpenseLoaded) {
      final currentState = state as ExpenseLoaded;

      emit(ExpenseLoaded(
        expenses: currentState.expenses,
        stats: currentState.stats,
        profit: currentState.profit,
        filterCategory: category,
        filterStartDate: startDate,
        filterEndDate: endDate,
      ));
    }
  }

  // إعادة تعيين الفلاتر
  void resetFilters() {
    if (state is ExpenseLoaded) {
      final currentState = state as ExpenseLoaded;

      emit(ExpenseLoaded(
        expenses: currentState.expenses,
        stats: currentState.stats,
        profit: currentState.profit,
      ));
    }
  }

  // البحث في التكاليف
  Future<void> searchExpenses(String query) async {
    if (state is ExpenseLoaded) {
      final currentState = state as ExpenseLoaded;
      final filteredExpenses = ExpenseCalculator.filterExpenses(
        expenses: currentState.expenses,
        searchQuery: query.isNotEmpty ? query : null,
      );

      final stats = ExpenseCalculator.calculateStats(filteredExpenses);
      final profit = await ExpenseCalculator.calculateProfit(totalRevenue, stats.totalExpenses);

      emit(ExpenseLoaded(
        expenses: filteredExpenses,
        stats: stats,
        profit: profit,
        filterCategory: currentState.filterCategory,
        filterStartDate: currentState.filterStartDate,
        filterEndDate: currentState.filterEndDate,
      ));
    }
  }

  // إنشاء تقرير PDF
  Future<void> generatePdfReport() async {
    if (state is! ExpenseLoaded) return;

    try {
      final currentState = state as ExpenseLoaded;

      emit(ExpensePdfGenerating(
        expenses: currentState.expenses,
        stats: currentState.stats,
        profit: currentState.profit,
      ));

      final pdf = await ExpensePdfService.generateExpenseReport(
        expenses: currentState.filteredExpenses,
        stats: currentState.filteredStats,
        profit: currentState.profit!,
        startDate: currentState.filterStartDate,
        endDate: currentState.filterEndDate,
        filterCategory: currentState.filterCategory,
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
      );

      emit(ExpensePdfGenerated(
        filePath: 'expense_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
        expenses: currentState.expenses,
        stats: currentState.stats,
        profit: currentState.profit,
      ));

      // العودة للحالة الأصلية بعد ثانية
      await Future.delayed(const Duration(seconds: 1));
      emit(ExpenseLoaded(
        expenses: currentState.expenses,
        stats: currentState.stats,
        profit: currentState.profit,
        filterCategory: currentState.filterCategory,
        filterStartDate: currentState.filterStartDate,
        filterEndDate: currentState.filterEndDate,
      ));
    } catch (e) {
      emit(ExpenseError(
        'فشل في إنشاء التقرير: $e',
        expenses: state.expenses,
        stats: state.stats,
        profit: state.profit,
      ));
    }
  }

  // تحديث إحصائيات الفائض
  Future<void> updateProfitCalculation(double newTotalRevenue) async {
    if (state is ExpenseLoaded) {
      final currentState = state as ExpenseLoaded;
      final newProfit = await ExpenseCalculator.calculateProfit(
          newTotalRevenue,
          currentState.stats?.totalExpenses ?? 0.0
      );

      emit(ExpenseLoaded(
        expenses: currentState.expenses,
        stats: currentState.stats,
        profit: newProfit,
        filterCategory: currentState.filterCategory,
        filterStartDate: currentState.filterStartDate,
        filterEndDate: currentState.filterEndDate,
      ));
    }
  }

  // الحصول على التكاليف المصنفة حسب الفئة
  Map<String, double> getExpensesByCategory() {
    return ExpenseCalculator.getExpensesByCategory(state.expenses);
  }

  // الحصول على التكاليف الشهرية
  Map<String, double> getMonthlyExpenses() {
    return ExpenseCalculator.getMonthlyExpenses(List.from(Iterable.empty()));
  }
}
// features/expenses/presentation/pages/expenses_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/expense_cubit.dart';
import '../widegts/add_expense_dialog.dart';
import '../widegts/expenses_list.dart';
import '../widegts/expenses_stats_card.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<ExpenseCubit>()..loadExpenses(),
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: const _ExpensesBody(),
        floatingActionButton: _buildFloatingActionButton(context),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'إدارة التكاليف',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      backgroundColor: Colors.blue.shade700,
      foregroundColor: Colors.white,
      elevation: 2,
      actions: [
        IconButton(
          icon: const Icon(Icons.picture_as_pdf),
          tooltip: 'تصدير تقرير PDF',
          onPressed: () => _generatePdfReport(context),
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'تحديث البيانات',
          onPressed: () => context.read<ExpenseCubit>().loadExpenses(),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddExpenseDialog(context),
      backgroundColor: Colors.blue.shade700,
      foregroundColor: Colors.white,
      child: const Icon(Icons.add, size: 28),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddExpenseDialog(),
    );
  }

  void _generatePdfReport(BuildContext context) {
    // سيتم نقله لـ PDF Report Generator
    context.read<ExpenseCubit>().generatePdfReport();
  }
}

class _ExpensesBody extends StatelessWidget {
  const _ExpensesBody();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        // بطاقة الإحصائيات
        ExpenseStatsCard(),

        // فاصل
        Divider(height: 1, thickness: 1),

        // عنوان القائمة
        _ExpensesListHeader(),

        // قائمة التكاليف
        Expanded(child: ExpenseList()),
      ],
    );
  }
}

class _ExpensesListHeader extends StatelessWidget {
  const _ExpensesListHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.grey.shade50,
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'التكلفة',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'المبلغ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'التاريخ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          SizedBox(width: 48), // مساحة لأيقونة الحذف
        ],
      ),
    );
  }
}
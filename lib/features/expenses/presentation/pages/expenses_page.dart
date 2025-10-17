// features/expenses/presentation/pages/expenses_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/expense_cubit.dart';

import '../widegts/add_expense_dialog.dart';
import '../widegts/expenses_list.dart';
import '../widegts/expenses_stats_card.dart';
import 'saved_reports_page.dart';

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
        // زر التقارير المحفوظة
        IconButton(
          icon: const Icon(Icons.folder),
          tooltip: 'التقارير المحفوظة',
          onPressed: () => _navigateToSavedReports(context),
        ),
        // زر تصدير PDF مع حفظ على الجهاز
        PopupMenuButton<String>(
          icon: const Icon(Icons.picture_as_pdf),
          tooltip: 'تصدير PDF',
          onSelected: (value) {
            if (value == 'save_report') {
              _savePdfReport(context);
            } else if (value == 'print_report') {
              _printPdfReport(context);
            } else if (value == 'saved_reports') {
              _navigateToSavedReports(context);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'save_report',
              child: Row(
                children: [
                  Icon(Icons.save, color: Colors.green),
                  SizedBox(width: 8),
                  Text('حفظ PDF على الجهاز'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'print_report',
              child: Row(
                children: [
                  Icon(Icons.print, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('طباعة مباشرة'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'saved_reports',
              child: Row(
                children: [
                  Icon(Icons.folder_open, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('التقارير المحفوظة'),
                ],
              ),
            ),
          ],
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

  void _savePdfReport(BuildContext context) {
    context.read<ExpenseCubit>().generateAndSavePdfReport();

    // إظهار رسالة تأكيد
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('جاري حفظ تقرير PDF...'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _printPdfReport(BuildContext context) {
    context.read<ExpenseCubit>().generatePdfReport();

    // إظهار رسالة تأكيد
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('جاري إعداد التقرير للطباعة...'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToSavedReports(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SavedReportsPage()),
    );
  }
}

class _ExpensesBody extends StatelessWidget {
  const _ExpensesBody();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ExpenseStatsCard(),
        Divider(height: 1, thickness: 1),
        _ExpensesListHeader(),
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
          SizedBox(width: 48),
        ],
      ),
    );
  }
}
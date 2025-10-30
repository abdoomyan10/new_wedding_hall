// features/expenses/presentation/widgets/expenses_list.dart

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/expense_entity.dart';

import '../cubit/expense_cubit.dart';

import '../cubit/expense_state.dart';

import 'expense_details_dialog.dart';

import 'expense_item.dart';



class ExpenseList extends StatelessWidget {

  const ExpenseList({super.key});



  @override

  Widget build(BuildContext context) {

    return BlocBuilder<ExpenseCubit, ExpenseState>(

      builder: (context, state) {

        // حالة التحميل الأولي فقط

        if (state is ExpenseLoading && state.expenses.isEmpty) {

          return _buildLoadingState();

        }



        // حالة الخطأ

        if (state is ExpenseError) {

          return _buildErrorState(context, state.message);

        }



        // في جميع الحالات الأخرى، عرض البيانات المتاحة

        final expenses = state.expenses;



        if (expenses.isEmpty) {

          return _buildEmptyState();

        }



        return _buildExpensesList(expenses, context);

      },

    );

  }



  Widget _buildExpensesList(List<ExpenseEntity> expenses, BuildContext context) {

    return ListView.builder(

      itemCount: expenses.length,

      padding: const EdgeInsets.only(bottom: 80),

      itemBuilder: (context, index) {

        final expense = expenses[index];

        return ExpenseItem(

          expense: expense,

          onDelete: () => _deleteExpense(context, expense),

          onTap: () => _showExpenseDetails(context, expense),

          onGeneratePdf: () => _generateSingleExpensePdf(context, expense),

        );

      },

    );

  }



  Widget _buildLoadingState() {

    return const Center(

      child: Column(

        mainAxisAlignment: MainAxisAlignment.center,

        children: [

          CircularProgressIndicator(),

          SizedBox(height: 16),

          Text('جاري تحميل التكاليف...'),

        ],

      ),

    );

  }



  Widget _buildErrorState(BuildContext context, String message) {

    return Center(

      child: Padding(

        padding: const EdgeInsets.all(20.0),

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Icon(

              Icons.error_outline,

              size: 64,

              color: Colors.red,

            ),

            const SizedBox(height: 16),

            const Text(

              'حدث خطأ',

              style: TextStyle(

                fontSize: 18,

                fontWeight: FontWeight.bold,

                color: Colors.red,

              ),

            ),

            const SizedBox(height: 8),

            Text(

              message,

              textAlign: TextAlign.center,

              style: const TextStyle(fontSize: 14),

            ),

            const SizedBox(height: 16),

            ElevatedButton(

              onPressed: () {

                context.read<ExpenseCubit>().loadExpenses();

              },

              child: const Text('إعادة المحاولة'),

            ),

          ],

        ),

      ),

    );

  }



  Widget _buildEmptyState() {

    return Center(

      child: Column(

        mainAxisAlignment: MainAxisAlignment.center,

        children: [

          Icon(

            Icons.money_off,

            size: 80,

            color: Colors.grey.shade400,

          ),

          const SizedBox(height: 16),

          const Text(

            'لا توجد تكاليف',

            style: TextStyle(

              fontSize: 18,

              fontWeight: FontWeight.bold,

              color: Colors.grey,

            ),

          ),

          const SizedBox(height: 8),

          Text(

            'انقر على زر + لإضافة تكلفة جديدة',

            style: TextStyle(

              fontSize: 14,

              color: Colors.grey.shade600,

            ),

          ),

        ],

      ),

    );

  }



  void _deleteExpense(BuildContext context, ExpenseEntity expense) {

    context.read<ExpenseCubit>().deleteExpense(expense.id);

  }



  void _showExpenseDetails(BuildContext context, ExpenseEntity expense) {

    showDialog(

      context: context,

      builder: (context) => ExpenseDetailsDialog(expense: expense),

    );

  }



  void _generateSingleExpensePdf(BuildContext context, ExpenseEntity expense) {

    context.read<ExpenseCubit>().generateSingleExpensePdf(expense);

  }

}




import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';

import '../../domain/entities/expense_entity.dart';
import '../cubit/expense_cubit.dart';

class ExpenseItem extends StatelessWidget {

  final ExpenseEntity expense;

  final VoidCallback onDelete;

  final VoidCallback onTap;

  final VoidCallback onGeneratePdf;



  const ExpenseItem({

    super.key,

    required this.expense,

    required this.onDelete,

    required this.onTap,

    required this.onGeneratePdf,

  });



  @override

  Widget build(BuildContext context) {

    return Card(

      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      elevation: 2,

      child: ListTile(

        leading: _buildAmountIndicator(),

        title: Text(

          expense.description,

          style: const TextStyle(fontWeight: FontWeight.bold),

          maxLines: 1,

          overflow: TextOverflow.ellipsis,

        ),

        subtitle: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text('${expense.category} - ${_formatDate(expense.date)}'),

            Text(

              'العامل: ${expense.workerName}',

              style: const TextStyle(fontSize: 12, color: Colors.grey),

            ),

          ],

        ),

        trailing: _buildTrailingButtons(context),

        onTap: onTap,

      ),

    );

  }



  Widget _buildAmountIndicator() {

    return Container(

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(

        color: _getAmountColor(),

        shape: BoxShape.circle,

      ),

      child: Text(

        '${expense.amount.toStringAsFixed(0)} ر.س',

        style: TextStyle(

          color: _getTextColor(),

          fontWeight: FontWeight.bold,

          fontSize: 12,

        ),

      ),

    );

  }



  Color _getAmountColor() {

    if (expense.amount < 100) {

      return Colors.green.shade50;

    } else if (expense.amount < 500) {

      return Colors.orange.shade50;

    } else {

      return Colors.red.shade50;

    }

  }



  Color _getTextColor() {

    if (expense.amount < 100) {

      return Colors.green.shade700;

    } else if (expense.amount < 500) {

      return Colors.orange.shade700;

    } else {

      return Colors.red.shade700;

    }

  }



  Widget _buildTrailingButtons(BuildContext context) {

    return PopupMenuButton<String>(

      icon: const Icon(Icons.more_vert, color: Colors.grey),

      itemBuilder: (context) => [

        PopupMenuItem(

          value: 'details',

          child: Row(

            children: [

              Icon(Icons.info, color: Colors.blue.shade700),

              const SizedBox(width: 8),

              const Text('تفاصيل'),

            ],

          ),

        ),

        PopupMenuItem(

          value: 'save_pdf',

          child: Row(

            children: [

              Icon(Icons.save, color: Colors.green.shade700),

              const SizedBox(width: 8),

              const Text('حفظ PDF'),

            ],

          ),

        ),

        PopupMenuItem(

          value: 'print_pdf',

          child: Row(

            children: [

              Icon(Icons.print, color: Colors.blue.shade700),

              const SizedBox(width: 8),

              const Text('طباعة PDF'),

            ],

          ),

        ),

        const PopupMenuDivider(),

        PopupMenuItem(

          value: 'delete',

          child: Row(

            children: [

              Icon(Icons.delete, color: Colors.red.shade700),

              const SizedBox(width: 8),

              const Text('حذف'),

            ],

          ),

        ),

      ],

      onSelected: (value) {

        switch (value) {

          case 'details':

            onTap();

            break;

          case 'save_pdf':

            _generateAndSavePdf(context);

            break;

          case 'print_pdf':

            _generateAndPrintPdf(context);

            break;

          case 'delete':

            _showDeleteConfirmation(context);

            break;

        }

      },

    );

  }



  void _generateAndSavePdf(BuildContext context) {

    context.read<ExpenseCubit>().generateAndSaveSingleExpensePdf(expense);



    // إظهار رسالة تأكيد

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(

        content: const Text('تم حفظ التكلفة كملف PDF على جهازك'),

        backgroundColor: Colors.green,

        behavior: SnackBarBehavior.floating,

        duration: const Duration(seconds: 3),

      ),

    );

  }



  void _generateAndPrintPdf(BuildContext context) {

    context.read<ExpenseCubit>().generateSingleExpensePdf(expense);



    // إظهار رسالة تأكيد

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(

        content: const Text('جاري إعداد التكلفة للطباعة'),

        backgroundColor: Colors.blue,

        behavior: SnackBarBehavior.floating,

        duration: const Duration(seconds: 2),

      ),

    );

  }



  void _showDeleteConfirmation(BuildContext context) {

    showDialog(

      context: context,

      builder: (context) => AlertDialog(

        title: const Row(

          children: [

            Icon(Icons.warning, color: Colors.orange),

            SizedBox(width: 8),

            Text('تأكيد الحذف'),

          ],

        ),

        content: Column(

          mainAxisSize: MainAxisSize.min,

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(

              'هل أنت متأكد من حذف التكلفة التالية؟',

              style: Theme.of(context).textTheme.bodyMedium,

            ),

            const SizedBox(height: 8),

            Container(

              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(

                color: Colors.grey.shade100,

                borderRadius: BorderRadius.circular(8),

              ),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(

                    expense.description,

                    style: const TextStyle(

                      fontWeight: FontWeight.bold,

                      fontSize: 14,

                    ),

                  ),

                  const SizedBox(height: 4),

                  Text(

                    '${expense.amount.toStringAsFixed(2)} ر.س - ${expense.category}',

                    style: TextStyle(

                      color: Colors.grey.shade600,

                      fontSize: 12,

                    ),

                  ),

                  const SizedBox(height: 4),

                  Text(

                    'العامل: ${expense.workerName}',

                    style: TextStyle(

                      color: Colors.grey.shade600,

                      fontSize: 12,

                    ),

                  ),

                ],

              ),

            ),

            const SizedBox(height: 8),

            Text(

              'لا يمكن التراجع عن هذا الإجراء.',

              style: TextStyle(

                color: Colors.red.shade700,

                fontSize: 12,

                fontWeight: FontWeight.bold,

              ),

            ),

          ],

        ),

        actions: [

          TextButton(

            onPressed: () => Navigator.pop(context),

            child: const Text('إلغاء'),

          ),

          ElevatedButton(

            onPressed: () {

              Navigator.pop(context);

              onDelete();



              // إظهار رسالة نجاح الحذف

              ScaffoldMessenger.of(context).showSnackBar(

                SnackBar(

                  content: const Text('تم حذف التكلفة بنجاح'),

                  backgroundColor: Colors.green,

                  behavior: SnackBarBehavior.floating,

                  duration: const Duration(seconds: 2),

                ),

              );

            },

            style: ElevatedButton.styleFrom(

              backgroundColor: Colors.red.shade700,

              foregroundColor: Colors.white,

            ),

            child: const Text('حذف'),

          ),

        ],

      ),

    );

  }



  String _formatDate(DateTime date) {

    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  }

}
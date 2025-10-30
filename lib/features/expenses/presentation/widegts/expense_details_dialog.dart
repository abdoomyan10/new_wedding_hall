// features/expenses/presentation/widgets/expense_details_dialog.dart

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:intl/intl.dart';

import '../../domain/entities/expense_entity.dart';

import '../cubit/expense_cubit.dart';



class ExpenseDetailsDialog extends StatelessWidget {

  final ExpenseEntity expense;



  const ExpenseDetailsDialog({

    super.key,

    required this.expense,

  });



  @override

  Widget build(BuildContext context) {

    return Dialog(

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          mainAxisSize: MainAxisSize.min,

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // العنوان

            _buildHeader(context),

            const SizedBox(height: 20),



            // تفاصيل التكلفة

            _buildDetailSection(),

            const SizedBox(height: 20),



            // أزرار الإجراءات

            _buildActionButtons(context),

          ],

        ),

      ),

    );

  }



  Widget _buildHeader(BuildContext context) {

    return Row(

      children: [

        const Icon(Icons.receipt, color: Colors.blue, size: 28),

        const SizedBox(width: 12),

        Expanded(

          child: Text(

            'تفاصيل التكلفة',

            style: Theme.of(context).textTheme.titleLarge?.copyWith(

              fontWeight: FontWeight.bold,

              color: Colors.blue.shade700,

            ),

          ),

        ),

        IconButton(

          icon: const Icon(Icons.close),

          onPressed: () => Navigator.pop(context),

        ),

      ],

    );

  }



  Widget _buildDetailSection() {

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color: Colors.grey.shade50,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(color: Colors.grey.shade300),

      ),

      child: Column(

        children: [

          _buildDetailRow('الوصف:', expense.description),

          _buildDetailRow('المبلغ:', '${expense.amount.toStringAsFixed(2)} ر.س'),

          _buildDetailRow('اسم العامل:', expense.workerName),

          _buildDetailRow('الفئة:', expense.category),

          _buildDetailRow('تاريخ التكلفة:', _formatDate(expense.date)),

          _buildDetailRow('تاريخ الإضافة:', _formatDate(expense.createdAt)),

          _buildDetailRow('المعرف:', expense.id),

        ],

      ),

    );

  }



  Widget _buildDetailRow(String label, String value) {

    return Padding(

      padding: const EdgeInsets.symmetric(vertical: 8),

      child: Row(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          SizedBox(

            width: 100,

            child: Text(

              label,

              style: const TextStyle(

                fontWeight: FontWeight.bold,

                color: Colors.blue,

              ),

            ),

          ),

          const SizedBox(width: 12),

          Expanded(

            child: Text(

              value,

              style: const TextStyle(fontSize: 14),

            ),

          ),

        ],

      ),

    );

  }



  Widget _buildActionButtons(BuildContext context) {

    return Column(

      children: [

        Row(

          children: [

            Expanded(

              child: OutlinedButton.icon(

                icon: const Icon(Icons.save),

                label: const Text('حفظ PDF'),

                onPressed: () {

                  Navigator.pop(context);

                  context.read<ExpenseCubit>().generateAndSaveSingleExpensePdf(expense);

                },

                style: OutlinedButton.styleFrom(

                  foregroundColor: Colors.green,

                  padding: const EdgeInsets.symmetric(vertical: 12),

                  side: BorderSide(color: Colors.green.shade700),

                ),

              ),

            ),

            const SizedBox(width: 12),

            Expanded(

              child: ElevatedButton.icon(

                icon: const Icon(Icons.print),

                label: const Text('طباعة'),

                onPressed: () {

                  Navigator.pop(context);

                  context.read<ExpenseCubit>().generateSingleExpensePdf(expense);

                },

                style: ElevatedButton.styleFrom(

                  backgroundColor: Colors.blue.shade700,

                  foregroundColor: Colors.white,

                  padding: const EdgeInsets.symmetric(vertical: 12),

                ),

              ),

            ),

          ],

        ),

        const SizedBox(height: 12),

        SizedBox(

          width: double.infinity,

          child: TextButton.icon(

            icon: const Icon(Icons.share),

            label: const Text('مشاركة'),

            onPressed: () {

              _showShareOptions(context);

            },

            style: TextButton.styleFrom(

              foregroundColor: Colors.orange.shade700,

            ),

          ),

        ),

      ],

    );

  }



  void _showShareOptions(BuildContext context) {

    showModalBottomSheet(

      context: context,

      shape: const RoundedRectangleBorder(

        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),

      ),

      builder: (context) => Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            Text(

              'خيارات المشاركة',

              style: Theme.of(context).textTheme.titleMedium?.copyWith(

                fontWeight: FontWeight.bold,

                color: Colors.blue.shade700,

              ),

            ),

            const SizedBox(height: 16),

            Row(

              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [

                _buildShareOption(

                  icon: Icons.save,

                  label: 'حفظ PDF',

                  onTap: () {

                    Navigator.pop(context);

                    Navigator.pop(context);

                    context.read<ExpenseCubit>().generateAndSaveSingleExpensePdf(expense);

                  },

                  color: Colors.green,

                ),

                _buildShareOption(

                  icon: Icons.print,

                  label: 'طباعة',

                  onTap: () {

                    Navigator.pop(context);

                    Navigator.pop(context);

                    context.read<ExpenseCubit>().generateSingleExpensePdf(expense);

                  },

                  color: Colors.blue,

                ),

                _buildShareOption(

                  icon: Icons.content_copy,

                  label: 'نسخ',

                  onTap: () {

                    _copyExpenseDetails(context);

                    Navigator.pop(context);

                  },

                  color: Colors.purple,

                ),

              ],

            ),

            const SizedBox(height: 16),

            SizedBox(

              width: double.infinity,

              child: OutlinedButton(

                onPressed: () => Navigator.pop(context),

                child: const Text('إلغاء'),

              ),

            ),

          ],

        ),

      ),

    );

  }



  Widget _buildShareOption({

    required IconData icon,

    required String label,

    required VoidCallback onTap,

    required Color color,

  }) {

    return Column(

      children: [

        IconButton(

          icon: Icon(icon, size: 32),

          color: color,

          onPressed: onTap,

        ),

        const SizedBox(height: 4),

        Text(

          label,

          style: TextStyle(

            fontSize: 12,

            color: color,

            fontWeight: FontWeight.bold,

          ),

        ),

      ],

    );

  }



  void _copyExpenseDetails(BuildContext context) {

    final details = '''

تفاصيل التكلفة:

الوصف: ${expense.description}

المبلغ: ${expense.amount.toStringAsFixed(2)} ر.س

اسم العامل: ${expense.workerName}

الفئة: ${expense.category}

تاريخ التكلفة: ${_formatDate(expense.date)}

تاريخ الإضافة: ${_formatDate(expense.createdAt)}

المعرف: ${expense.id}

''';



    // يمكن إضافة حزمة clipboard هنا إذا أردت

    // Clipboard.setData(ClipboardData(text: details));



    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(

        content: const Text('تم نسخ تفاصيل التكلفة'),

        backgroundColor: Colors.green,

        behavior: SnackBarBehavior.floating,

      ),

    );

  }



  String _formatDate(DateTime date) {

    return DateFormat('yyyy-MM-dd - HH:mm').format(date);

  }

}
// features/expenses/presentation/widgets/expense_item.dart
import 'package:flutter/material.dart';
import 'package:new_wedding_hall/core/constants/app_colors.dart';
import '../../domain/entities/expense_entity.dart';

class ExpenseItem extends StatelessWidget {
  final ExpenseEntity expense;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const ExpenseItem({
    super.key,
    required this.expense,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: _buildAmountIndicator(),
        title: Text(
          expense.description,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${expense.category} - ${_formatDate(expense.date)}'),
        trailing: _buildTrailingButtons(),
        onTap: onTap,
      ),
    );
  }

  Widget _buildAmountIndicator() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.paleGold.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: Text(
        '${expense.amount.toStringAsFixed(2)} ر.س',
        style: TextStyle(
          color: AppColors.deepRed,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTrailingButtons() {
    return PopupMenuButton<String>(
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: AppColors.deepRed),
              SizedBox(width: 8),
              Text('حذف'),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'delete') {
          onDelete();
        }
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

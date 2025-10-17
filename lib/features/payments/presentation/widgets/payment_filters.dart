// features/payments/presentation/widgets/payment_filters.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PaymentFilters extends StatelessWidget {
  const PaymentFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final statusFilters = [
      {'key': 'all', 'text': 'الكل', 'icon': Icons.all_inclusive},
      {'key': 'completed', 'text': 'مكتمل', 'icon': Icons.check_circle},
      {'key': 'pending', 'text': 'معلق', 'icon': Icons.pending},
      {'key': 'failed', 'text': 'فاشل', 'icon': Icons.error},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: AppColors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: statusFilters.map((filter) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                label: Text(filter['text'] as String),
                avatar: Icon(
                  filter['icon'] as IconData,
                  size: 16,
                  color: AppColors.paleGold,
                ),
                onSelected: (selected) {
                  // TODO: تطبيق التصفية حسب الحالة
                  if (filter['key'] == 'all') {
                    // context.read<PaymentCubit>().loadPayments();
                  }
                },
                backgroundColor: AppColors.gray200,
                selectedColor: AppColors.deepRed.withOpacity(0.08),
                labelStyle: const TextStyle(fontSize: 12),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

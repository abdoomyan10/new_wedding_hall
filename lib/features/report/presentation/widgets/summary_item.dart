// features/reports/presentation/widgets/summary_item.dart
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class SummaryItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const SummaryItem({
    super.key,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.deepRed),
        ),
      ],
    );
  }
}

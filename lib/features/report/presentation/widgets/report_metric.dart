import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class ReportMetric extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const ReportMetric({
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
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.deepRed),
        ),
      ],
    );
  }
}

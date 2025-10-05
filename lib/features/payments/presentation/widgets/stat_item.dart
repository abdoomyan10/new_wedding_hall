// features/payments/presentation/widgets/stat_item.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const StatItem({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.gray500,
          ),
        ),
      ],
    );
  }
}
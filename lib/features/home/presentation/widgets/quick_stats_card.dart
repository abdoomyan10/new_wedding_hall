// features/home/presentation/widgets/quick_stats_card.dart
import 'package:flutter/material.dart';
import 'package:new_wedding_hall/core/constants/app_colors.dart';
import '../../domain/entities/home_entity.dart';

class QuickStatsCard extends StatelessWidget {
  final HomeEntity homeData;

  const QuickStatsCard({super.key, required this.homeData});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.insights, color: AppColors.gold),
                SizedBox(width: 8),
                Text(
                  'نظرة سريعة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  icon: Icons.notifications,
                  value: homeData.unreadNotificationsCount.toString(),
                  label: 'إشعارات',
                  color: AppColors.gold,
                ),
                _StatItem(
                  icon: Icons.event,
                  value: '5',
                  label: 'حفلات هذا الأسبوع',
                  color: AppColors.paleGold,
                ),
                _StatItem(
                  icon: Icons.attach_money,
                  value: '25,000',
                  label: 'إيرادات الشهر',
                  color: AppColors.deepRed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

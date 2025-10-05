// features/home/presentation/widgets/upcoming_events_section.dart
import 'package:flutter/material.dart';

class UpcomingEventsSection extends StatelessWidget {
  final VoidCallback? onViewAll;

  const UpcomingEventsSection({super.key, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.upcoming, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'الحفلات القادمة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            UpcomingEventItem(
              eventName: 'زفاف أحمد وفاطمة',
              date: '2024-10-15',
              time: '07:00 مساءً',
              onTap: () {},
            ),
            UpcomingEventItem(
              eventName: 'خطوبة محمد وسارة',
              date: '2024-10-18',
              time: '06:00 مساءً',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class UpcomingEventItem extends StatelessWidget {
  final String eventName;
  final String date;
  final String time;
  final VoidCallback? onTap;

  const UpcomingEventItem({
    super.key,
    required this.eventName,
    required this.date,
    required this.time,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.event, color: Colors.purple, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eventName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$date - $time',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_left, color: Colors.grey[400]),
        ],
      ),
    );
  }
}
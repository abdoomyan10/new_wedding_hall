import 'package:flutter/material.dart';
import 'package:new_wedding_hall/core/constants/app_colors.dart';

class QuickActionsGrid extends StatelessWidget {
  final VoidCallback? onAddEvent;
  final VoidCallback? onClients;
  final VoidCallback? onPayments;
  final VoidCallback? onReports;

  const QuickActionsGrid({
    super.key,
    this.onAddEvent,
    this.onClients,
    this.onPayments,
    this.onReports,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        ActionButton(
          icon: Icons.add,
          title: 'إضافة حفلة',
          color: AppColors.gold,
          onTap: () {},
        ),
        ActionButton(
          icon: Icons.people,
          title: 'العملاء',
          color: AppColors.paleGold,
          onTap: () {},
        ),
        ActionButton(
          icon: Icons.attach_money,
          title: 'المدفوعات',
          color: AppColors.gold,
          onTap: () {},
        ),
        ActionButton(
          icon: Icons.bar_chart,
          title: 'التقارير',
          color: AppColors.deepRed,
          onTap: () {},
        ),
      ],
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;

  const ActionButton({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white, // الخلفية بيضاء كما في الأصل
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1), // نفس الشفافية والألوان
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24), // نفس لون الأيقونة
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // لون النص أسود
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

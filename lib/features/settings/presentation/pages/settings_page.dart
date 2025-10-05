import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: const Center(
        child: Text(
          "صفحة الإعدادات",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
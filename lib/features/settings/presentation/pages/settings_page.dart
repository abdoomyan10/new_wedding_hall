import 'package:flutter/material.dart';
import 'package:new_wedding_hall/core/constants/app_colors.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifications = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paleGold.withOpacity(0.1),
      appBar: AppBar(
        title: Text('الإعدادات'),
        backgroundColor: AppColors.deepRed,
        foregroundColor: AppColors.paleGold,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // قسم معلومات الحساب
          _buildSectionHeader('معلومات الحساب'),
          _buildAccountInfo(),
          SizedBox(height: 20),

          // قسم تسجيل الدخول
          _buildSectionHeader('تسجيل الدخول'),
          _buildLoginButton(),
          SizedBox(height: 20),

          // قسم التواصل
          _buildSectionHeader('التواصل والدعم'),
          _buildContactInfo(),
          SizedBox(height: 20),

          // قسم الإعدادات العامة
        ],
      ),
    );
  }

  // بناء رأس القسم
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.deepRed,
        ),
      ),
    );
  }

  // بناء قسم معلومات الحساب
  Widget _buildAccountInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.paleGold,
                child: Icon(Icons.person, color: AppColors.gold),
              ),
              title: Text('محمد أحمد', style: TextStyle(color: AppColors.gold)),
              subtitle: Text(
                'mohamed@example.com',
                style: TextStyle(color: AppColors.gold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بناء زر تسجيل الدخول
  Widget _buildLoginButton() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.logout, color: AppColors.deepRed),
              title: Text(
                'تسجيل الخروج',
                style: TextStyle(color: AppColors.gold),
              ),
              subtitle: Text(
                'انقر لتسجيل الخروج  ',
                style: TextStyle(color: AppColors.gold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بناء قسم التواصل
  Widget _buildContactInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildContactItem(Icons.phone, 'رقم الهاتف', '+966 50 123 4567'),
            Divider(),
            _buildContactItem(
              Icons.email,
              'البريد الإلكتروني',
              'support@app.com',
            ),
            Divider(),
            _buildContactItem(
              Icons.language,
              'الموقع الإلكتروني',
              'www.app.com',
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                _contactSupport();
              },
              icon: Icon(Icons.chat),
              label: Text('تواصل مع الدعم الفني'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepRed,
                foregroundColor: AppColors.paleGold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بناء عنصر التواصل
  Widget _buildContactItem(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: AppColors.deepRed),
      title: Text(title, style: TextStyle(color: AppColors.gold)),
      subtitle: Text(subtitle, style: TextStyle(color: AppColors.gold)),
      onTap: () {
        _showContactDialog(title, subtitle);
      },
    );
  }

  // بناء خيارات الإعدادات

  // الدوال المساعدة للتفاعلات

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تواصل مع الدعم الفني'),
        content: Text('سيتم فتح قناة اتصال مع فريق الدعم الفني'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('تواصل الآن'),
          ),
        ],
      ),
    );
  }

  void _showContactDialog(String title, String value) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(value),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('نسخ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('موافق'),
          ),
        ],
      ),
    );
  }
}

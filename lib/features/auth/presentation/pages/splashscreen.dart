import 'package:flutter/material.dart';
import 'loginscreen.dart';
import 'package:new_wedding_hall/core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(Duration(seconds: 4));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // keep scaffold background neutral; background image will cover
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Fullscreen background image
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),

          // Content overlay
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // شعار الصالة (يملأ الحاوية بشكل دائري، مع ظل، وخلفية شفافة)
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/mozhela.png',
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // اسم التطبيق
                Text(
                  'MOZHELA',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.paleGold,
                    fontFamily: 'Arial',
                  ),
                ),

                const SizedBox(height: 20),

                // وصف التطبيق
                Text(
                  'إدارة صالة الأعراس باحترافية',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 50),

                // مؤشر التحميل الثابت
                Container(
                  width: 100,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.paleGold.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Container(
                    width: 60, // عرض ثابت للتقدم
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

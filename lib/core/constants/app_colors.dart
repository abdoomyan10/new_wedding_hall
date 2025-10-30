import 'package:flutter/material.dart';

class AppColors {
  // Curved Navigation Bar Colors
  static const Color curvedNavBarBackground = Color(0xFF0066FF);
  static const Color curvedNavBarActiveColor = Color(0xFFFFFFFF);
  static const Color curvedNavBarInactiveColor = Color(0xFFB3D1FF);

  // Primary Colors
  static const Color primary = Color(0xFF0066FF);
  static const Color primaryDark = Color(0xFF0052CC);
  static const Color primaryLight = Color(0xFF4D94FF);

  // Brand / Wedding palette (centralized)
  static const Color deepRed = Color(0xFF8B0000); // 8B0000
  static const Color gold = Color(0xFFD4AF37); // D4AF37
  static const Color paleGold = Color(0xFFF4E3A3);
  static const Color gold1 = Color(0xFFB76E79); // B76E79

  // Secondary Colors
  static const Color secondary = Color(0xFF00C853);
  static const Color secondaryDark = Color(0xFF00A344);
  static const Color secondaryLight = Color(0xFF66FFA6);

  // Accent Colors
  static const Color accent = Color(0xFFFFAB00);
  static const Color accentDark = Color(0xFFCC8900);
  static const Color accentLight = Color(0xFFFFDD4D);

  // Neutral Colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);

  // Semantic Colors
  static const Color success = Color(0xFF00C853);
  static const Color successLight = Color(0xFF66FFA6);
  static const Color successDark = Color(0xFF00A344);

  static const Color warning = Color(0xFFFFAB00);
  static const Color warningLight = Color(0xFFFFDD4D);
  static const Color warningDark = Color(0xFFCC8900);

  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color errorDark = Color(0xFFC62828);

  static const Color info = Color(0xFF2979FF);
  static const Color infoLight = Color(0xFF448AFF);
  static const Color infoDark = Color(0xFF2962FF);

  // Background Colors
  static const Color scaffoldBackground = Color(0xFFFAFAFA);
  static const Color cardBackground = white;
  static const Color background = Color(0xFFFAFAFA);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFF9E9E9E);
  static const Color textInverse = white;

  // Border Colors
  static const Color borderLight = Color(0xFFEEEEEE);
  static const Color borderDark = Color(0xFFE0E0E0);

  // Overlay Colors
  static const Color overlayDark = Color(0x52000000);
  static const Color overlayLight = Color(0x0A000000);

  // Shadow Colors
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowMedium = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);

  // Gradient Colors
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const Gradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryLight],
  );

  // Chart Colors (للرسوم البيانية في التقارير)
  static const List<Color> chartColors = [
    Color(0xFF0066FF),
    Color(0xFF00C853),
    Color(0xFFFFAB00),
    Color(0xFFD32F2F),
    Color(0xFF2979FF),
    Color(0xFF7B1FA2),
    Color(0xFF0097A7),
    Color(0xFF689F38),
  ];

  // Report Specific Colors (ألوان مخصصة للتقارير)
  static const Color revenueColor = Color(0xFF00C853);
  static const Color expenseColor = Color(0xFFD32F2F);
  static const Color profitColor = Color(0xFF0066FF);
  static const Color marginColor = Color(0xFFFFAB00);
  static const Color eventsColor = Color(0xFF7B1FA2);
}

// امتداد لتسهيل الاستخدام مع Context
extension AppColorsExtension on BuildContext {
  // Primary Colors
  Color get primaryColor => AppColors.primary;
  Color get primaryDark => AppColors.primaryDark;
  Color get primaryLight => AppColors.primaryLight;

  // Semantic Colors
  Color get successColor => AppColors.success;
  Color get warningColor => AppColors.warning;
  Color get errorColor => AppColors.error;
  Color get infoColor => AppColors.info;

  // Background Colors
  Color get scaffoldBackground => AppColors.scaffoldBackground;
  Color get cardBackground => AppColors.cardBackground;

  // Text Colors
  Color get textPrimary => AppColors.textPrimary;
  Color get textSecondary => AppColors.textSecondary;

  // Convenience Methods
  Color get surfaceColor => AppColors.white;
  Color get onSurfaceColor => AppColors.black;

  bool get isDarkMode {
    final brightness = MediaQuery.of(this).platformBrightness;
    return brightness == Brightness.dark;
  }

  // Dynamic colors based on theme
  Color get adaptiveBackground =>
      isDarkMode ? AppColors.gray900 : AppColors.background;
  Color get adaptiveSurface => isDarkMode ? AppColors.gray800 : AppColors.white;
  Color get adaptiveText =>
      isDarkMode ? AppColors.white : AppColors.textPrimary;
}

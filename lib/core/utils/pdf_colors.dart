// lib/core/utils/pdf_colors.dart
import 'package:pdf/pdf.dart';

class PdfColors {
  // الألوان الأساسية
  static const PdfColor primary = PdfColor.fromInt(0xFF2196F3);
  static const PdfColor primaryDark = PdfColor.fromInt(0xFF1976D2);
  static const PdfColor primaryLight = PdfColor.fromInt(0xFFBBDEFB);

  // ألوان الثانوية
  static const PdfColor secondary = PdfColor.fromInt(0xFFFF9800);
  static const PdfColor secondaryDark = PdfColor.fromInt(0xFFF57C00);
  static const PdfColor secondaryLight = PdfColor.fromInt(0xFFFFE0B2);

  // ألوان النجاح والخطأ
  static const PdfColor success = PdfColor.fromInt(0xFF4CAF50);
  static const PdfColor successLight = PdfColor.fromInt(0xFFE8F5E8);
  static const PdfColor error = PdfColor.fromInt(0xFFF44336);
  static const PdfColor errorLight = PdfColor.fromInt(0xFFFDEDED);
  static const PdfColor warning = PdfColor.fromInt(0xFFFFC107);
  static const PdfColor warningLight = PdfColor.fromInt(0xFFFFF8E1);
  static const PdfColor info = PdfColor.fromInt(0xFF2196F3);
  static const PdfColor infoLight = PdfColor.fromInt(0xFFE3F2FD);

  // ألوان النص
  static const PdfColor textPrimary = PdfColor.fromInt(0xFF212121);
  static const PdfColor textSecondary = PdfColor.fromInt(0xFF757575);
  static const PdfColor textDisabled = PdfColor.fromInt(0xFFBDBDBD);
  static const PdfColor textWhite = PdfColor.fromInt(0xFFFFFFFF);

  // ألوان الخلفية
  static const PdfColor background = PdfColor.fromInt(0xFFFAFAFA);
  static const PdfColor surface = PdfColor.fromInt(0xFFFFFFFF);
  static const PdfColor cardBackground = PdfColor.fromInt(0xFFFFFFFF);

  // ألوان الحدود والتقسيم
  static const PdfColor border = PdfColor.fromInt(0xFFE0E0E0);
  static const PdfColor divider = PdfColor.fromInt(0xFFEEEEEE);

  // ألوان التمويه (Overlay)
  static const PdfColor overlay = PdfColor.fromInt(0x52000000);

  // ألوان التظليل (Shadows)
  static const PdfColor shadowLight = PdfColor.fromInt(0x1A000000);
  static const PdfColor shadowMedium = PdfColor.fromInt(0x33000000);
  static const PdfColor shadowDark = PdfColor.fromInt(0x4D000000);

  // ألوان البيانات والمخططات
  static const PdfColor chartBlue = PdfColor.fromInt(0xFF4285F4);
  static const PdfColor chartRed = PdfColor.fromInt(0xFFEA4335);
  static const PdfColor chartYellow = PdfColor.fromInt(0xFFFBBC05);
  static const PdfColor chartGreen = PdfColor.fromInt(0xFF34A853);
  static const PdfColor chartPurple = PdfColor.fromInt(0xFF9C27B0);
  static const PdfColor chartOrange = PdfColor.fromInt(0xFFFF9800);
  static const PdfColor chartTeal = PdfColor.fromInt(0xFF009688);
  static const PdfColor chartPink = PdfColor.fromInt(0xFFE91E63);
  static const PdfColor chartIndigo = PdfColor.fromInt(0xFF3F51B5);
  static const PdfColor chartCyan = PdfColor.fromInt(0xFF00BCD4);

  // ألوان التدرجات
  static const PdfColor gradientStart = PdfColor.fromInt(0xFF667EEA);
  static const PdfColor gradientEnd = PdfColor.fromInt(0xFF764BA2);

  // ألوان خاصة بالتطبيق
  static const PdfColor expenseRed = PdfColor.fromInt(0xFFF44336);
  static const PdfColor revenueGreen = PdfColor.fromInt(0xFF4CAF50);
  static const PdfColor profitBlue = PdfColor.fromInt(0xFF2196F3);
  static const PdfColor neutralGray = PdfColor.fromInt(0xFF9E9E9E);

  // ألوان الحالة (Status Colors)
  static const PdfColor statusPending = PdfColor.fromInt(0xFFFFA000);
  static const PdfColor statusCompleted = PdfColor.fromInt(0xFF4CAF50);
  static const PdfColor statusCancelled = PdfColor.fromInt(0xFFF44336);
  static const PdfColor statusInProgress = PdfColor.fromInt(0xFF2196F3);

  // ألوان الفئات (Category Colors)
  static const PdfColor categoryMaterials = PdfColor.fromInt(0xFF4285F4);
  static const PdfColor categoryLabor = PdfColor.fromInt(0xFF34A853);
  static const PdfColor categoryMaintenance = PdfColor.fromInt(0xFFFBBC05);
  static const PdfColor categoryServices = PdfColor.fromInt(0xFFEA4335);
  static const PdfColor categoryOther = PdfColor.fromInt(0xFF9C27B0);

  // ألوان الأشهر (Seasonal Colors)
  static const PdfColor winter = PdfColor.fromInt(0xFF81D4FA);
  static const PdfColor spring = PdfColor.fromInt(0xFFC5E1A5);
  static const PdfColor summer = PdfColor.fromInt(0xFFFFF59D);
  static const PdfColor autumn = PdfColor.fromInt(0xFFFFCC80);

  // دوال مساعدة للألوان
  static PdfColor fromHex(String hexColor) {
    try {
      hexColor = hexColor.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      final colorValue = int.parse(hexColor, radix: 16);
      return PdfColor.fromInt(colorValue);
    } catch (e) {
      return PdfColors.textPrimary;
    }
  }





  // الحصول على لون الفئة
  static PdfColor getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'مواد':
      case 'materials':
        return categoryMaterials;
      case 'عمالة':
      case 'labor':
        return categoryLabor;
      case 'صيانة':
      case 'maintenance':
        return categoryMaintenance;
      case 'خدمات':
      case 'services':
        return categoryServices;
      default:
        return categoryOther;
    }
  }

  // الحصول على لون الحالة
  static PdfColor getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'معلق':
      case 'pending':
        return statusPending;
      case 'مكتمل':
      case 'completed':
        return statusCompleted;
      case 'ملغى':
      case 'cancelled':
        return statusCancelled;
      case 'قيد التنفيذ':
      case 'in progress':
        return statusInProgress;
      default:
        return neutralGray;
    }
  }

  // تدرجات الألوان للاستخدام في المخططات
  static List<PdfColor> get chartColorPalette => [
    chartBlue,
    chartRed,
    chartGreen,
    chartYellow,
    chartPurple,
    chartOrange,
    chartTeal,
    chartPink,
    chartIndigo,
    chartCyan,
  ];

  static List<PdfColor> get expenseChartColors => [
    expenseRed,
    chartOrange,
    warning,
    chartYellow,
  ];

  static List<PdfColor> get revenueChartColors => [
    revenueGreen,
    chartGreen,
    success,
    chartTeal,
  ];

  // ألوان للتقرير المالي

  static const PdfColor headerBackground = PdfColor.fromInt(0xFF1976D2);
  static const PdfColor headerText = PdfColor.fromInt(0xFFFFFFFF);
  static const PdfColor tableHeader = PdfColor.fromInt(0xFFE3F2FD);
  static const PdfColor tableHeaderText = PdfColor.fromInt(0xFF1976D2);
  static const PdfColor tableRowEven = PdfColor.fromInt(0xFFFFFFFF);
  static const PdfColor tableRowOdd = PdfColor.fromInt(0xFFF5F5F5);
  static const PdfColor positiveValue = PdfColor.fromInt(0xFF4CAF50);
  static const PdfColor negativeValue = PdfColor.fromInt(0xFFF44336);
  static const PdfColor totalRow = PdfColor.fromInt(0xFFE8F5E8);


  // ألوان لتقرير التكاليف

  static const PdfColor title = PdfColor.fromInt(0xFFD32F2F);
  static const PdfColor subtitle = PdfColor.fromInt(0xFFF44336);
  static const PdfColor highlight = PdfColor.fromInt(0xFFFFCDD2);
  static const PdfColor summary = PdfColor.fromInt(0xFFEF9A9A);


  // ألوان لتقرير الإيرادات



}



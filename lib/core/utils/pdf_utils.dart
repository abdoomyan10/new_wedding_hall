// core/utils/pdf_utils.dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'font_loader.dart';

class PdfUtils {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🔄 بدء تهيئة PdfUtils...');
      await FontLoader.loadFont();
      _isInitialized = true;
      debugPrint('✅ تم تهيئة PdfUtils بنجاح');
      debugPrint('📝 ${FontLoader.fontInfo}');
    } catch (e) {
      debugPrint('❌ خطأ في تهيئة PdfUtils: $e');
      _isInitialized = true; // نعتبره مهيأ حتى مع الخط البديل
    }
  }

  static bool get isReady => _isInitialized;

  static Future<void> ensureReady() async {
    if (!isReady) {
      await initialize();
    }
  }

  // دالة محسنة تعمل مع أو بدون خطوط عربية
  static pw.Widget buildArabicText(
      String text, {
        double fontSize = 12,
        bool bold = false,
        PdfColor color = PdfColors.black,
        pw.TextAlign alignment = pw.TextAlign.right,
      }) {
    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Text(
        text,
        style: _getTextStyle(
          fontSize: fontSize,
          bold: bold,
          color: color,
        ),
        textAlign: alignment,
      ),
    );
  }

  static pw.TextStyle _getTextStyle({
    double fontSize = 12,
    bool bold = false,
    PdfColor color = PdfColors.black,
  }) {
    if (FontLoader.isLoaded && FontLoader.arabicFont != null) {
      return pw.TextStyle(
        font: FontLoader.arabicFont!,
        fontSize: fontSize,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: color,
      );
    } else {
      // استخدام خط system مع إعدادات النص العربي
      return pw.TextStyle(
        fontSize: fontSize,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: color,
        // إضافة هذه الخاصية لتحسين العرض
        wordSpacing: 1.0,
        letterSpacing: 0.5,
      );
    }
  }

  // دالة بديلة آمنة
  static pw.Widget buildSafeText(
      String text, {
        double fontSize = 12,
        bool bold = false,
        PdfColor color = PdfColors.black,
        pw.TextAlign alignment = pw.TextAlign.right,
      }) {
    return buildArabicText(
      text,
      fontSize: fontSize,
      bold: bold,
      color: color,
      alignment: alignment,
    );
  }

  // دالة لاختبار الخطوط
  static pw.Widget buildFontTestPage() {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(20),
      child: pw.Directionality(
        textDirection: pw.TextDirection.rtl,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            buildArabicText('اختبار الخطوط العربية', fontSize: 24, bold: true),
            pw.SizedBox(height: 20),
            buildArabicText('النص العادي: مرحباً بك في التطبيق', fontSize: 14),
            buildArabicText('النص العريض: مرحباً بك في التطبيق', fontSize: 14, bold: true),
            pw.SizedBox(height: 10),
            buildArabicText('الأرقام: ١٢٣٤٥٦٧٨٩٠', fontSize: 14),
            buildArabicText('التاريخ: ${DateTime.now().toString()}', fontSize: 12),
            pw.SizedBox(height: 20),
            buildArabicText('معلومات الخط:', fontSize: 16, bold: true),
            buildArabicText('الخط الحالي: ${FontLoader.currentFont}', fontSize: 12),
            buildArabicText('الحالة: ${FontLoader.isLoaded ? "جاهز" : "غير جاهز"}', fontSize: 12),
            pw.SizedBox(height: 10),
            buildArabicText('نص تجريبي طويل:', fontSize: 14, bold: true),
            buildArabicText(
              'هذا نص عربي طويل لاختبار مدى دعم الخط للغة العربية. يجب أن يظهر هذا النص بشكل صحيح بدون أي مشاكل في التنسيق أو الاتجاه.',
              fontSize: 12,
            ),
          ],
        ),
      ),
    );
  }

  static String get fontStatus {
    return 'الحالة: ${FontLoader.isLoaded ? "جاهز" : "غير جاهز"}\n'
        'الخط: ${FontLoader.currentFont}';
  }
}

void debugPrint(String message) {
  print('🖨️ PDF_UTILS: $message');
}
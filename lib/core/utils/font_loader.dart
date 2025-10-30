// core/utils/font_loader.dart
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

class FontLoader {
  static pw.Font? arabicFont;
  static bool isLoaded = false;

  static Future<void> loadFont() async {
    if (isLoaded) return;

    try {
      print('🔄 بدء تحميل الخطوط العربية...');

      // قائمة بالخطوط البديلة بالترتيب
      final fontPaths = [
        'assets/fonts/NotoNaskhArabic-Regular.ttf',
        'assets/fonts/NotoSansArabic-Regular.ttf',
        'assets/fonts/Amiri-Regular.ttf',
        'assets/fonts/Tajawal-Regular.ttf',
        'assets/fonts/NotoKufiArabic-Regular.ttf',
      ];

      for (final path in fontPaths) {
        try {
          final fontData = await rootBundle.load(path);
          arabicFont = pw.Font.ttf(fontData);
          print('✅ تم تحميل الخط العربي: $path');
          break;
        } catch (e) {
          print('❌ فشل تحميل الخط $path: $e');
          continue;
        }
      }

      // إذا فشل جميع الخطوط، استخدم الخط الافتراضي
      if (arabicFont == null) {
        print('⚠️ استخدام الخط الافتراضي');
        arabicFont = pw.Font.helvetica();
      }

      isLoaded = true;
      print('✅ تم تحميل الخطوط العربية بنجاح');
    } catch (e) {
      print('❌ خطأ في تحميل الخطوط: $e');
      arabicFont = pw.Font.helvetica();
      isLoaded = true;
    }
  }
}
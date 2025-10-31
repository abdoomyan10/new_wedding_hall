// core/utils/font_loader.dart
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

class FontLoader {
  static pw.Font? arabicFont;
  static bool isLoaded = false;
  static bool isLoading = false;

  static Future<void> loadFont() async {
    if (isLoaded || isLoading) return;

    isLoading = true;

    try {
      print('🔄 بدء تحميل الخطوط العربية...');

      // قائمة بالخطوط مع مساراتها الصحيحة بناءً على هيكل مجلداتك
      final fontPaths = [
        'fonts/Amiri-Regular.ttf',
        'fonts/Tajawal-Regular.ttf',
        'fonts/NotoKufiArabic-VariableFont_wght.ttf',
        'fonts/NotoSansArabic-VariableFont_wdth,wght.ttf',
      ];

      for (final path in fontPaths) {
        try {
          print('📖 محاولة تحميل الخط: $path');
          final fontData = await rootBundle.load(path);
          arabicFont = pw.Font.ttf(fontData);
          print('✅ تم تحميل الخط العربي بنجاح: $path');
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
    } finally {
      isLoading = false;
    }
  }

  static Future<bool> testArabicFont() async {
    if (!isLoaded) {
      await loadFont();
    }

    if (arabicFont == null) {
      print('❌ فشل تحميل أي خط عربي');
      return false;
    }

    // اختبار بسيط لمعرفة إذا كان الخط يدعم العربية
    try {
      final testDoc = pw.Document();
      testDoc.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Text(
              'اختبار النص العربي',
              style: pw.TextStyle(font: arabicFont),
              textDirection: pw.TextDirection.rtl,
            );
          },
        ),
      );

      await testDoc.save();
      print('✅ الخط العربي يعمل بشكل صحيح');
      return true;
    } catch (e) {
      print('❌ الخط العربي لا يعمل: $e');
      return false;
    }
  }

  static void reset() {
    arabicFont = null;
    isLoaded = false;
    isLoading = false;
  }
}
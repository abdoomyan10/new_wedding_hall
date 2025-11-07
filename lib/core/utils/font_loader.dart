// core/utils/font_loader.dart
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

class FontLoader {
  static pw.Font? _arabicFont;
  static bool _isLoaded = false;
  static String _currentFont = 'SystemFallback';

  static pw.Font? get arabicFont => _arabicFont;
  static bool get isLoaded => _isLoaded;
  static String get currentFont => _currentFont;

  static Future<void> loadFont() async {
    if (_isLoaded && _arabicFont != null) return;

    try {
      debugPrint('🔄 جاري تحميل الخطوط العربية...');

      // محاولة تحميل الخطوط العربية المخصصة
      final fontsToTry = [
        'assets/fonts/Tajawal-Regular.ttf',
        'assets/fonts/Amiri-Regular.ttf',
        'assets/fonts/NotoKufiArabic-VariableFont_wght.ttf',
        'assets/fonts/NotoSansArabic-VariableFont_width,wght.ttf',
      ];

      for (final fontPath in fontsToTry) {
        try {
          _arabicFont = await _loadFontFromAssets(fontPath);
          if (_arabicFont != null) {
            _currentFont = fontPath.split('/').last;
            _isLoaded = true;
            debugPrint('✅ تم تحميل الخط العربي: $_currentFont');
            return;
          }
        } catch (e) {
          debugPrint('⚠️ فشل تحميل $fontPath: $e');
          continue;
        }
      }

      // إذا فشل كل شيء، استخدام خط system بديل
      _arabicFont = pw.Font.courier();
      _currentFont = 'SystemCourier';
      _isLoaded = true;
      debugPrint('✅ استخدام خط System كبديل');

    } catch (e) {
      debugPrint('❌ خطأ حرج في تحميل الخطوط: $e');
      _arabicFont = pw.Font.courier();
      _isLoaded = true;
    }
  }

  static Future<pw.Font> _loadFontFromAssets(String path) async {
    try {
      final fontData = await rootBundle.load(path);
      return pw.Font.ttf(fontData.buffer.asByteData());
    } catch (e) {
      debugPrint('❌ خطأ في تحميل الخط من $path: $e');
      rethrow;
    }
  }

  static String get fontInfo => 'الخط: $_currentFont - محمل: $_isLoaded';
}

void debugPrint(String message) {
  print('🔤 FONT_LOADER: $message');
}
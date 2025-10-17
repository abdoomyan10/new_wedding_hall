import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';

class FontLoader {
  static pw.Font? _arabicFont;
  static bool _isLoaded = false;

  static Future<void> loadFont() async {
    if (_isLoaded) return;

    try {
      // محاولة تحميل الخط العربي
      final fontData = await rootBundle.load('assets/fonts/Amiri-Regular.ttf');
      _arabicFont = pw.Font.ttf(fontData);
      _isLoaded = true;
      print('✅ الخط العربي تم تحميله بنجاح في FontLoader');
    } catch (e) {
      print('❌ فشل تحميل الخط: $e');
      _isLoaded = true; // منع إعادة المحاولة
    }
  }

  static pw.Font? get arabicFont => _arabicFont;
  static bool get isLoaded => _isLoaded;
}
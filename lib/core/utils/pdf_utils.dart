import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'font_loader.dart';

class PdfUtils {
  static Future<void> initialize() async {
    await FontLoader.loadFont();
  }

  static pw.TextStyle getArabicTextStyle({
    double fontSize = 12,
    pw.FontWeight fontWeight = pw.FontWeight.normal,
    PdfColor color = PdfColors.black,
  }) {
    return pw.TextStyle(
      font: FontLoader.arabicFont,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static bool get isReady => FontLoader.isLoaded && FontLoader.arabicFont != null;

  static Future<bool> ensureReady() async {
    if (!FontLoader.isLoaded) {
      await FontLoader.loadFont();
    }
    return isReady;
  }
}
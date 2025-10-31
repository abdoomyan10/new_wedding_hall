// core/utils/pdf_utils.dart
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

  // دالة محسنة لبناء النص العربي
  static pw.Widget buildArabicText(
      String text, {
        double fontSize = 12,
        bool bold = false,
        PdfColor color = PdfColors.black,
        pw.TextAlign alignment = pw.TextAlign.right,
      }) {
    return pw.Container(
      child: pw.Text(
        text,
        style: getArabicTextStyle(
          fontSize: fontSize,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color,
        ),
        textDirection: pw.TextDirection.rtl,
        textAlign: alignment,
      ),
    );
  }

  // دالة جديدة للتحقق من دعم النص العربي
  static bool isArabicTextSupported(String text) {
    return FontLoader.isLoaded && FontLoader.arabicFont != null;
  }

  // دالة للتعامل مع النص بشكل آمن - نسخة مبسطة بدون FutureBuilder
  static pw.Widget buildSafeText(
      String text, {
        double fontSize = 12,
        bool bold = false,
        PdfColor color = PdfColors.black,
        pw.TextAlign alignment = pw.TextAlign.right,
        bool forceArabic = true,
      }) {
    if (forceArabic && isArabicTextSupported(text)) {
      return buildArabicText(
        text,
        fontSize: fontSize,
        bold: bold,
        color: color,
        alignment: alignment,
      );
    } else {
      // استخدام خط بديل إذا لم تكن الخطوط العربية متاحة
      return pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color,
        ),
        textAlign: alignment,
      );
    }
  }

  // دالة مساعدة لبناء جدول بنص عربي
  static pw.Widget buildArabicTable(List<List<String>> data, {List<String>? headers}) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        if (headers != null)
          pw.TableRow(
            decoration: const pw.BoxDecoration(
              color: PdfColors.grey300,
            ),
            children: headers.map((header) =>
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: buildSafeText(header, bold: true, alignment: pw.TextAlign.center),
                )).toList(),
          ),
        for (var row in data)
          pw.TableRow(
            children: row.map((cell) =>
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: buildSafeText(cell, alignment: pw.TextAlign.center),
                )).toList(),
          ),
      ],
    );
  }

  // دالة مساعدة لبناء عمود بنص عربي
  static pw.Widget buildArabicColumn(
      List<String> texts, {
        pw.CrossAxisAlignment crossAxisAlignment = pw.CrossAxisAlignment.end,
      }) {
    return pw.Column(
      crossAxisAlignment: crossAxisAlignment,
      children: texts.map((text) => buildSafeText(text)).toList(),
    );
  }

  // دالة لبناء صفحة بعنوان عربي
  static pw.Widget buildArabicPage(
      String title,
      List<pw.Widget> children, {
        bool showDate = true,
      }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          buildSafeText(
            title,
            fontSize: 24,
            bold: true,
          ),
          if (showDate) ...[
            pw.SizedBox(height: 10),
            buildSafeText(
              'تاريخ التقرير: ${_formatDate(DateTime.now())}',
              fontSize: 14,
            ),
          ],
          pw.Divider(),
          pw.SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
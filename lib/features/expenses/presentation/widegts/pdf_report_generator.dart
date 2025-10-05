// features/expenses/presentation/cubit/expense_pdf_service.dart
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/expense_stats_entity.dart';

class ExpensePdfService {
  static Future<pw.Document> generateExpenseReport({
    required List<ExpenseEntity> expenses,
    required ExpenseStatsEntity stats,
    required ProfitEntity profit,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    String? filterCategory,
  }) async {
    final pdf = pw.Document();

    // تحميل الخط مسبقاً
    final fontData = await rootBundle.load("fonts/NotoNaskhArabic-Regular.ttf");
    final arabicFont = pw.Font.ttf(fontData);

    // الصفحة الرئيسية
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: _buildTheme(arabicFont),
        build: (pw.Context context) => [
          _buildHeader(title ?? 'تقرير التكاليف', arabicFont),
          _buildReportInfo(startDate, endDate, filterCategory, arabicFont),
          _buildSummarySection(stats, profit, arabicFont),
          _buildExpensesTable(expenses, arabicFont),
          _buildChartsSection(expenses, arabicFont),
        ],
      ),
    );

    return pdf;
  }

  static pw.ThemeData _buildTheme(pw.Font arabicFont) {
    return pw.ThemeData.withFont(
      base: arabicFont,
    );
  }

  static pw.Widget _buildHeader(String title, pw.Font arabicFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue700,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'نظام إدارة قاعة الأفراح',
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 12,
                    color: PdfColors.grey200,
                  ),
                ),
              ],
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Text(
              DateFormat('yyyy-MM-dd').format(DateTime.now()),
              style: pw.TextStyle(
                font: arabicFont,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildReportInfo(DateTime? startDate, DateTime? endDate, String? category, pw.Font arabicFont) {
    final infoLines = <String>[];

    if (startDate != null && endDate != null) {
      infoLines.add('الفترة: ${DateFormat('yyyy-MM-dd').format(startDate)} إلى ${DateFormat('yyyy-MM-dd').format(endDate)}');
    }

    if (category != null && category.isNotEmpty) {
      infoLines.add('الفئة: $category');
    }

    if (infoLines.isEmpty) return pw.SizedBox();

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 16),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'معايير التقرير:',
            style: pw.TextStyle(
              font: arabicFont,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          ...infoLines.map((line) => pw.Text(
            line,
            style: pw.TextStyle(
              font: arabicFont,
              fontSize: 10,
            ),
          )),
        ],
      ),
    );
  }

  static pw.Widget _buildSummarySection(ExpenseStatsEntity stats, ProfitEntity profit, pw.Font arabicFont) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Row(
        children: [
          _buildSummaryCard('إجمالي التكاليف', '${stats.totalExpenses.toStringAsFixed(2)} ر.س', PdfColors.red, arabicFont),
          pw.SizedBox(width: 12),
          _buildSummaryCard('إجمالي الإيرادات', '${profit.totalRevenue.toStringAsFixed(2)} ر.س', PdfColors.green, arabicFont),
          pw.SizedBox(width: 12),
          _buildSummaryCard(
              'الفائض',
              '${profit.profit.toStringAsFixed(2)} ر.س',
              profit.isProfit ? PdfColors.green : PdfColors.red,
              arabicFont
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryCard(String title, String value, PdfColor color, pw.Font arabicFont) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              title,
              style: pw.TextStyle(
                font: arabicFont,
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue700,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(
                font: arabicFont,
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildExpensesTable(List<ExpenseEntity> expenses, pw.Font arabicFont) {
    if (expenses.isEmpty) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(top: 20),
        child: pw.Center(
          child: pw.Text(
            'لا توجد تكاليف في هذه الفترة',
            style: pw.TextStyle(
              font: arabicFont,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey300),
        children: [
          // رأس الجدول
          pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColors.blue700),
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'الوصف',
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                    fontSize: 10,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'المبلغ',
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                    fontSize: 10,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'العامل',
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                    fontSize: 10,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'الفئة',
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                    fontSize: 10,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  'التاريخ',
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                    fontSize: 10,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          ),
          // بيانات الجدول
          ...expenses.map((expense) => pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(
                  expense.description,
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 9,
                  ),
                  textAlign: pw.TextAlign.right,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(
                  '${expense.amount.toStringAsFixed(2)} ر.س',
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 9,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(
                  expense.workerName,
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 9,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(
                  expense.category,
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 9,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(
                  DateFormat('yyyy-MM-dd').format(expense.date),
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 9,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          )).toList(),
        ],
      ),
    );
  }

  static pw.Widget _buildChartsSection(List<ExpenseEntity> expenses, pw.Font arabicFont) {
    if (expenses.isEmpty) return pw.SizedBox();

    final categoryData = _getCategoryData(expenses);

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'التوزيع حسب الفئات',
            style: pw.TextStyle(
              font: arabicFont,
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          _buildCategoryChart(categoryData, arabicFont),
        ],
      ),
    );
  }

  static Map<String, double> _getCategoryData(List<ExpenseEntity> expenses) {
    final Map<String, double> data = {};

    for (final expense in expenses) {
      data.update(
        expense.category,
            (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    return data;
  }

  static pw.Widget _buildCategoryChart(Map<String, double> data, pw.Font arabicFont) {
    final total = data.values.fold(0.0, (sum, value) => sum + value);

    // إذا كان الإجمالي صفر، لا تعرض المخطط
    if (total == 0) {
      return pw.Text(
        'لا توجد بيانات لعرضها',
        style: pw.TextStyle(
          font: arabicFont,
          fontSize: 10,
        ),
      );
    }

    return pw.Column(
      children: data.entries.map((entry) {
        final percentage = (entry.value / total * 100).toStringAsFixed(1);
        final barWidth = (entry.value / total * 200); // 200 هو الطول الأقصى للشريط

        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  entry.key,
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 9,
                  ),
                ),
              ),
              pw.Expanded(
                flex: 5,
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: barWidth,
                      height: 20,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue700,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Text(
                      '$percentage%',
                      style: pw.TextStyle(
                        font: arabicFont,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                flex: 2,
                child: pw.Text(
                  '${entry.value.toStringAsFixed(2)} ر.س',
                  style: pw.TextStyle(
                    font: arabicFont,
                    fontSize: 8,
                  ),
                  textAlign: pw.TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// كlass ProfitEntity
class ProfitEntity {
  final double totalRevenue;
  final double profit;
  final bool isProfit;

  const ProfitEntity({
    required this.totalRevenue,
    required this.profit,
    required this.isProfit,
  });
}
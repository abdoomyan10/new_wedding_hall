// features/reports/presentation/cubit/report_cubit.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'package:new_wedding_hall/core/error/failure.dart';
import 'package:new_wedding_hall/core/usecase/usecase.dart';

import '../../domain/entities/report_entity.dart';
import '../../domain/entities/report_summary_entity.dart';
import '../../domain/usecases/export_reports_usecase.dart';
import '../../domain/usecases/get_daily_reports_usecase.dart';
import '../../domain/usecases/get_monthly_reports_usecase.dart';
import '../../domain/usecases/get_report_summary_usecase.dart';
import '../../domain/usecases/get_weekly_reports_usecase.dart';
import '../../domain/usecases/get_yearly_reports_usecase.dart';
import 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  final GetDailyReportsUseCase getDailyReportsUseCase;
  final GetWeeklyReportsUseCase getWeeklyReportsUseCase;
  final GetMonthlyReportsUseCase getMonthlyReportsUseCase;
  final GetYearlyReportsUseCase getYearlyReportsUseCase;
  final GetReportSummaryUseCase getReportSummaryUseCase;
  final ExportReportsUseCase exportReportsUseCase;

  // متغيرات لحفظ الخطوط العربية
  pw.Font? _arabicFont;
  bool _fontsLoaded = false;

  ReportCubit({
    required this.getDailyReportsUseCase,
    required this.getWeeklyReportsUseCase,
    required this.getMonthlyReportsUseCase,
    required this.getYearlyReportsUseCase,
    required this.getReportSummaryUseCase,
    required this.exportReportsUseCase,
  }) : super(const ReportInitial()) {
    _loadArabicFonts();
  }

  // ========== دوال PDF والطباعة المضافة ==========

  // تحميل الخطوط العربية
  Future<void> _loadArabicFonts() async {
    try {
      debugPrint('🔄 بدء تحميل الخطوط العربية للتقرير...');

      final List<String> fontPaths = [
        'assets/fonts/NotoNaskhArabic-VariableFont_wght.ttf',
        'assets/fonts/Amiri-Regular.ttf',
        'assets/fonts/Tajawal-Regular.ttf',
        'assets/fonts/NotoKufiArabic-VariableFont_wght.ttf',
      ];

      for (final path in fontPaths) {
        try {
          final fontData = await rootBundle.load(path);
          _arabicFont = pw.Font.ttf(fontData);
          debugPrint('✅ تم تحميل الخط العربي للتقرير: $path');
          break;
        } catch (e) {
          debugPrint('❌ فشل تحميل الخط $path: $e');
          continue;
        }
      }

      if (_arabicFont == null) {
        debugPrint('⚠️ استخدام الخط الافتراضي للتقرير');
        _arabicFont = pw.Font.helvetica();
      }

      _fontsLoaded = true;
      debugPrint('✅ تم تحميل الخطوط العربية للتقرير بنجاح');

    } catch (e) {
      debugPrint('❌ خطأ في تحميل الخطوط العربية للتقرير: $e');
      _fontsLoaded = false;
      _arabicFont = pw.Font.helvetica();
      _fontsLoaded = true;
    }
  }

  // دالة للحصول على النمط مع الخط العربي
  pw.TextStyle _getTextStyle({double fontSize = 12, bool bold = false, PdfColor? color}) {
    return pw.TextStyle(
      font: _arabicFont,
      fontSize: fontSize,
      color: color,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    );
  }

  // دالة لمعالجة النص العربي وضبط الاتجاه
  pw.Widget _buildArabicText(String text, {double fontSize = 12, bool bold = false, PdfColor? color, pw.TextAlign alignment = pw.TextAlign.right}) {
    return pw.Text(
      text,
      style: _getTextStyle(fontSize: fontSize, bold: bold, color: color),
      textDirection: pw.TextDirection.rtl,
      textAlign: alignment,
    );
  }

  // ========== دوال إدارة الملفات والمجلدات ==========

  // إنشاء مجلد SavedReports إذا لم يكن موجوداً
  Future<Directory> _getOrCreateReportFolder() async {
    try {
      Directory directory;

      try {
        directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      } catch (e) {
        directory = await getApplicationDocumentsDirectory();
      }

      final reportsFolder = Directory('${directory.path}/SavedReports');

      if (!await reportsFolder.exists()) {
        await reportsFolder.create(recursive: true);
        debugPrint('📁 تم إنشاء مجلد SavedReports في: ${reportsFolder.path}');
      }

      return reportsFolder;
    } catch (e) {
      debugPrint('❌ خطأ في إنشاء المجلد: $e');
      final docsDirectory = await getApplicationDocumentsDirectory();
      final fallbackFolder = Directory('${docsDirectory.path}/SavedReports');

      if (!await fallbackFolder.exists()) {
        await fallbackFolder.create(recursive: true);
      }

      return fallbackFolder;
    }
  }

  // دالة مساعدة لحفظ الملف
  Future<String> _savePdfFile(pw.Document pdf, String fileName) async {
    try {
      final cleanFileName = fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      final folder = await _getOrCreateReportFolder();
      final file = File('${folder.path}/$cleanFileName');
      final bytes = await pdf.save();
      await file.writeAsBytes(bytes);

      debugPrint('✅ تم حفظ ملف التقرير بنجاح في: ${file.path}');
      debugPrint('📊 حجم الملف: ${bytes.length} بايت');
      return file.path;
    } catch (e) {
      debugPrint('❌ خطأ في حفظ ملف التقرير: $e');
      throw Exception('فشل في حفظ ملف التقرير: $e');
    }
  }

  // الحصول على قائمة ملفات PDF المحفوظة
  Future<List<File>> getSavedReportFiles() async {
    try {
      final folder = await _getOrCreateReportFolder();
      if (!await folder.exists()) {
        debugPrint('📁 مجلد التقارير غير موجود، إرجاع قائمة فارغة');
        return [];
      }

      final List<FileSystemEntity> entities = await folder.list().toList();
      final List<File> pdfFiles = [];

      for (final entity in entities) {
        if (entity is File && entity.path.toLowerCase().endsWith('.pdf')) {
          pdfFiles.add(entity);
        }
      }

      // ترتيب الملفات من الأحدث إلى الأقدم
      pdfFiles.sort((a, b) {
        try {
          final aStat = a.statSync();
          final bStat = b.statSync();
          return bStat.modified.compareTo(aStat.modified);
        } catch (e) {
          return 0;
        }
      });

      debugPrint('📁 تم العثور على ${pdfFiles.length} ملف PDF في مجلد التقارير');
      return pdfFiles;
    } catch (e) {
      debugPrint('❌ خطأ في جلب ملفات التقرير المحفوظة: $e');
      throw Exception('فشل في جلب ملفات التقرير المحفوظة: $e');
    }
  }

  // حذف ملف PDF محفوظ
  Future<bool> deleteSavedReportFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('✅ تم حذف ملف التقرير: $filePath');
        return true;
      } else {
        debugPrint('⚠️ ملف التقرير غير موجود: $filePath');
        return false;
      }
    } catch (e) {
      debugPrint('❌ خطأ في حذف ملف التقرير: $e');
      return false;
    }
  }

  // ========== دوال إنشاء PDF مع دعم عربي ==========

  // بناء رأس التقرير
  pw.Widget _buildReportHeader(ReportSummaryEntity summary, String period) {
    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          _buildArabicText(
            'تقرير الأداء',
            fontSize: 24,
            bold: true,
          ),
          pw.SizedBox(height: 10),
          _buildArabicText(
            '${_getPeriodText(period)} - ${DateFormat('yyyy-MM-dd - HH:mm').format(DateTime.now())}',
            fontSize: 14,
          ),
          pw.Divider(),
          pw.SizedBox(height: 20),
          _buildArabicText(
            'ملخص الأداء',
            fontSize: 18,
            bold: true,
          ),
        ],
      ),
    );
  }

  // بناء صفحة الإحصائيات
  pw.Widget _buildSummaryStats(ReportSummaryEntity summary) {
    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          _buildArabicText(
            'الإحصائيات',
            fontSize: 20,
            bold: true,
          ),
          pw.SizedBox(height: 20),
          _buildStatItem('إجمالي الإيرادات', '${summary.totalRevenue.toStringAsFixed(2)} ر.س'),
          _buildStatItem('إجمالي المصروفات', '${summary.totalExpenses.toStringAsFixed(2)} ر.س'),
          _buildStatItem('صافي الربح', '${summary.netProfit.toStringAsFixed(2)} ر.س'),
          _buildStatItem('إجمالي المدفوعات', '${summary.totalPayments.toStringAsFixed(2)} ر.س'),
          _buildStatItem('عدد الحفلات', summary.totalEvents.toString()),
          _buildStatItem('هامش الربح', '${summary.profitMargin.toStringAsFixed(1)}%'),
        ],
      ),
    );
  }

  // بناء عنصر إحصائي
  pw.Widget _buildStatItem(String title, String value) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _buildArabicText(value, fontSize: 14, bold: true),
          _buildArabicText(title, fontSize: 14),
        ],
      ),
    );
  }

  // بناء قائمة التقارير
  pw.Widget _buildReportsList(List<ReportEntity> reports, String period) {
    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          _buildArabicText(
            'قائمة التقارير ${_getPeriodText(period)}',
            fontSize: 20,
            bold: true,
          ),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: const {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(2),
              3: pw.FlexColumnWidth(2),
              4: pw.FlexColumnWidth(2),
            },
            defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
            children: [
              // رأس الجدول
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                children: [
                  _buildTableHeaderCell('التاريخ'),
                  _buildTableHeaderCell('الإيرادات'),
                  _buildTableHeaderCell('المصروفات'),
                  _buildTableHeaderCell('صافي الربح'),
                  _buildTableHeaderCell('عدد الحفلات'),
                ],
              ),
              // بيانات الجدول
              for (var report in reports)
                pw.TableRow(
                  children: [
                    _buildTableCell(_formatReportDate(report.date, period)),
                    _buildTableCell('${report.totalRevenue.toStringAsFixed(2)} ر.س'),
                    _buildTableCell('${report.expenses.toStringAsFixed(2)} ر.س'),
                    _buildTableCell('${report.netProfit.toStringAsFixed(2)} ر.س'),
                    _buildTableCell(report.eventsCount.toString()),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  // بناء خلية رأس الجدول
  pw.Widget _buildTableHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(12),
      child: _buildArabicText(
        text,
        fontSize: 14,
        bold: true,
        alignment: pw.TextAlign.center,
      ),
    );
  }

  // بناء خلية بيانات الجدول
  pw.Widget _buildTableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: _buildArabicText(
        text,
        fontSize: 12,
        alignment: pw.TextAlign.center,
      ),
    );
  }

  // بناء صفحة تقرير فردية
  pw.Widget _buildSingleReportPage(ReportEntity report, String period) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          _buildArabicText(
            'تفاصيل التقرير',
            fontSize: 24,
            bold: true,
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blue),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                _buildDetailRow('الفترة:', _getPeriodText(period)),
                _buildDetailRow('التاريخ:', _formatReportDate(report.date, period)),
                _buildDetailRow('الإيرادات:', '${report.totalRevenue.toStringAsFixed(2)} ر.س'),
                _buildDetailRow('المصروفات:', '${report.expenses.toStringAsFixed(2)} ر.س'),
                _buildDetailRow('صافي الربح:', '${report.netProfit.toStringAsFixed(2)} ر.س'),
                _buildDetailRow('المدفوعات:', '${report.totalPayments.toStringAsFixed(2)} ر.س'),
                _buildDetailRow('عدد الحفلات:', report.eventsCount.toString()),
                _buildDetailRow('هامش الربح:', '${report.profitMargin.toStringAsFixed(1)}%'),
                _buildDetailRow('المعرف:', report.id),
              ],
            ),
          ),
          pw.SizedBox(height: 30),
          _buildArabicText(
            'تم إنشاء هذا التقرير في: ${DateFormat('yyyy-MM-dd - HH:mm').format(DateTime.now())}',
            fontSize: 12,
            color: PdfColors.grey,
          ),
        ],
      ),
    );
  }

  // بناء صف تفاصيل
  pw.Widget _buildDetailRow(String label, String value) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 15),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Expanded(
            child: _buildArabicText(value, fontSize: 14),
          ),
          pw.SizedBox(width: 20),
          pw.Container(
            width: 100,
            child: _buildArabicText(
              label,
              fontSize: 14,
              bold: true,
            ),
          ),
        ],
      ),
    );
  }

  // دوال مساعدة للنصوص والتواريخ
  String _getPeriodText(String period) {
    switch (period) {
      case 'daily':
        return 'يومي';
      case 'weekly':
        return 'أسبوعي';
      case 'monthly':
        return 'شهري';
      case 'yearly':
        return 'سنوي';
      default:
        return period;
    }
  }

  String _formatReportDate(DateTime date, String period) {
    switch (period) {
      case 'daily':
        return DateFormat('yyyy-MM-dd').format(date);
      case 'weekly':
        return 'أسبوع ${DateFormat('MM-dd').format(date)}';
      case 'monthly':
        return DateFormat('yyyy-MM').format(date);
      case 'yearly':
        return DateFormat('yyyy').format(date);
      default:
        return DateFormat('yyyy-MM-dd').format(date);
    }
  }

  // ========== الدوال الرئيسية للطباعة والحفظ ==========

  // حفظ تقرير PDF شامل
  Future<void> generateAndSavePdfReport() async {
    try {
      if (!_fontsLoaded) {
        await _loadArabicFonts();
      }

      if (state is! ReportLoaded) {
        throw Exception('❌ لا توجد تقارير محملة');
      }

      final loadedState = state as ReportLoaded;

      if (loadedState.reports.isEmpty) {
        throw Exception('❌ لا توجد بيانات تقارير للحفظ');
      }

      debugPrint('🔄 بدء إنشاء تقرير PDF...');

      final pdf = pw.Document();

      // إضافة صفحة العنوان
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: _buildReportHeader(loadedState.summary!, loadedState.selectedPeriod),
            );
          },
        ),
      );

      // إضافة صفحة الإحصائيات
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: _buildSummaryStats(loadedState.summary!),
            );
          },
        ),
      );

      // إضافة صفحة التقارير
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: _buildReportsList(loadedState.reports, loadedState.selectedPeriod),
            );
          },
        ),
      );

      final fileName = 'تقرير_الأداء_${loadedState.selectedPeriod}_${DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now())}.pdf';
      final filePath = await _savePdfFile(pdf, fileName);

      debugPrint('✅ تم إنشاء وحفظ التقرير بنجاح: $filePath');

      // فتح الملف بعد حفظه
      await OpenFile.open(filePath);

    } catch (e) {
      debugPrint('❌ خطأ في إنشاء تقرير PDF: $e');
      throw e; // إعادة رمي الاستثناء للتعامل معه في الواجهة
    }
  }

  // طباعة تقرير PDF
  Future<void> generatePdfReport() async {
    try {
      if (!_fontsLoaded) {
        await _loadArabicFonts();
      }

      if (state is! ReportLoaded) {
        throw Exception('❌ لا توجد تقارير محملة');
      }

      final loadedState = state as ReportLoaded;
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: _buildReportHeader(loadedState.summary!, loadedState.selectedPeriod),
            );
          },
        ),
      );

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: _buildSummaryStats(loadedState.summary!),
            );
          },
        ),
      );

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: _buildReportsList(loadedState.reports, loadedState.selectedPeriod),
            );
          },
        ),
      );

      debugPrint('🔄 بدء عملية الطباعة...');
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
      debugPrint('✅ تمت الطباعة بنجاح');

    } catch (e) {
      debugPrint('❌ خطأ في طباعة تقرير PDF: $e');
      throw e;
    }
  }

  // حفظ تقرير فردي كPDF
  Future<void> generateAndSaveSingleReportPdf(ReportEntity report) async {
    try {
      if (!_fontsLoaded) {
        await _loadArabicFonts();
      }

      if (state is! ReportLoaded) {
        throw Exception('❌ لا توجد تقارير محملة');
      }

      final loadedState = state as ReportLoaded;
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _buildSingleReportPage(report, loadedState.selectedPeriod);
          },
        ),
      );

      final fileName = 'تقرير_${report.id}_${DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now())}.pdf';
      final filePath = await _savePdfFile(pdf, fileName);

      debugPrint('✅ تم حفظ التقرير الفردي بنجاح: $filePath');

      // فتح الملف بعد حفظه
      await OpenFile.open(filePath);

    } catch (e) {
      debugPrint('❌ خطأ في حفظ التقرير الفردي: $e');
      throw e;
    }
  }

  // طباعة تقرير فردي
  Future<void> generateSingleReportPdf(ReportEntity report) async {
    try {
      if (!_fontsLoaded) {
        await _loadArabicFonts();
      }

      if (state is! ReportLoaded) {
        throw Exception('❌ لا توجد تقارير محملة');
      }

      final loadedState = state as ReportLoaded;
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _buildSingleReportPage(report, loadedState.selectedPeriod);
          },
        ),
      );

      debugPrint('🔄 بدء عملية طباعة التقرير الفردي...');
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
      debugPrint('✅ تمت طباعة التقرير الفردي بنجاح');

    } catch (e) {
      debugPrint('❌ خطأ في طباعة التقرير الفردي: $e');
      throw e;
    }
  }

  // ========== دوال التحميل الحالية ==========

  // تحميل التقارير اليومية
  Future<void> loadDailyReports() async {
    emit(const ReportLoading());

    final result = await getDailyReportsUseCase(NoParams());

    result.fold(
          (failure) {
        emit(ReportError(_mapFailureToMessage(failure)));
      },
          (reports) async {
        final summaryResult = await getReportSummaryUseCase('daily');

        summaryResult.fold(
              (summaryFailure) {
            emit(ReportError(_mapFailureToMessage(summaryFailure)));
          },
              (summary) {
            emit(
              ReportLoaded(
                reports: reports,
                summary: summary,
                selectedPeriod: 'daily',
              ),
            );
          },
        );
      },
    );
  }

  // تحميل التقارير الأسبوعية
  Future<void> loadWeeklyReports() async {
    emit(const ReportLoading());

    final result = await getWeeklyReportsUseCase(DateTime(2023, 10, 1));

    result.fold(
          (failure) {
        emit(ReportError(_mapFailureToMessage(failure)));
      },
          (reports) async {
        final summaryResult = await getReportSummaryUseCase('weekly');

        summaryResult.fold(
              (summaryFailure) {
            emit(ReportError(_mapFailureToMessage(summaryFailure)));
          },
              (summary) {
            emit(
              ReportLoaded(
                reports: reports,
                summary: summary,
                selectedPeriod: 'weekly',
              ),
            );
          },
        );
      },
    );
  }

  // تحميل التقارير الشهرية
  Future<void> loadMonthlyReports() async {
    emit(const ReportLoading());

    final result = await getMonthlyReportsUseCase(DateTime(2023, 10, 1));

    result.fold(
          (failure) {
        emit(ReportError(_mapFailureToMessage(failure)));
      },
          (reports) async {
        final summaryResult = await getReportSummaryUseCase('monthly');

        summaryResult.fold(
              (summaryFailure) {
            emit(ReportError(_mapFailureToMessage(summaryFailure)));
          },
              (summary) {
            emit(
              ReportLoaded(
                reports: reports,
                summary: summary,
                selectedPeriod: 'monthly',
              ),
            );
          },
        );
      },
    );
  }

  // تحميل التقارير السنوية
  Future<void> loadYearlyReports() async {
    emit(const ReportLoading());

    final result = await getYearlyReportsUseCase(DateTime(2023, 10, 1));

    result.fold(
          (failure) {
        emit(ReportError(_mapFailureToMessage(failure)));
      },
          (reports) async {
        final summaryResult = await getReportSummaryUseCase('yearly');

        summaryResult.fold(
              (summaryFailure) {
            emit(ReportError(_mapFailureToMessage(summaryFailure)));
          },
              (summary) {
            emit(
              ReportLoaded(
                reports: reports,
                summary: summary,
                selectedPeriod: 'yearly',
              ),
            );
          },
        );
      },
    );
  }

  // تحميل الملخص فقط
  Future<void> loadReportSummary(String period) async {
    final result = await getReportSummaryUseCase(period);

    result.fold(
          (failure) {
        _showExportError(
          'فشل في تحميل الملخص: ${_mapFailureToMessage(failure)}',
        );
      },
          (summary) {
        if (state is ReportLoaded) {
          final currentState = state as ReportLoaded;
          emit(
            ReportLoaded(
              reports: currentState.reports,
              summary: summary,
              selectedPeriod: currentState.selectedPeriod,
            ),
          );
        }
      },
    );
  }

  // تصدير التقارير كـ PDF
  Future<void> exportToPdf() async {
    if (state is! ReportLoaded) {
      _showExportError('لا توجد تقارير لتصديرها');
      return;
    }

    final currentState = state as ReportLoaded;

    if (currentState.reports.isEmpty) {
      _showExportError('لا توجد تقارير لتصديرها');
      return;
    }

    try {
      final result = await exportReportsUseCase(
        ExportReportsParams(
          reports: currentState.reports,
          format: ExportFormat.pdf,
          period: currentState.selectedPeriod,
        ),
      );

      result.fold(
            (failure) {
          _showExportError(_mapFailureToMessage(failure));
        },
            (filePath) {
          _showExportSuccess('تم التصدير بنجاح كـ PDF: $filePath');
        },
      );
    } catch (e) {
      _showExportError('حدث خطأ أثناء التصدير: $e');
    }
  }

  // تصدير التقارير كـ Excel
  Future<void> exportToExcel() async {
    if (state is! ReportLoaded) {
      _showExportError('لا توجد تقارير لتصديرها');
      return;
    }

    final currentState = state as ReportLoaded;

    if (currentState.reports.isEmpty) {
      _showExportError('لا توجد تقارير لتصديرها');
      return;
    }

    try {
      final result = await exportReportsUseCase(
        ExportReportsParams(
          reports: currentState.reports,
          format: ExportFormat.excel,
          period: currentState.selectedPeriod,
        ),
      );

      result.fold(
            (failure) {
          _showExportError(_mapFailureToMessage(failure));
        },
            (filePath) {
          _showExportSuccess('تم التصدير بنجاح كـ Excel: $filePath');
        },
      );
    } catch (e) {
      _showExportError('حدث خطأ أثناء التصدير: $e');
    }
  }

  // تصدير التقارير مع تحديد التنسيق
  Future<void> exportReports(ExportFormat format) async {
    if (state is! ReportLoaded) {
      _showExportError('لا توجد تقارير لتصديرها');
      return;
    }

    final currentState = state as ReportLoaded;

    if (currentState.reports.isEmpty) {
      _showExportError('لا توجد تقارير لتصديرها');
      return;
    }

    try {
      final result = await exportReportsUseCase(
        ExportReportsParams(
          reports: currentState.reports,
          format: format,
          period: currentState.selectedPeriod,
        ),
      );

      result.fold(
            (failure) {
          _showExportError(_mapFailureToMessage(failure));
        },
            (filePath) {
          final formatName = format == ExportFormat.pdf ? 'PDF' : 'Excel';
          _showExportSuccess('تم التصدير بنجاح كـ $formatName: $filePath');
        },
      );
    } catch (e) {
      _showExportError('حدث خطأ أثناء التصدير: $e');
    }
  }

  // تحديث تقرير محدد
  void updateReport(ReportEntity updatedReport) {
    if (state is! ReportLoaded) return;

    final currentState = state as ReportLoaded;
    final updatedReports = currentState.reports.map((report) {
      return report.id == updatedReport.id ? updatedReport : report;
    }).toList();

    final newSummary = _calculateSummary(updatedReports);

    emit(
      ReportLoaded(
        reports: updatedReports,
        summary: newSummary,
        selectedPeriod: currentState.selectedPeriod,
      ),
    );
  }

  // إضافة تقرير جديد
  void addReport(ReportEntity newReport) {
    if (state is! ReportLoaded) return;

    final currentState = state as ReportLoaded;
    final updatedReports = [...currentState.reports, newReport];
    final newSummary = _calculateSummary(updatedReports);

    emit(
      ReportLoaded(
        reports: updatedReports,
        summary: newSummary,
        selectedPeriod: currentState.selectedPeriod,
      ),
    );
  }

  // حذف تقرير
  void deleteReport(String reportId) {
    if (state is! ReportLoaded) return;

    final currentState = state as ReportLoaded;
    final updatedReports = currentState.reports
        .where((report) => report.id != reportId)
        .toList();
    final newSummary = _calculateSummary(updatedReports);

    emit(
      ReportLoaded(
        reports: updatedReports,
        summary: newSummary,
        selectedPeriod: currentState.selectedPeriod,
      ),
    );
  }

  // حساب الملخص الإجمالي من التقارير
  ReportSummaryEntity _calculateSummary(List<ReportEntity> reports) {
    if (reports.isEmpty) {
      return const ReportSummaryEntity(
        totalRevenue: 0,
        totalExpenses: 0,
        netProfit: 0,
        totalPayments: 0,
        totalEvents: 0,
        profitMargin: 0,
      );
    }

    double totalRevenue = 0;
    double totalExpenses = 0;
    double totalNetProfit = 0;
    double totalPayments = 0;
    int totalEvents = 0;

    for (final report in reports) {
      totalRevenue += report.totalRevenue;
      totalExpenses += report.expenses;
      totalNetProfit += report.netProfit;
      totalPayments += report.totalPayments;
      totalEvents += report.eventsCount;
    }

    double profitMargin = totalRevenue > 0
        ? (totalNetProfit / totalRevenue) * 100
        : 0;

    return ReportSummaryEntity(
      totalRevenue: totalRevenue,
      totalExpenses: totalExpenses,
      netProfit: totalNetProfit,
      totalPayments: totalPayments,
      totalEvents: totalEvents,
      profitMargin: profitMargin,
    );
  }

  // تحويل Failure إلى رسالة خطأ
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'خطأ في الاتصال بالخادم';
      case NetworkFailure:
        return 'خطأ في الاتصال بالإنترنت';
      case CacheFailure:
        return 'خطأ في التخزين المحلي';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }

  // عرض رسائل الخطأ
  void _showExportError(String message) {
    debugPrint('❌ خطأ في التصدير: $message');
  }

  void _showExportSuccess(String message) {
    debugPrint('✅ نجاح: $message');
  }

  // الحصول على التقارير الحالية
  List<ReportEntity> get currentReports {
    if (state is ReportLoaded) {
      return (state as ReportLoaded).reports;
    }
    return [];
  }

  // الحصول على الملخص الحالي
  ReportSummaryEntity? get currentSummary {
    if (state is ReportLoaded) {
      return (state as ReportLoaded).summary;
    }
    return null;
  }

  // الحصول على الفترة المحددة حالياً
  String get currentPeriod {
    if (state is ReportLoaded) {
      return (state as ReportLoaded).selectedPeriod;
    }
    return 'daily';
  }

  // تنظيف الموارد عند إغلاق Cubit
  @override
  Future<void> close() {
    _arabicFont = null;
    return super.close();
  }
}
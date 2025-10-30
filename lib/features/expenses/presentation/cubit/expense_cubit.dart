import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/expense_stats_entity.dart';
import '../../domain/entities/profit_entity.dart';
import '../../domain/usecases/add_expense_usecase.dart';
import '../../domain/usecases/delete_expense_usecase.dart';
import '../../domain/usecases/get_expense_stats_usecase.dart';
import '../../domain/usecases/get_expense_usecase.dart';
import 'expense_state.dart';

class ExpenseCubit extends Cubit<ExpenseState> {

  final AddExpenseUseCase addExpenseUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;
  final GetExpensesUseCase getExpensesUseCase;
  final GetExpenseStatsUseCase getExpenseStatsUseCase;

  // متغيرات لحفظ الخطوط العربية
  pw.Font? _arabicFont;
  bool _fontsLoaded = false;

  ExpenseCubit({
    required this.addExpenseUseCase,
    required this.deleteExpenseUseCase,
    required this.getExpensesUseCase,
    required this.getExpenseStatsUseCase,
  }) : super(const ExpenseInitial()) {
    _loadArabicFonts();
  }

  // تحميل الخطوط العربية - استخدام خطوط تدعم الاتصال
  Future<void> _loadArabicFonts() async {
    try {
      debugPrint('🔄 بدء تحميل الخطوط العربية...');

      // قائمة بالخطوط التي تدعم العربية بشكل جيد
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
          debugPrint('✅ تم تحميل الخط العربي: $path');
          break; // استخدم أول خط يتم تحميله بنجاح
        } catch (e) {
          debugPrint('❌ فشل تحميل الخط $path: $e');
          continue;
        }
      }

      // إذا فشل تحميل جميع الخطوط، استخدم خط افتراضي
      if (_arabicFont == null) {
        debugPrint('⚠️ استخدام الخط الافتراضي');
        _arabicFont = pw.Font.helvetica();
      }

      _fontsLoaded = true;
      debugPrint('✅ تم تحميل الخطوط العربية بنجاح');

    } catch (e) {
      debugPrint('❌ خطأ في تحميل الخطوط العربية: $e');
      _fontsLoaded = false;
      _arabicFont = pw.Font.helvetica();
      _fontsLoaded = true;
    }
  }

  // دالة محسنة للحصول على النمط مع الخط العربي
  pw.TextStyle _getTextStyle({double fontSize = 12, bool bold = false, PdfColor? color}) {
    return pw.TextStyle(
      font: _arabicFont,
      fontSize: fontSize,
      color: color,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    );
  }

  // دالة جديدة لمعالجة النص العربي وضبط الاتجاه
  pw.Widget _buildArabicText(String text, {double fontSize = 12, bool bold = false, PdfColor? color, pw.TextAlign alignment = pw.TextAlign.right}) {
    return pw.Text(
      text,
      style: _getTextStyle(fontSize: fontSize, bold: bold, color: color),
      textDirection: pw.TextDirection.rtl,
      textAlign: alignment,
    );
  }

  // ========== دوال إدارة الملفات والمجلدات ==========

  // إنشاء مجلد ExpenseReports إذا لم يكن موجوداً
  Future<Directory> _getOrCreateExpenseReportsFolder() async {
    try {
      Directory directory;

      // محاولة استخدام التخزين الخارجي أولاً
      try {
        directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      } catch (e) {
        directory = await getApplicationDocumentsDirectory();
      }

      final expenseReportsFolder = Directory('${directory.path}/ExpenseReports');

      if (!await expenseReportsFolder.exists()) {
        await expenseReportsFolder.create(recursive: true);
        debugPrint('تم إنشاء مجلد ExpenseReports في: ${expenseReportsFolder.path}');
      }

      return expenseReportsFolder;
    } catch (e) {
      debugPrint('خطأ في إنشاء المجلد: $e');
      // استخدام مجلد المستندات كبديل
      final docsDirectory = await getApplicationDocumentsDirectory();
      final fallbackFolder = Directory('${docsDirectory.path}/ExpenseReports');

      if (!await fallbackFolder.exists()) {
        await fallbackFolder.create(recursive: true);
      }

      return fallbackFolder;
    }
  }

  // دالة مساعدة محسنة لحفظ الملف
  Future<String> _savePdfFile(pw.Document pdf, String fileName) async {
    try {
      // تنظيف اسم الملف من الأحرف غير المسموح بها
      final cleanFileName = _cleanFileName(fileName);

      final folder = await _getOrCreateExpenseReportsFolder();
      final file = File('${folder.path}/$cleanFileName');
      final bytes = await pdf.save();
      await file.writeAsBytes(bytes);

      debugPrint('✅ تم حفظ الملف بنجاح في: ${file.path}');
      debugPrint('📁 المسار الكامل: ${folder.path}');

      return file.path;
    } catch (e) {
      debugPrint('❌ خطأ في حفظ الملف: $e');
      throw Exception('فشل في حفظ الملف: $e');
    }
  }

  // تنظيف اسم الملف من الرموز غير المسموح بها
  String _cleanFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  // الحصول على قائمة ملفات PDF المحفوظة
  Future<List<File>> getSavedPdfFiles() async {
    try {
      final folder = await _getOrCreateExpenseReportsFolder();
      if (!await folder.exists()) {
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

      debugPrint('📁 تم العثور على ${pdfFiles.length} ملف PDF');
      return pdfFiles;
    } catch (e) {
      debugPrint('❌ خطأ في جلب الملفات المحفوظة: $e');
      throw Exception('فشل في جلب الملفات المحفوظة: $e');
    }
  }

  // حذف ملف PDF محفوظ
  Future<bool> deleteSavedPdfFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('✅ تم حذف الملف: $filePath');
        return true;
      } else {
        debugPrint('⚠️ الملف غير موجود: $filePath');
        return false;
      }
    } catch (e) {
      debugPrint('❌ خطأ في حذف الملف: $e');
      return false;
    }
  }

  // ========== دوال إنشاء PDF مع دعم عربي محسن ==========

  // بناء رأس التقرير محسن
  pw.Widget _buildReportHeader() {
    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end, // محاذاة لليمين
        children: [
          _buildArabicText(
            'تقرير التكاليف',
            fontSize: 24,
            bold: true,
          ),
          pw.SizedBox(height: 10),
          _buildArabicText(
            'تاريخ التقرير: ${DateFormat('yyyy-MM-dd - HH:mm').format(DateTime.now())}',
            fontSize: 14,
          ),
          pw.Divider(),
          pw.SizedBox(height: 20),
          _buildArabicText(
            'ملخص التكاليف',
            fontSize: 18,
            bold: true,
          ),
        ],
      ),
    );
  }

  // بناء صفحة الإحصائيات محسنة
  pw.Widget _buildStatsPage(ExpenseStatsEntity stats, ProfitEntity? profit) {
    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end, // محاذاة لليمين
        children: [
          _buildArabicText(
            'الإحصائيات',
            fontSize: 20,
            bold: true,
          ),
          pw.SizedBox(height: 20),
          _buildStatItem('إجمالي التكاليف', '${stats.totalExpenses.toStringAsFixed(2)} ر.س'),
          _buildStatItem('عدد التكاليف', stats.expenseCount.toString()),
          _buildStatItem('متوسط التكلفة', '${stats.averageExpense.toStringAsFixed(2)} ر.س'),
          _buildStatItem('تكاليف اليوم', '${stats.todayExpenses.toStringAsFixed(2)} ر.س'),
          _buildStatItem('تكاليف الشهر', '${stats.monthlyExpenses.toStringAsFixed(2)} ر.س'),

          if (profit != null) ...[
            pw.SizedBox(height: 20),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blue),
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  _buildArabicText(
                    'الربح / الخسارة',
                    fontSize: 16,
                    bold: true,
                    color: PdfColors.blue,
                  ),
                  pw.SizedBox(height: 5),
                  _buildArabicText('الإيرادات: ${profit.totalRevenue.toStringAsFixed(2)} ر.س', fontSize: 14),
                  _buildArabicText('التكاليف: ${profit.totalExpenses.toStringAsFixed(2)} ر.س', fontSize: 14),
                  _buildArabicText(
                    '${profit.isProfit ? 'ربح' : 'خسارة'}: ${profit.profit.toStringAsFixed(2)} ر.س',
                    fontSize: 14,
                    bold: true,
                    color: profit.isProfit ? PdfColors.green : PdfColors.red,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // بناء عنصر إحصائي محسن
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

  // بناء قائمة التكاليف محسنة
  pw.Widget _buildExpensesList(List<ExpenseEntity> expenses) {
    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          _buildArabicText(
            'قائمة التكاليف',
            fontSize: 20,
            bold: true,
          ),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: const {
              0: pw.FlexColumnWidth(3),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(2),
              3: pw.FlexColumnWidth(2),
            },
            defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
            children: [
              // رأس الجدول
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                children: [
                  _buildTableHeaderCell('الوصف'),
                  _buildTableHeaderCell('المبلغ'),
                  _buildTableHeaderCell('الفئة'),
                  _buildTableHeaderCell('التاريخ'),
                ],
              ),
              // بيانات الجدول
              for (var expense in expenses)
                pw.TableRow(
                  children: [
                    _buildTableCell(expense.description),
                    _buildTableCell('${expense.amount.toStringAsFixed(2)} ر.س'),
                    _buildTableCell(expense.category),
                    _buildTableCell(DateFormat('yyyy-MM-dd').format(expense.date)),
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

  // بناء صفحة تكلفة فردية محسنة
  pw.Widget _buildSingleExpensePage(ExpenseEntity expense) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          _buildArabicText(
            'تفاصيل التكلفة',
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
                _buildDetailRow('الوصف:', expense.description),
                _buildDetailRow('المبلغ:', '${expense.amount.toStringAsFixed(2)} ر.س'),
                _buildDetailRow('اسم العامل:', expense.workerName),
                _buildDetailRow('الفئة:', expense.category),
                _buildDetailRow('تاريخ التكلفة:', DateFormat('yyyy-MM-dd').format(expense.date)),
                _buildDetailRow('تاريخ الإضافة:', DateFormat('yyyy-MM-dd - HH:mm').format(expense.createdAt)),
                _buildDetailRow('المعرف:', expense.id),
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

  // بناء صف تفاصيل محسن
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

  // ========== الدوال الرئيسية ==========

  Future<void> loadExpenses() async {
    emit(const ExpenseLoading(expenses: []));

    final result = await getExpensesUseCase();
    result.fold(
          (failure) {
        emit(ExpenseError(message: failure.toString(), expenses: []));
      },
          (expenses) async {
        final statsResult = await getExpenseStatsUseCase();
        statsResult.fold(
              (failure) {
            emit(ExpenseError(message: failure.toString(), expenses: expenses));
          },
              (stats) {
            final profit = ProfitEntity.calculate(
              totalRevenue: 0,
              totalExpenses: stats.totalExpenses,
            );
            emit(ExpenseLoaded(expenses: expenses, stats: stats, profit: profit));
          },
        );
      },
    );
  }

  Future<void> addExpense(ExpenseEntity expense) async {
    final result = await addExpenseUseCase(expense);
    result.fold(
          (failure) {
        loadExpenses();
      },
          (_) {
        loadExpenses();
      },
    );
  }

  Future<void> deleteExpense(String expenseId) async {
    final result = await deleteExpenseUseCase(expenseId);
    result.fold(
          (failure) {
        loadExpenses();
      },
          (_) {
        loadExpenses();
      },
    );
  }

  // حفظ تقرير PDF شامل
  Future<void> generateAndSavePdfReport() async {
    try {
      // الانتظار حتى يتم تحميل الخطوط إذا لم تكن محملة بعد
      if (!_fontsLoaded) {
        await _loadArabicFonts();
      }

      final pdf = pw.Document();

      // إضافة صفحة العنوان
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: _buildReportHeader(),
            );
          },
        ),
      );

      // إضافة صفحة الإحصائيات
      if (state is ExpenseLoaded) {
        final loadedState = state as ExpenseLoaded;
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Padding(
                padding: const pw.EdgeInsets.all(20),
                child: _buildStatsPage(loadedState.filteredStats, loadedState.profit),
              );
            },
          ),
        );

        // إضافة صفحة التكاليف
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Padding(
                padding: const pw.EdgeInsets.all(20),
                child: _buildExpensesList(loadedState.expenses),
              );
            },
          ),
        );
      }

      final fileName = 'تقرير_التكاليف_${DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now())}.pdf';
      final filePath = await _savePdfFile(pdf, fileName);

      // فتح الملف بعد حفظه
      await OpenFile.open(filePath);

    } catch (e) {
      debugPrint('خطأ في إنشاء التقرير: $e');
    }
  }

  // طباعة تقرير PDF
  Future<void> generatePdfReport() async {
    try {
      if (!_fontsLoaded) {
        await _loadArabicFonts();
      }

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: _buildReportHeader(),
            );
          },
        ),
      );

      if (state is ExpenseLoaded) {
        final loadedState = state as ExpenseLoaded;
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Padding(
                padding: const pw.EdgeInsets.all(20),
                child: _buildStatsPage(loadedState.filteredStats, loadedState.profit),
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
                child: _buildExpensesList(loadedState.expenses),
              );
            },
          ),
        );
      }

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      debugPrint('خطأ في طباعة التقرير: $e');
    }
  }

  // حفظ تكلفة فردية كPDF
  Future<void> generateAndSaveSingleExpensePdf(ExpenseEntity expense) async {
    try {
      if (!_fontsLoaded) {
        await _loadArabicFonts();
      }

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _buildSingleExpensePage(expense);
          },
        ),
      );

      final fileName = 'تكلفة_${expense.id}_${DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now())}.pdf';
      final filePath = await _savePdfFile(pdf, fileName);

      // فتح الملف بعد حفظه
      await OpenFile.open(filePath);

    } catch (e) {
      debugPrint('خطأ في حفظ التكلفة الفردية: $e');
    }
  }

  // طباعة تكلفة فردية
  Future<void> generateSingleExpensePdf(ExpenseEntity expense) async {
    try {
      if (!_fontsLoaded) {
        await _loadArabicFonts();
      }

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _buildSingleExpensePage(expense);
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      debugPrint('خطأ في طباعة التكلفة الفردية: $e');
    }
  }
}
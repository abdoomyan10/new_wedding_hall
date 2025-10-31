// features/payments/presentation/cubit/payment_cubit.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

// استيرادات Use Cases المطلوبة
import '../../domain/entities/payment_entity.dart';
import '../../domain/entities/payment_state_entity.dart';
import '../../domain/usecases/add_payment_usecase.dart';
import '../../domain/usecases/get_payment_usecase.dart';
import '../../domain/usecases/get_payments_stats_usecase.dart';
import '../../domain/usecases/update_payment_usecase.dart';
import '../../domain/usecases/delete_payment_usecase.dart';

// استيراد PdfUtils
import '../../../../core/utils/pdf_utils.dart';

part 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final GetPaymentsUseCase getPaymentsUseCase;
  final AddPaymentUseCase addPaymentUseCase;
  final UpdatePaymentUseCase updatePaymentUseCase;
  final DeletePaymentUseCase deletePaymentUseCase;
  final GetPaymentStatsUseCase getPaymentStatsUseCase;

  // إزالة متغيرات الخطوط القديمة
  bool _fontsLoaded = false;

  // قائمة مؤقتة للبحث (سيتم استبدالها بالبيانات الفعلية من use case)
  List<PaymentEntity> _allPayments = [];

  PaymentCubit({
    required this.getPaymentsUseCase,
    required this.addPaymentUseCase,
    required this.updatePaymentUseCase,
    required this.deletePaymentUseCase,
    required this.getPaymentStatsUseCase,
  }) : super(PaymentInitial()) {
    _loadArabicFonts();
  }

  // تحميل الخطوط العربية باستخدام PdfUtils
  Future<void> _loadArabicFonts() async {
    try {
      await PdfUtils.initialize();
      _fontsLoaded = PdfUtils.isReady;
      debugPrint('✅ حالة تحميل الخطوط: $_fontsLoaded');
    } catch (e) {
      debugPrint('❌ خطأ في تحميل الخطوط العربية: $e');
      _fontsLoaded = false;
    }
  }

  // دالة محسنة للحصول على النمط مع الخط العربي
  pw.TextStyle _getTextStyle({double fontSize = 12, bool bold = false, PdfColor? color}) {
    return PdfUtils.getArabicTextStyle(
      fontSize: fontSize,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      color: color ?? PdfColors.black,
    );
  }

  // دالة جديدة لمعالجة النص العربي وضبط الاتجاه
  pw.Widget buildArabicText(String text, {double fontSize = 12, bool bold = false, PdfColor? color, pw.TextAlign alignment = pw.TextAlign.right}) {
    return PdfUtils.buildArabicText(
      text,
      fontSize: fontSize,
      bold: bold,
      color: color ?? PdfColors.black,
      alignment: alignment,
    );
  }

  // ========== دوال إدارة الملفات والمجلدات ==========
  // ... (بقية الدوال تبقى كما هي بدون تغيير)

  Future<Directory> _getOrCreatePaymentReportsFolder() async {
    try {
      Directory directory;

      try {
        directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      } catch (e) {
        directory = await getApplicationDocumentsDirectory();
      }

      final paymentReportsFolder = Directory('${directory.path}/PaymentReports');

      if (!await paymentReportsFolder.exists()) {
        await paymentReportsFolder.create(recursive: true);
        debugPrint('تم إنشاء مجلد PaymentReports في: ${paymentReportsFolder.path}');
      }

      return paymentReportsFolder;
    } catch (e) {
      debugPrint('خطأ في إنشاء المجلد: $e');
      final docsDirectory = await getApplicationDocumentsDirectory();
      final fallbackFolder = Directory('${docsDirectory.path}/PaymentReports');

      if (!await fallbackFolder.exists()) {
        await fallbackFolder.create(recursive: true);
      }

      return fallbackFolder;
    }
  }

  Future<String> _savePdfFile(pw.Document pdf, String fileName) async {
    try {
      final cleanFileName = _cleanFileName(fileName);
      final folder = await _getOrCreatePaymentReportsFolder();
      final file = File('${folder.path}/$cleanFileName');
      final bytes = await pdf.save();
      await file.writeAsBytes(bytes);

      debugPrint('✅ تم حفظ ملف الدفع بنجاح في: ${file.path}');
      return file.path;
    } catch (e) {
      debugPrint('❌ خطأ في حفظ ملف الدفع: $e');
      throw Exception('فشل في حفظ ملف الدفع: $e');
    }
  }

  String _cleanFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  Future<List<File>> getSavedPdfFiles() async {
    try {
      final folder = await _getOrCreatePaymentReportsFolder();
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

      pdfFiles.sort((a, b) {
        try {
          final aStat = a.statSync();
          final bStat = b.statSync();
          return bStat.modified.compareTo(aStat.modified);
        } catch (e) {
          return 0;
        }
      });

      debugPrint('📁 تم العثور على ${pdfFiles.length} ملف PDF للمدفوعات');
      return pdfFiles;
    } catch (e) {
      debugPrint('❌ خطأ في جلب ملفات المدفوعات المحفوظة: $e');
      throw Exception('فشل في جلب ملفات المدفوعات المحفوظة: $e');
    }
  }

  Future<bool> deleteSavedPdfFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('✅ تم حذف ملف الدفع: $filePath');
        return true;
      } else {
        debugPrint('⚠️ ملف الدفع غير موجود: $filePath');
        return false;
      }
    } catch (e) {
      debugPrint('❌ خطأ في حذف ملف الدفع: $e');
      return false;
    }
  }

  // ========== دوال إنشاء PDF للمدفوعات ==========

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
              child: _buildPaymentReportHeader(),
            );
          },
        ),
      );

      // إضافة صفحة الإحصائيات
      if (state is PaymentLoaded) {
        final loadedState = state as PaymentLoaded;
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Padding(
                padding: const pw.EdgeInsets.all(20),
                child: _buildPaymentStatsPage(loadedState.stats),
              );
            },
          ),
        );

        // إضافة صفحة المدفوعات
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Padding(
                padding: const pw.EdgeInsets.all(20),
                child: _buildPaymentsList(loadedState.payments),
              );
            },
          ),
        );
      }

      final fileName = 'تقرير_المدفوعات_${DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now())}.pdf';
      final filePath = await _savePdfFile(pdf, fileName);

      // فتح الملف بعد حفظه
      await OpenFile.open(filePath);

    } catch (e) {
      debugPrint('خطأ في إنشاء تقرير المدفوعات: $e');
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
              child: _buildPaymentReportHeader(),
            );
          },
        ),
      );

      if (state is PaymentLoaded) {
        final loadedState = state as PaymentLoaded;
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Padding(
                padding: const pw.EdgeInsets.all(20),
                child: _buildPaymentStatsPage(loadedState.stats),
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
                child: _buildPaymentsList(loadedState.payments),
              );
            },
          ),
        );
      }

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      debugPrint('خطأ في طباعة تقرير المدفوعات: $e');
    }
  }

  // ========== دوال إنشاء PDF للدفعة الفردية ==========

  Future<void> generateAndSaveSinglePaymentPdf(PaymentEntity payment) async {
    try {
      // الانتظار حتى يتم تحميل الخطوط إذا لم تكن محملة بعد
      if (!_fontsLoaded) {
        await _loadArabicFonts();
      }

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _buildSinglePaymentPage(payment);
          },
        ),
      );

      final fileName = 'دفعة_${_cleanName(payment.clientName)}_${DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now())}.pdf';
      final filePath = await _savePdfFile(pdf, fileName);

      // فتح الملف بعد حفظه
      await OpenFile.open(filePath);

      // إظهار رسالة نجاح
      debugPrint('✅ تم حفظ تفاصيل الدفعة بنجاح: $filePath');

    } catch (e) {
      debugPrint('❌ خطأ في حفظ تفاصيل الدفعة: $e');
      throw Exception('فشل في حفظ تفاصيل الدفعة: $e');
    }
  }

  Future<void> generateSinglePaymentPdf(PaymentEntity payment) async {
    try {
      if (!_fontsLoaded) {
        await _loadArabicFonts();
      }

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _buildSinglePaymentPage(payment);
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      debugPrint('خطأ في طباعة تفاصيل الدفعة: $e');
      throw Exception('فشل في طباعة تفاصيل الدفعة: $e');
    }
  }

  // ========== دوال بناء محتوى PDF ==========

  pw.Widget _buildPaymentReportHeader() {
    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Container(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            buildArabicText(
              'تقرير المدفوعات',
              fontSize: 24,
              bold: true,
            ),
            pw.SizedBox(height: 10),
            buildArabicText(
              'تاريخ التقرير: ${DateFormat('yyyy-MM-dd - HH:mm').format(DateTime.now())}',
              fontSize: 14,
            ),
            pw.Divider(),
            pw.SizedBox(height: 20),
            buildArabicText(
              'ملخص المدفوعات',
              fontSize: 18,
              bold: true,
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildPaymentStatsPage(PaymentStatsEntity? stats) {
    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Container(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            buildArabicText(
              'الإحصائيات',
              fontSize: 20,
              bold: true,
            ),
            pw.SizedBox(height: 20),
            if (stats != null) ...[
              _buildStatCard('إجمالي المستلم', '${stats.totalReceived.toStringAsFixed(2)} ر.س', PdfColors.green),
              _buildStatCard('المدفوعات المعلقة', '${stats.totalPending.toStringAsFixed(2)} ر.س', PdfColors.orange),
              _buildStatCard('إجمالي المبلغ', '${stats.totalAmount.toStringAsFixed(2)} ر.س', PdfColors.blue),
              pw.SizedBox(height: 15),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildStatBox('مدفوعات مكتملة', stats.completedPayments.toString(), PdfColors.green),
                  _buildStatBox('مدفوعات معلقة', stats.pendingPayments.toString(), PdfColors.orange),
                  _buildStatBox('مدفوعات فاشلة', stats.failedPayments.toString(), PdfColors.red),
                ],
              ),

              // عرض الإيرادات الشهرية إذا كانت متوفرة
              if (stats.monthlyRevenue.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                buildArabicText(
                  'الإيرادات الشهرية',
                  fontSize: 16,
                  bold: true,
                ),
                pw.SizedBox(height: 10),
                ...stats.monthlyRevenue.entries.map((entry) =>
                    _buildRevenueItem(entry.key, entry.value)
                ).toList(),
              ],
            ] else ...[
              buildArabicText(
                'لا توجد إحصائيات متاحة',
                fontSize: 16,
                color: PdfColors.grey,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // دوال مساعدة جديدة للإحصائيات
  pw.Widget _buildStatCard(String title, String value, PdfColor color) {
    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Container(
        width: double.infinity,
        margin: const pw.EdgeInsets.only(bottom: 10),
        padding: const pw.EdgeInsets.all(15),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: color, width: 2),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            buildArabicText(value, fontSize: 16, bold: true, color: color),
            buildArabicText(title, fontSize: 14),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildStatBox(String title, String value, PdfColor color) {
    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: _getLightColor(color),
          border: pw.Border.all(color: color),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          children: [
            buildArabicText(value, fontSize: 18, bold: true, color: color),
            buildArabicText(title, fontSize: 10),
          ],
        ),
      ),
    );
  }

  // دالة مساعدة للحصول على ألوان فاتحة
  PdfColor _getLightColor(PdfColor baseColor) {
    if (baseColor == PdfColors.green) return PdfColors.lightGreen;
    if (baseColor == PdfColors.orange) return PdfColors.orange100;
    if (baseColor == PdfColors.red) return PdfColors.red100;
    if (baseColor == PdfColors.blue) return PdfColors.lightBlue;
    return PdfColors.grey300;
  }

  pw.Widget _buildRevenueItem(String month, double revenue) {
    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            buildArabicText('${revenue.toStringAsFixed(2)} ر.س', fontSize: 12, bold: true),
            buildArabicText(month, fontSize: 12),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildPaymentsList(List<PaymentEntity> payments) {
    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Container(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            buildArabicText(
              'قائمة المدفوعات',
              fontSize: 20,
              bold: true,
            ),
            pw.SizedBox(height: 10),
            buildArabicText(
              'عدد المدفوعات: ${payments.length}',
              fontSize: 14,
            ),
            pw.SizedBox(height: 20),

            if (payments.isNotEmpty) ...[
              // استخدام TableHelper.fromTextArray بدون context
              pw.TableHelper.fromTextArray(
                data: <List<String>>[
                  // رأس الجدول
                  ['اسم العميل', 'اسم الحفلة', 'المبلغ', 'طريقة الدفع', 'الحالة'],
                  // بيانات الجدول
                  ...payments.map((payment) => [
                    payment.clientName,
                    payment.eventName,
                    '${payment.amount.toStringAsFixed(2)} ر.س',
                    payment.paymentMethodText,
                    payment.statusText,
                  ]).toList(),
                ],
                headerStyle: _getTextStyle(fontSize: 12, bold: true, color: PdfColors.white),
                headerDecoration: pw.BoxDecoration(
                  color: PdfColors.blue700,
                ),
                cellStyle: _getTextStyle(fontSize: 10),
                cellAlignments: {
                  0: pw.Alignment.centerRight,
                  1: pw.Alignment.centerRight,
                  2: pw.Alignment.centerLeft,
                  3: pw.Alignment.center,
                  4: pw.Alignment.center,
                },
                border: pw.TableBorder.all(
                  color: PdfColors.grey300,
                  width: 1,
                ),
                columnWidths: {
                  0: pw.FlexColumnWidth(2),
                  1: pw.FlexColumnWidth(2),
                  2: pw.FlexColumnWidth(1),
                  3: pw.FlexColumnWidth(1.5),
                  4: pw.FlexColumnWidth(1),
                },
              ),
            ] else ...[
              buildArabicText(
                'لا توجد مدفوعات لعرضها',
                fontSize: 16,
                color: PdfColors.grey,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // بناء صفحة الدفعة الفردية
  pw.Widget _buildSinglePaymentPage(PaymentEntity payment) {
    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Container(
        padding: const pw.EdgeInsets.all(20),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            buildArabicText(
              'تفاصيل الدفعة',
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
                  _buildDetailRow('اسم العميل:', payment.clientName),
                  _buildDetailRow('اسم الحفلة:', payment.eventName),
                  _buildDetailRow('المبلغ:', '${payment.amount.toStringAsFixed(2)} ر.س'),
                  _buildDetailRow('طريقة الدفع:', payment.paymentMethodText),
                  _buildDetailRow('حالة الدفع:', payment.statusText),
                  _buildDetailRow('تاريخ الدفع:', DateFormat('yyyy-MM-dd').format(payment.paymentDate)),
                  _buildDetailRow('تاريخ الإضافة:', DateFormat('yyyy-MM-dd - HH:mm').format(payment.createdAt)),
                  _buildDetailRow('ملاحظات:', payment.notes.isEmpty ? 'لا توجد' : payment.notes),
                  _buildDetailRow('المعرف:', payment.id),
                ],
              ),
            ),
            pw.SizedBox(height: 30),
            buildArabicText(
              'تم إنشاء هذا التقرير في: ${DateFormat('yyyy-MM-dd - HH:mm').format(DateTime.now())}',
              fontSize: 12,
              color: PdfColors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // بناء صف تفاصيل محسن
  pw.Widget _buildDetailRow(String label, String value) {
    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 15),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Expanded(
              child: buildArabicText(value, fontSize: 14),
            ),
            pw.SizedBox(width: 20),
            pw.Container(
              width: 100,
              child: buildArabicText(
                label,
                fontSize: 14,
                bold: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة تنظيف الاسم للملف
  String _cleanName(String name) {
    return name.replaceAll(' ', '_').replaceAll(RegExp(r'[^\w]'), '');
  }

  // ========== الدوال الرئيسية ==========

  void loadPayments() async {
    emit(PaymentLoading());
    final paymentsResult = await getPaymentsUseCase();
    final statsResult = await getPaymentStatsUseCase();

    paymentsResult.fold(
          (failure) => emit(PaymentError(failure.toString())),
          (payments) {
        // حفظ جميع المدفوعات للبحث
        _allPayments = payments;

        statsResult.fold(
              (failure) => emit(PaymentLoaded(payments)),
              (stats) => emit(PaymentLoaded(payments, stats)),
        );
      },
    );
  }

  void addPayment(PaymentEntity payment) async {
    final result = await addPaymentUseCase(payment);
    result.fold(
          (failure) => emit(PaymentError(failure.toString())),
          (_) => loadPayments(), // يعيد التحميل تلقائياً بعد الإضافة
    );
  }

  void updatePayment(PaymentEntity payment) async {
    final result = await updatePaymentUseCase(payment);
    result.fold(
          (failure) => emit(PaymentError(failure.toString())),
          (_) => loadPayments(), // يعيد التحميل تلقائياً بعد التحديث
    );
  }

  void deletePayment(String paymentId) async {
    final result = await deletePaymentUseCase(paymentId);
    result.fold(
          (failure) => emit(PaymentError(failure.toString())),
          (_) => loadPayments(), // يعيد التحميل تلقائياً بعد الحذف
    );
  }

  void searchPayments(String value) {
    if (value.isEmpty) {
      // إذا كان البحث فارغاً، إعادة تحميل جميع المدفوعات
      loadPayments();
      return;
    }

    // البحث في المدفوعات المحفوظة
    final filteredPayments = _allPayments.where((payment) {
      return payment.clientName.toLowerCase().contains(value.toLowerCase()) ||
          payment.eventName.toLowerCase().contains(value.toLowerCase()) ||
          payment.amount.toString().contains(value) ||
          payment.paymentMethodText.toLowerCase().contains(value.toLowerCase()) ||
          payment.statusText.toLowerCase().contains(value.toLowerCase()) ||
          payment.notes.toLowerCase().contains(value.toLowerCase());
    }).toList();

    // حساب الإحصائيات للنتائج المصفاة
    final stats = _calculateStatsForSearch(filteredPayments);

    emit(PaymentLoaded(filteredPayments, stats));
  }

  // دالة مساعدة لحساب الإحصائيات للبحث
  PaymentStatsEntity _calculateStatsForSearch(List<PaymentEntity> payments) {
    final completedPayments = payments.where((p) => p.status == 'completed').toList();
    final pendingPayments = payments.where((p) => p.status == 'pending').toList();
    final failedPayments = payments.where((p) => p.status == 'failed').toList();

    final totalReceived = completedPayments.fold<double>(0, (sum, payment) => sum + payment.amount);
    final totalPending = pendingPayments.fold<double>(0, (sum, payment) => sum + payment.amount);
    final totalAmount = totalReceived + totalPending;

    final monthlyRevenue = _calculateMonthlyRevenue(payments);

    return PaymentStatsEntity(
      totalReceived: totalReceived,
      totalPending: totalPending,
      completedPayments: completedPayments.length,
      pendingPayments: pendingPayments.length,
      failedPayments: failedPayments.length,
      monthlyRevenue: monthlyRevenue,
      totalAmount: totalAmount,
    );
  }

  // دالة مساعدة لحساب الإيرادات الشهرية
  Map<String, double> _calculateMonthlyRevenue(List<PaymentEntity> payments) {
    final now = DateTime.now();
    final monthlyRevenue = <String, double>{};

    // حساب الإيرادات للشهور الستة الماضية
    for (int i = 0; i < 6; i++) {
      final month = DateTime(now.year, now.month - i);
      final monthName = _getMonthName(month.month);
      final year = month.year.toString();
      final key = '$monthName $year';

      final monthPayments = payments.where((payment) {
        return payment.paymentDate.year == month.year &&
            payment.paymentDate.month == month.month &&
            payment.status == 'completed';
      }).toList();

      monthlyRevenue[key] = monthPayments.fold(0.0, (sum, p) => sum + p.amount);
    }

    return monthlyRevenue;
  }

  String _getMonthName(int month) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return months[month - 1];
  }
}
// features/payments/presentation/widgets/payment_details_page.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:open_file/open_file.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/pdf_utils.dart';
import '../../../../core/services/pdf_storage_service.dart';
import '../../domain/entities/payment_entity.dart';
import '../cubit/payment_cubit.dart';
import '../pages/saved_payments_reports_page.dart';
import 'add_payment_dialog.dart';

class PaymentDetailsPage extends StatefulWidget {
  final PaymentEntity payment;

  const PaymentDetailsPage({super.key, required this.payment});

  @override
  State<PaymentDetailsPage> createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends State<PaymentDetailsPage> {
  bool _isPdfInitialized = false;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _initializePdf();
  }

  Future<void> _initializePdf() async {
    if (_isInitializing || _isPdfInitialized) return;

    _isInitializing = true;
    setState(() {});

    try {
      await PdfUtils.initialize();
      _isPdfInitialized = PdfUtils.isReady;
      print('✅ حالة تهيئة PDF: $_isPdfInitialized');
    } catch (e) {
      print('❌ خطأ في تهيئة PDF: $e');
      _isPdfInitialized = false;
    }

    _isInitializing = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الدفعة'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          // زر التقارير المحفوظة
          IconButton(
            icon: const Icon(Icons.folder),
            onPressed: () => _navigateToSavedReports(context),
            tooltip: 'التقارير المحفوظة',
          ),
          // زر حفظ PDF
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isPdfInitialized ? _savePdfToDevice : null,
            tooltip: 'حفظ PDF',
          ),
          // زر الطباعة
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _isPdfInitialized ? _generatePdf : null,
            tooltip: 'طباعة',
          ),
          // زر التعديل
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editPayment,
            tooltip: 'تعديل الدفعة',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildPaymentInfoCard(),
          if (widget.payment.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildNotesCard(),
          ],
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('المعلومات الأساسية'),
            const SizedBox(height: 16),
            _buildInfoRow('اسم العميل', widget.payment.clientName),
            _buildInfoRow('اسم الحفلة', widget.payment.eventName),
            _buildInfoRow('تاريخ الإنشاء',
                DateFormat('yyyy-MM-dd HH:mm').format(widget.payment.createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('معلومات الدفع'),
            const SizedBox(height: 16),
            _buildInfoRow('المبلغ', '${widget.payment.amount.toStringAsFixed(0)} ر.س'),
            _buildInfoRow('طريقة الدفع', _getPaymentMethodText(widget.payment.paymentMethod)),
            _buildInfoRow('حالة الدفع', _getStatusText(widget.payment.status)),
            _buildInfoRow('تاريخ الدفع',
                DateFormat('yyyy-MM-dd').format(widget.payment.paymentDate)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('ملاحظات'),
            const SizedBox(height: 8),
            Text(
              widget.payment.notes,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.gray700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.gray500,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDeleteButton(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPdfActionButton(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSavePdfButton(),
        const SizedBox(height: 12),
        _buildSavedReportsButton(),
      ],
    );
  }

  Widget _buildDeleteButton() {
    return OutlinedButton.icon(
      onPressed: _showDeleteConfirmation,
      icon: const Icon(Icons.delete, color: AppColors.error),
      label: const Text('حذف الدفعة', style: TextStyle(color: AppColors.error)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: const BorderSide(color: AppColors.error),
      ),
    );
  }

  Widget _buildPdfActionButton() {
    return ElevatedButton.icon(
      onPressed: _isPdfInitialized ? _generatePdf : null,
      icon: _isPdfInitialized
          ? const Icon(Icons.picture_as_pdf)
          : const CircularProgressIndicator(),
      label: Text(_isPdfInitialized ? 'معاينة PDF' : 'جاري التهيئة...'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildSavePdfButton() {
    return ElevatedButton.icon(
      onPressed: _isPdfInitialized ? _savePdfToDevice : null,
      icon: _isPdfInitialized
          ? const Icon(Icons.save_alt)
          : const CircularProgressIndicator(),
      label: Text(_isPdfInitialized ? 'حفظ PDF في الجهاز' : 'جاري التهيئة...'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.success,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }

  Widget _buildSavedReportsButton() {
    return OutlinedButton.icon(
      onPressed: () => _navigateToSavedReports(context),
      icon: const Icon(Icons.folder_open),
      label: const Text('عرض التقارير المحفوظة'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }

  // ========== دوال المعالجة ==========

  void _editPayment() {
    showDialog(
      context: context,
      builder: (context) => AddPaymentDialog(
        paymentToEdit: widget.payment,
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذه الدفعة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePayment();
            },
            child: const Text('حذف', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _deletePayment() {
    context.read<PaymentCubit>().deletePayment(widget.payment.id);
    Navigator.pop(context);
  }

  // ========== دوال PDF المحسنة ==========

  Future<void> _generatePdf() async {
    if (!_isPdfInitialized) {
      _showErrorSnackBar('PDF غير جاهز، يرجى الانتظار قليلاً');
      return;
    }

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _buildPdfContent();
          },
        ),
      );

      // حفظ الملف أولاً
      final fileName = 'دفعة_${_cleanName(widget.payment.clientName)}_${DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now())}.pdf';
      final filePath = await PdfStorageService.savePdfToDevice(pdf, fileName);
      print('✅ تم حفظ الملف تلقائياً في: $filePath');

      // ثم المعاينة
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      _showSuccessSnackBar('تم إنشاء PDF بنجاح وتم حفظه تلقائياً');

    } catch (e) {
      print('❌ خطأ في إنشاء PDF: $e');
      _showErrorSnackBar('فشل في إنشاء PDF: $e');
    }
  }

  Future<void> _savePdfToDevice() async {
    if (!_isPdfInitialized) {
      _showErrorSnackBar('PDF غير جاهز، يرجى الانتظار قليلاً');
      return;
    }

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _buildPdfContent();
          },
        ),
      );

      final fileName = 'دفعة_${_cleanName(widget.payment.clientName)}_${DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now())}.pdf';
      final filePath = await PdfStorageService.savePdfToDevice(pdf, fileName);

      _showSuccessSnackBar('تم حفظ PDF بنجاح');

      // فتح الملف بعد حفظه
      await OpenFile.open(filePath);

    } catch (e) {
      print('❌ خطأ في حفظ PDF: $e');
      _showErrorSnackBar('فشل في حفظ PDF: $e');
    }
  }

  pw.Widget _buildPdfContent() {
    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Container(
        padding: const pw.EdgeInsets.all(20),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            // العنوان
            PdfUtils.buildArabicText(
              'تفاصيل الدفعة',
              fontSize: 24,
              bold: true,
            ),
            pw.SizedBox(height: 20),

            // بطاقة المعلومات الأساسية
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blue),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  _buildPdfDetailRow('اسم العميل:', widget.payment.clientName),
                  _buildPdfDetailRow('اسم الحفلة:', widget.payment.eventName),
                  _buildPdfDetailRow('المبلغ:', '${widget.payment.amount.toStringAsFixed(0)} ر.س'),
                  _buildPdfDetailRow('طريقة الدفع:', _getPaymentMethodText(widget.payment.paymentMethod)),
                  _buildPdfDetailRow('حالة الدفع:', _getStatusText(widget.payment.status)),
                  _buildPdfDetailRow('تاريخ الدفع:', DateFormat('yyyy-MM-dd').format(widget.payment.paymentDate)),
                  _buildPdfDetailRow('تاريخ الإضافة:', DateFormat('yyyy-MM-dd - HH:mm').format(widget.payment.createdAt)),
                  _buildPdfDetailRow('ملاحظات:', widget.payment.notes.isEmpty ? 'لا توجد' : widget.payment.notes),
                  _buildPdfDetailRow('المعرف:', widget.payment.id),
                ],
              ),
            ),

            pw.SizedBox(height: 30),

            // تذييل الصفحة
            PdfUtils.buildArabicText(
              'تم إنشاء هذا التقرير في: ${DateFormat('yyyy-MM-dd - HH:mm').format(DateTime.now())}',
              fontSize: 12,
              color: PdfColors.grey,
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildPdfDetailRow(String label, String value) {
    return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 15),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Expanded(
              child: PdfUtils.buildArabicText(value, fontSize: 14),
            ),
            pw.SizedBox(width: 20),
            pw.Container(
              width: 100,
              child: PdfUtils.buildArabicText(
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

  // ========== دوال مساعدة ==========

  String _getPaymentMethodText(String method) {
    switch (method) {
      case 'cash':
        return 'نقدي';
      case 'bank_transfer':
        return 'تحويل بنكي';
      case 'credit_card':
        return 'بطاقة ائتمان';
      default:
        return method;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'مكتمل';
      case 'pending':
        return 'معلق';
      case 'failed':
        return 'فاشل';
      default:
        return status;
    }
  }

  String _cleanName(String name) {
    return name.replaceAll(' ', '_').replaceAll(RegExp(r'[^\w]'), '');
  }

  void _navigateToSavedReports(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavedPaymentsReportsPage(),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }
}
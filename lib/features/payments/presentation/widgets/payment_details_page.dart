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
          : _buildLoadingIndicator(),
      label: _isPdfInitialized
          ? const Text('معاينة PDF')
          : const Text('جاري التحميل...'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildSavePdfButton() {
    return OutlinedButton.icon(
      onPressed: _isPdfInitialized ? _savePdfToDevice : null,
      icon: const Icon(Icons.save, color: AppColors.info),
      label: const Text('حفظ PDF على الجهاز', style: TextStyle(color: AppColors.info)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: const BorderSide(color: AppColors.info),
      ),
    );
  }

  Widget _buildSavedReportsButton() {
    return OutlinedButton.icon(
      onPressed: () => _navigateToSavedReports(context),
      icon: const Icon(Icons.folder_open, color: AppColors.warning),
      label: const Text('عرض التقارير المحفوظة', style: TextStyle(color: AppColors.warning)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: const BorderSide(color: AppColors.warning),
      ),
    );
  }

  Widget _buildLoadingIndicator({double size = 16}) {
    return SizedBox(
      width: size,
      height: size,
      child: const CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
      ),
    );
  }

  void _editPayment() {
    showDialog(
      context: context,
      builder: (context) => AddPaymentDialog(paymentToEdit: widget.payment),
    ).then((_) {
      if (mounted) {
        context.read<PaymentCubit>().loadPayments();
      }
    });
  }

  void _navigateToSavedReports(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SavedPaymentsReportsPage(),
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: _deletePayment,
            child: const Text('حذف', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _deletePayment() {
    // إغلاق dialog التأكيد أولاً
    Navigator.of(context).pop();

    // إظهار تحميل
    _showLoadingDialog('جاري حذف الدفعة...');

    // تنفيذ الحذف مباشرة
    context.read<PaymentCubit>().deletePayment(widget.payment.id);

    // إغلاق الصفحات بعد فترة قصيرة
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pop(); // إغلاق dialog التحميل
        Navigator.of(context).pop(); // العودة للصفحة السابقة

        // إظهار رسالة النجاح
        _showSnackBar('تم حذف الدفعة بنجاح', AppColors.success);
      }
    });
  }

  Future<void> _generatePdf() async {
    if (!_isPdfInitialized) {
      _showSnackBar('الخطوط غير جاهزة، يرجى الانتظار...', AppColors.warning);
      return;
    }

    try {
      _showLoadingDialog('جاري معاينة PDF...');

      final pdf = pw.Document();
      pdf.addPage(_buildPdfPage());

      if (mounted) {
        Navigator.of(context).pop();
      }

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        _showSnackBar('خطأ في معاينة PDF: $e', AppColors.error);
      }
    }
  }

  Future<void> _savePdfToDevice() async {
    if (!_isPdfInitialized) {
      _showSnackBar('الخطوط غير جاهزة، يرجى الانتظار...', AppColors.warning);
      return;
    }

    try {
      _showLoadingDialog('جاري حفظ PDF...');

      final hasPermission = await PdfStorageService.checkStoragePermission();
      if (!hasPermission) {
        if (mounted) {
          Navigator.of(context).pop();
          _showSnackBar('تم رفض إذن التخزين', AppColors.error);
        }
        return;
      }

      final pdf = pw.Document();
      pdf.addPage(_buildPdfPage());
      final Uint8List pdfBytes = await pdf.save();

      if (mounted) {
        Navigator.of(context).pop();
      }

      final fileName = 'دفعة_${_cleanName(widget.payment.clientName)}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}';
      final savedPath = await PdfStorageService.savePdfToDevice(pdfBytes, fileName);

      if (savedPath != null) {
        // فتح الملف بعد حفظه
        await OpenFile.open(savedPath);

        _showSaveSuccessDialog(savedPath, fileName);
      } else {
        _showSnackBar('فشل في حفظ الملف - تأكد من أذونات التخزين', AppColors.error);
      }

    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        _showSnackBar('خطأ في حفظ PDF: $e', AppColors.error);
      }
    }
  }

  String _cleanName(String name) {
    return name.replaceAll(' ', '_').replaceAll(RegExp(r'[^\w]'), '');
  }

  void _showSaveSuccessDialog(String filePath, String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 8),
            Text('تم الحفظ بنجاح'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('تم حفظ ملف PDF بنجاح وفتحه'),
            const SizedBox(height: 8),
            Text(
              '$fileName.pdf',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getShortPath(filePath),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.gray600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'تم إضافة الملف إلى التقارير المحفوظة تلقائياً',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('موافق'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // الانتقال إلى صفحة التقارير المحفوظة
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SavedPaymentsReportsPage(),
                ),
              );
            },
            child: const Text('عرض التقارير'),
          ),
        ],
      ),
    );
  }

  String _getShortPath(String fullPath) {
    if (fullPath.length > 50) {
      return '...${fullPath.substring(fullPath.length - 50)}';
    }
    return fullPath;
  }

  Future<void> _openPdfFile(String filePath) async {
    final success = await PdfStorageService.openPdfFile(filePath);
    if (!success) {
      _showSnackBar('تعذر فتح الملف', AppColors.warning);
    }
  }

  pw.Page _buildPdfPage() {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(30),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildPdfHeader(),
                pw.SizedBox(height: 30),
                _buildPdfSection('المعلومات الأساسية', _buildBasicInfo()),
                pw.SizedBox(height: 20),
                _buildPdfSection('معلومات الدفع', _buildPaymentInfo()),
                if (widget.payment.notes.isNotEmpty) ...[
                  pw.SizedBox(height: 20),
                  _buildPdfSection('ملاحظات', _buildNotesInfo()),
                ],
                pw.SizedBox(height: 40),
                _buildPdfFooter(),
              ],
            ),
          ),
        );
      },
    );
  }

  pw.Widget _buildPdfHeader() {
    return pw.Column(
      children: [
        pw.Center(
          child: pw.Text(
            'تفاصيل الدفعة',
            style: PdfUtils.getArabicTextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Center(
          child: pw.Text(
            'رقم المرجع: ${widget.payment.id}',
            style: PdfUtils.getArabicTextStyle(
              fontSize: 12,
              color: PdfColors.grey600,
            ),
          ),
        ),
      ],
    );
  }

  List<pw.Widget> _buildBasicInfo() {
    return [
      _buildPdfRow('اسم العميل', widget.payment.clientName),
      _buildPdfRow('اسم الحفلة', widget.payment.eventName),
      _buildPdfRow('تاريخ الإنشاء',
          DateFormat('yyyy-MM-dd HH:mm').format(widget.payment.createdAt)),
    ];
  }

  List<pw.Widget> _buildPaymentInfo() {
    return [
      _buildPdfRow('المبلغ', '${widget.payment.amount.toStringAsFixed(0)} ر.س'),
      _buildPdfRow('طريقة الدفع', _getPaymentMethodText(widget.payment.paymentMethod)),
      _buildPdfRow('حالة الدفع', _getStatusText(widget.payment.status)),
      _buildPdfRow('تاريخ الدفع',
          DateFormat('yyyy-MM-dd').format(widget.payment.paymentDate)),
    ];
  }

  List<pw.Widget> _buildNotesInfo() {
    return [
      pw.Text(
        widget.payment.notes,
        style: PdfUtils.getArabicTextStyle(fontSize: 14),
      ),
    ];
  }

  pw.Widget _buildPdfSection(String title, List<pw.Widget> children) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blue800, width: 1),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: PdfUtils.getArabicTextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  pw.Widget _buildPdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: PdfUtils.getArabicTextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.Text(
            value,
            style: PdfUtils.getArabicTextStyle(
              color: PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfFooter() {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
          children: [
            _buildSignatureField(),
            _buildDateField(),
          ],
        ),
        pw.SizedBox(height: 30),
        _buildPdfDivider(),
        pw.SizedBox(height: 10),
        _buildPdfFooterText(),
      ],
    );
  }

  pw.Widget _buildSignatureField() {
    return pw.Column(
      children: [
        pw.Container(
          width: 150,
          height: 1,
          color: PdfColors.black,
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'التوقيع',
          style: PdfUtils.getArabicTextStyle(
            fontSize: 12,
            color: PdfColors.grey600,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildDateField() {
    return pw.Column(
      children: [
        pw.Text(
          'التاريخ: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
          style: PdfUtils.getArabicTextStyle(
            fontSize: 12,
            color: PdfColors.grey600,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPdfDivider() {
    return pw.Container(
      width: double.infinity,
      height: 1,
      color: PdfColors.grey300,
    );
  }

  pw.Widget _buildPdfFooterText() {
    return pw.Center(
      child: pw.Text(
        'تم إنشاء هذا المستند تلقائياً - نظام إدارة المدفوعات',
        style: PdfUtils.getArabicTextStyle(
          fontSize: 10,
          color: PdfColors.grey500,
        ),
      ),
    );
  }

  void _showLoadingDialog([String message = 'جاري المعالجة...']) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed': return 'مكتمل';
      case 'pending': return 'معلق';
      case 'failed': return 'فاشل';
      default: return status;
    }
  }

  String _getPaymentMethodText(String paymentMethod) {
    switch (paymentMethod) {
      case 'cash': return 'نقدي';
      case 'bank_transfer': return 'تحويل بنكي';
      case 'credit_card': return 'بطاقة ائتمان';
      default: return paymentMethod;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
// features/payments/presentation/widgets/payment_details_dialog.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'add_payment_dialog.dart';

class PaymentDetailsDialog extends StatefulWidget {
  final PaymentEntity payment;

  const PaymentDetailsDialog({super.key, required this.payment});

  @override
  State<PaymentDetailsDialog> createState() => _PaymentDetailsDialogState();
}

class _PaymentDetailsDialogState extends State<PaymentDetailsDialog> {
  bool _isPdfInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePdf();
  }

  Future<void> _initializePdf() async {
    try {
      await PdfUtils.initialize();
      setState(() {
        _isPdfInitialized = PdfUtils.isReady;
      });
    } catch (e) {
      print('❌ خطأ في تهيئة PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // الهيدر
            _buildHeader(context),
            const SizedBox(height: 16),

            // المحتوى
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // بطاقة رأس الدفعة
                  _buildHeaderCard(),
                  const SizedBox(height: 16),

                  // بطاقة المعلومات الأساسية
                  _buildBasicInfoCard(),
                  const SizedBox(height: 16),

                  // بطاقة معلومات الدفع
                  _buildPaymentInfoCard(),
                  const SizedBox(height: 16),

                  // بطاقة الملاحظات إذا كانت موجودة
                  if (widget.payment.notes.isNotEmpty) ...[
                    _buildNotesCard(),
                    const SizedBox(height: 16),
                  ],

                  // أزرار الإجراءات
                  _buildActionButtons(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.deepRed,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.payment, color: AppColors.paleGold, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'تفاصيل الدفعة',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.paleGold,
                fontFamily: 'Tajawal',
              ),
              textAlign: TextAlign.right,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.paleGold),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [
              AppColors.deepRed.withOpacity(0.9),
              AppColors.deepRed.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.payment.clientName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                            fontFamily: 'Tajawal',
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.payment.eventName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.white,
                            fontFamily: 'Tajawal',
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.payment,
                      color: AppColors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.white.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusChip(),
                    Text(
                      '${widget.payment.amount.toStringAsFixed(0)} ر.س',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                        fontFamily: 'Tajawal',
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    final statusInfo = _getStatusInfo(widget.payment.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusInfo.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusInfo.color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusInfo.icon,
            size: 14,
            color: statusInfo.color,
          ),
          const SizedBox(width: 4),
          Text(
            statusInfo.text,
            style: TextStyle(
              color: statusInfo.color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              fontFamily: 'Tajawal',
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              title: 'المعلومات الأساسية',
              icon: Icons.info_outline,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.person,
              label: 'اسم العميل',
              value: widget.payment.clientName,
            ),
            _buildInfoRow(
              icon: Icons.event,
              label: 'اسم الحفلة',
              value: widget.payment.eventName,
            ),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'تاريخ الإنشاء',
              value: DateFormat('yyyy-MM-dd HH:mm').format(widget.payment.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              title: 'معلومات الدفع',
              icon: Icons.credit_card,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.attach_money,
              label: 'المبلغ',
              value: '${widget.payment.amount.toStringAsFixed(0)} ر.س',
            ),
            _buildInfoRow(
              icon: Icons.payment,
              label: 'طريقة الدفع',
              value: _getPaymentMethodText(widget.payment.paymentMethod),
            ),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'تاريخ الدفع',
              value: DateFormat('yyyy-MM-dd').format(widget.payment.paymentDate),
            ),
            _buildInfoRow(
              icon: Icons.fingerprint,
              label: 'معرف الدفعة',
              value: widget.payment.id,
              showCopyButton: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              title: 'ملاحظات',
              icon: Icons.notes,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.gray200),
              ),
              child: Text(
                widget.payment.notes,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.gray700,
                  height: 1.4,
                  fontFamily: 'Tajawal',
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required IconData icon}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.deepRed.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.deepRed,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.deepRed,
            fontFamily: 'Tajawal',
          ),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool showCopyButton = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showCopyButton)
            IconButton(
              icon: const Icon(Icons.content_copy, size: 16),
              onPressed: () => _copyToClipboard(value),
              color: AppColors.gray500,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    fontFamily: 'Tajawal',
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.gray500,
                        fontFamily: 'Tajawal',
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      icon,
                      size: 12,
                      color: AppColors.gray500,
                    ),
                  ],
                ),
              ],
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
              child: OutlinedButton.icon(
                onPressed: _editPayment,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text(
                  'تعديل الدفعة',
                  style: TextStyle(fontFamily: 'Tajawal'),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.deepRed,
                  side: const BorderSide(color: AppColors.deepRed),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isPdfInitialized ? _savePdfToDevice : null,
                icon: const Icon(Icons.picture_as_pdf, size: 18),
                label: const Text(
                  'حفظ PDF',
                  style: TextStyle(fontFamily: 'Tajawal'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepRed,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: _printPdf,
                icon: const Icon(Icons.print, size: 18),
                label: const Text(
                  'طباعة مباشرة',
                  style: TextStyle(fontFamily: 'Tajawal'),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.deepRed,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _confirmDeletePayment,
                icon: const Icon(Icons.delete, size: 18),
                label: const Text(
                  'حذف الدفعة',
                  style: TextStyle(fontFamily: 'Tajawal'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // دوال المعالجة
  void _editPayment() {
    Navigator.of(context).pop(); // إغلاق الـ Dialog الحالي
    showDialog(
      context: context,
      builder: (context) => AddPaymentDialog(
        paymentToEdit: widget.payment,
      ),
    ).then((_) {
      context.read<PaymentCubit>().loadPayments();
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم نسخ النص',
          style: TextStyle(fontFamily: 'Tajawal'),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmDeletePayment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('تأكيد الحذف'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('هل أنت متأكد من حذف هذه الدفعة؟'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.payment.clientName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.payment.eventName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.payment.amount.toStringAsFixed(0)} ر.س',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'لا يمكن التراجع عن هذا الإجراء.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: _deletePayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _deletePayment() {
    Navigator.of(context).pop(); // إغلاق dialog التأكيد
    Navigator.of(context).pop(); // إغلاق dialog التفاصيل

    context.read<PaymentCubit>().deletePayment(widget.payment.id);

    // إظهار رسالة نجاح
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم حذف الدفعة بنجاح',
          style: TextStyle(fontFamily: 'Tajawal'),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _savePdfToDevice() async {
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم حفظ PDF بنجاح',
            style: TextStyle(fontFamily: 'Tajawal'),
          ),
          backgroundColor: AppColors.success,
        ),
      );

      await OpenFile.open(filePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'فشل في حفظ PDF: $e',
            style: const TextStyle(fontFamily: 'Tajawal'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _printPdf() async {
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

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'فشل في الطباعة: $e',
            style: const TextStyle(fontFamily: 'Tajawal'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  pw.Widget _buildPdfContent() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          PdfUtils.buildArabicText(
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
                _buildPdfDetailRow('اسم العميل:', widget.payment.clientName),
                _buildPdfDetailRow('اسم الحفلة:', widget.payment.eventName),
                _buildPdfDetailRow('المبلغ:', '${widget.payment.amount.toStringAsFixed(0)} ر.س'),
                _buildPdfDetailRow('طريقة الدفع:', _getPaymentMethodText(widget.payment.paymentMethod)),
                _buildPdfDetailRow('حالة الدفع:', _getStatusText(widget.payment.status)),
                _buildPdfDetailRow('تاريخ الدفع:', DateFormat('yyyy-MM-dd').format(widget.payment.paymentDate)),
                _buildPdfDetailRow('ملاحظات:', widget.payment.notes.isEmpty ? 'لا توجد' : widget.payment.notes),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfDetailRow(String label, String value) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          PdfUtils.buildArabicText(value, fontSize: 14),
          pw.SizedBox(width: 10),
          PdfUtils.buildArabicText(label, fontSize: 14, bold: true),
        ],
      ),
    );
  }

  // دوال مساعدة
  String _getPaymentMethodText(String method) {
    switch (method) {
      case 'cash': return 'نقدي';
      case 'bank_transfer': return 'تحويل بنكي';
      case 'credit_card': return 'بطاقة ائتمان';
      default: return method;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed': return 'مكتمل';
      case 'pending': return 'معلق';
      case 'failed': return 'فاشل';
      default: return status;
    }
  }

  _StatusInfo _getStatusInfo(String status) {
    switch (status) {
      case 'completed':
        return _StatusInfo('مكتمل', Colors.green, Icons.check_circle);
      case 'pending':
        return _StatusInfo('معلق', Colors.orange, Icons.pending);
      case 'failed':
        return _StatusInfo('فاشل', Colors.red, Icons.error);
      default:
        return _StatusInfo(status, Colors.grey, Icons.help);
    }
  }

  String _cleanName(String name) {
    return name.replaceAll(' ', '_').replaceAll(RegExp(r'[^\w]'), '');
  }
}

class _StatusInfo {
  final String text;
  final Color color;
  final IconData icon;

  _StatusInfo(this.text, this.color, this.icon);
}
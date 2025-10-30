// features/payments/presentation/widgets/payment_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:new_wedding_hall/features/payments/presentation/widgets/payment_details_page.dart' show PaymentDetailsPage;

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/payment_entity.dart';
import '../cubit/payment_cubit.dart';

import 'add_payment_dialog.dart';

class PaymentCard extends StatelessWidget {
  final PaymentEntity payment;

  const PaymentCard({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          print('🎯 تم النقر على البطاقة: ${payment.clientName}');
          _navigateToDetailsPage(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الصف الأول: اسم العميل وحالة الدفع
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      payment.clientName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(payment.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getStatusColor(payment.status).withOpacity(0.3)),
                    ),
                    child: Text(
                      _getStatusText(payment.status),
                      style: TextStyle(
                        color: _getStatusColor(payment.status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // الصف الثاني: اسم الحفلة
              Text(
                payment.eventName,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.gray500,
                ),
              ),
              const SizedBox(height: 12),

              // الصف الثالث: المبلغ وتاريخ الدفع
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${payment.amount.toStringAsFixed(0)} ر.س',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: AppColors.gray500),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('yyyy-MM-dd').format(payment.paymentDate),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // الصف الرابع: طريقة الدفع والملاحظات
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getPaymentMethodText(payment.paymentMethod),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.gray500,
                      ),
                    ),
                  ),
                  if (payment.notes.isNotEmpty)
                    Expanded(
                      child: Text(
                        payment.notes,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.gray500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                ],
              ),

              // زر الإجراءات
              const SizedBox(height: 12),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  // أزرار الإجراءات المحسنة
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // زر التعديل
        _buildActionButton(
          icon: Icons.edit,
          color: AppColors.info,
          tooltip: 'تعديل الدفعة',
          onPressed: () => _showEditPaymentDialog(context, payment),
        ),
        const SizedBox(width: 8),

        // قائمة المزيد من الخيارات
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'details',
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  const Text('تفاصيل'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'save_pdf',
              child: Row(
                children: [
                  Icon(Icons.save, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  const Text('حفظ PDF'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'print_pdf',
              child: Row(
                children: [
                  Icon(Icons.print, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  const Text('طباعة PDF'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  const Text('حذف'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'details':
                _navigateToDetailsPage(context);
                break;
              case 'save_pdf':
                _generateAndSavePdf(context);
                break;
              case 'print_pdf':
                _generateAndPrintPdf(context);
                break;
              case 'delete':
                _showDeleteConfirmation(context, payment.id);
                break;
            }
          },
        ),
      ],
    );
  }

  // زر الإجراءات المصغّر
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: IconButton(
          icon: Icon(icon, size: 16),
          onPressed: onPressed,
          color: color,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ),
    );
  }

  // الانتقال لصفحة التفاصيل
  void _navigateToDetailsPage(BuildContext context) {
    print('🚀 جارٍ الانتقال إلى صفحة التفاصيل...');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentDetailsPage(payment: payment),
      ),
    );
  }

  // عرض dialog التعديل
  void _showEditPaymentDialog(BuildContext context, PaymentEntity payment) {
    showDialog(
      context: context,
      builder: (context) => AddPaymentDialog(paymentToEdit: payment),
    );
  }

  // حفظ PDF فردي
  void _generateAndSavePdf(BuildContext context) {
    context.read<PaymentCubit>().generateAndSaveSinglePaymentPdf(payment);

    // إظهار رسالة تأكيد
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم حفظ الدفعة كملف PDF على جهازك'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // طباعة PDF فردي
  void _generateAndPrintPdf(BuildContext context) {
    context.read<PaymentCubit>().generateSinglePaymentPdf(payment);

    // إظهار رسالة تأكيد
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('جاري إعداد الدفعة للطباعة'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // عرض تأكيد الحذف
  void _showDeleteConfirmation(BuildContext context, String paymentId) {
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
            onPressed: () {
              context.read<PaymentCubit>().deletePayment(paymentId);
              Navigator.of(context).pop();
            },
            child: const Text(
              'حذف',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  // دوال مساعدة
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.gray500;
    }
  }

  String _getPaymentMethodText(String paymentMethod) {
    switch (paymentMethod) {
      case 'cash':
        return 'نقدي';
      case 'bank_transfer':
        return 'تحويل بنكي';
      case 'credit_card':
        return 'بطاقة ائتمان';
      default:
        return paymentMethod;
    }
  }
}
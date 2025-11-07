// features/payments/presentation/widgets/payment_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:new_wedding_hall/features/payments/presentation/widgets/payment_details_page.dart';


import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/payment_entity.dart';
import '../cubit/payment_cubit.dart';

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
          _showPaymentDetails(context);
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
                        color: AppColors.deepRed,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(payment.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(payment.status).withOpacity(0.3),
                      ),
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
                style: const TextStyle(fontSize: 14, color: AppColors.deepRed),
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
                      color: AppColors.deepRed,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('yyyy-MM-dd').format(payment.paymentDate),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.gold,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getPaymentMethodText(payment.paymentMethod),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.deepRed,
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

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showPaymentDetails(context),
            icon: const Icon(Icons.visibility, size: 16),
            label: const Text(
              'عرض التفاصيل',
              style: TextStyle(fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.deepRed,
              side: const BorderSide(color: AppColors.deepRed),
              padding: const EdgeInsets.symmetric(vertical: 6),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.picture_as_pdf, size: 20),
          color: AppColors.deepRed,
          onPressed: () {
            context.read<PaymentCubit>().generateAndSaveSinglePaymentPdf(payment);
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete, size: 20),
          color: Colors.red,
          onPressed: () => _confirmDelete(context),
        ),
      ],
    );
  }

  void _showPaymentDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PaymentDetailsDialog(payment: payment),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف دفعة ${payment.clientName}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<PaymentCubit>().deletePayment(payment.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
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
}
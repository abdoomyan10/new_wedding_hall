// features/payments/domain/entities/payment_entity.dart
import 'package:flutter/material.dart';

class PaymentEntity {
  final String id;
  final String eventId;
  final String eventName;
  final String clientName;
  final double amount;
  final DateTime paymentDate;
  final String paymentMethod; // cash, bank_transfer, credit_card
  final String status; // completed, pending, failed
  final String notes;
  final DateTime createdAt;

  const PaymentEntity({
    required this.id,
    required this.eventId,
    required this.eventName,
    required this.clientName,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    required this.status,
    required this.notes,
    required this.createdAt,
  });

  String get paymentMethodText {
    switch (paymentMethod) {
      case 'cash': return 'نقدي';
      case 'bank_transfer': return 'تحويل بنكي';
      case 'credit_card': return 'بطاقة ائتمان';
      default: return paymentMethod;
    }
  }

  String get statusText {
    switch (status) {
      case 'completed': return 'مكتمل';
      case 'pending': return 'معلق';
      case 'failed': return 'فاشل';
      default: return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'completed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'failed': return Colors.red;
      default: return Colors.grey;
    }
  }
}
// features/payments/domain/entities/payment_entity.dart
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
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

  // دالة لإنشاء نسخة من الكائن للتعديل
  PaymentEntity copyWith({
    String? id,
    String? eventId,
    String? eventName,
    String? clientName,
    double? amount,
    DateTime? paymentDate,
    String? paymentMethod,
    String? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return PaymentEntity(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      eventName: eventName ?? this.eventName,
      clientName: clientName ?? this.clientName,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // دالة لتحويل الكائن إلى Map (مفيدة للتخزين)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'eventName': eventName,
      'clientName': clientName,
      'amount': amount,
      'paymentDate': paymentDate.millisecondsSinceEpoch,
      'paymentMethod': paymentMethod,
      'status': status,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // دالة لإنشاء كائن من Map
  factory PaymentEntity.fromMap(Map<String, dynamic> map) {
    return PaymentEntity(
      id: map['id'] ?? '',
      eventId: map['eventId'] ?? '',
      eventName: map['eventName'] ?? '',
      clientName: map['clientName'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      paymentDate: DateTime.fromMillisecondsSinceEpoch(map['paymentDate'] ?? 0),
      paymentMethod: map['paymentMethod'] ?? 'cash',
      status: map['status'] ?? 'pending',
      notes: map['notes'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  // دالة للتحقق من صحة البيانات
  bool get isValid {
    return id.isNotEmpty &&
        eventId.isNotEmpty &&
        eventName.isNotEmpty &&
        clientName.isNotEmpty &&
        amount > 0 &&
        paymentDate.isBefore(DateTime.now().add(const Duration(days: 365))) &&
        paymentDate.isAfter(DateTime(2020));
  }

  // دالة للحصول على معلومات الدفعة كـ String
  String get paymentInfo {
    return '''
الدفعة: $id
العميل: $clientName
الحفلة: $eventName
المبلغ: ${amount.toStringAsFixed(2)} ر.س
طريقة الدفع: $paymentMethodText
الحالة: $statusText
تاريخ الدفع: ${_formatDate(paymentDate)}
ملاحظات: ${notes.isEmpty ? 'لا توجد ملاحظات' : notes}
''';
  }

  // دالة مساعدة لتنسيق التاريخ
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  List<Object> get props {
    return [
      id,
      eventId,
      eventName,
      clientName,
      amount,
      paymentDate,
      paymentMethod,
      status,
      notes,
      createdAt,
    ];
  }

  @override
  String toString() {
    return 'PaymentEntity(id: $id, clientName: $clientName, eventName: $eventName, amount: $amount, status: $status)';
  }
}
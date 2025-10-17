// features/payments/data/models/payment_model.dart
import '../../domain/entities/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.eventId,
    required super.eventName,
    required super.clientName,
    required super.amount,
    required super.paymentDate,
    required super.paymentMethod,
    required super.status,
    required super.notes,
    required super.createdAt,
  });

  factory PaymentModel.fromEntity(PaymentEntity entity) {
    return PaymentModel(
      id: entity.id,
      eventId: entity.eventId,
      eventName: entity.eventName,
      clientName: entity.clientName,
      amount: entity.amount,
      paymentDate: entity.paymentDate,
      paymentMethod: entity.paymentMethod,
      status: entity.status,
      notes: entity.notes,
      createdAt: entity.createdAt,
    );
  }

  PaymentEntity toEntity() {
    return PaymentEntity(
      id: id,
      eventId: eventId,
      eventName: eventName,
      clientName: clientName,
      amount: amount,
      paymentDate: paymentDate,
      paymentMethod: paymentMethod,
      status: status,
      notes: notes,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'eventName': eventName,
      'clientName': clientName,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'paymentMethod': paymentMethod,
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      eventName: json['eventName'] as String,
      clientName: json['clientName'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      paymentMethod: json['paymentMethod'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
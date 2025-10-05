// features/payments/data/models/payment_model.dart
import '../../domain/entities/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  PaymentModel({
    required String id,
    required String eventId,
    required String eventName,
    required String clientName,
    required double amount,
    required DateTime paymentDate,
    required String paymentMethod,
    required String status,
    required String notes,
    required DateTime createdAt,
  }) : super(
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
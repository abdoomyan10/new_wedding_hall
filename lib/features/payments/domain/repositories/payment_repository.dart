// features/payments/domain/repositories/payment_repository.dart
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/payment_entity.dart';
import '../entities/payment_state_entity.dart';

abstract class PaymentRepository {

  Future<Either<Failure, List<PaymentEntity>>> getPayments();
  Future<Either<Failure, void>> addPayment(PaymentEntity payment);
  Future<Either<Failure, void>> updatePayment(PaymentEntity payment);
  Future<Either<Failure, void>> deletePayment(String paymentId);
  Future<Either<Failure, PaymentStatsEntity>> getPaymentStats();
  Future<Either<Failure, List<PaymentEntity>>> getPaymentsByEvent(String eventId);
}

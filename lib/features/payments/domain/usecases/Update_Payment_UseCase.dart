// features/payments/domain/usecases/update_payment_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:wedding_hall/core/error/failure.dart';
import 'package:wedding_hall/features/payments/domain/entities/payment_entity.dart';
import 'package:wedding_hall/features/payments/domain/repositories/payment_repository.dart';

class UpdatePaymentUseCase {
  final PaymentRepository repository;

  UpdatePaymentUseCase(this.repository);

  Future<Either<Failure, void>> call(PaymentEntity payment) async {
    return await repository.updatePayment(payment);
  }
}
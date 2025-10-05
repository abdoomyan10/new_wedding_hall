// features/payments/domain/usecases/get_payments_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:wedding_hall/core/error/failure.dart';
import 'package:wedding_hall/features/payments/domain/entities/payment_entity.dart';
import 'package:wedding_hall/features/payments/domain/repositories/payment_repository.dart';

class GetPaymentsUseCase {
  final PaymentRepository repository;

  GetPaymentsUseCase(this.repository);

  Future<Either<Failure, List<PaymentEntity>>> call() async {
    return await repository.getPayments();
  }
}
import 'package:dartz/dartz.dart';
import 'package:new_wedding_hall/core/error/failure.dart';
import 'package:new_wedding_hall/core/usecase/usecase.dart';

import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

class AddPaymentUseCase implements UseCase<void, PaymentEntity> {
  final PaymentRepository repository;

  AddPaymentUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(PaymentEntity payment) async {
    return await repository.addPayment(payment);
  }
}

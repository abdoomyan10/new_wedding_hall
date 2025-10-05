// features/payments/domain/usecases/delete_payment_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:wedding_hall/core/error/failure.dart';
import 'package:wedding_hall/core/usecase/usecase.dart';
import 'package:wedding_hall/features/payments/domain/repositories/payment_repository.dart';

class DeletePaymentUseCase implements UseCase<void, String> {
  final PaymentRepository repository;

  DeletePaymentUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String paymentId) async {
    return await repository.deletePayment(paymentId);
  }
}
// features/payments/domain/usecases/get_payment_stats_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:wedding_hall/core/error/failure.dart';
import 'package:wedding_hall/features/payments/domain/repositories/payment_repository.dart';

import '../entities/payment_state_entity.dart';

class GetPaymentStatsUseCase {
  final PaymentRepository repository;

  GetPaymentStatsUseCase(this.repository);

  Future<Either<Failure, PaymentStatsEntity>> call() async {
    return await repository.getPaymentStats();
  }
}
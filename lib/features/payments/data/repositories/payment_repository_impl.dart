// features/payments/data/repositories/payment_repository_impl.dart
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/payment_entity.dart';
//import '../../domain/entities/payment_stats_entity.dart';
import '../../domain/entities/payment_state_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_data_source.dart';
import '../models/payment_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentDataSource dataSource;
  final NetworkInfo networkInfo;

  PaymentRepositoryImpl({
    required this.dataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<PaymentEntity>>> getPayments() async {
    try {
      if (await networkInfo.isConnected) {
        final payments = await dataSource.getPayments();
        return Right(payments);
      } else {
        return Left(NetworkFailure());
      }
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addPayment(PaymentEntity payment) async {
    try {
      if (await networkInfo.isConnected) {
        await dataSource.addPayment(PaymentModel(
          id: payment.id,
          eventId: payment.eventId,
          eventName: payment.eventName,
          clientName: payment.clientName,
          amount: payment.amount,
          paymentDate: payment.paymentDate,
          paymentMethod: payment.paymentMethod,
          status: payment.status,
          notes: payment.notes,
          createdAt: payment.createdAt,
        ));
        return const Right(null);
      } else {
        return Left(NetworkFailure());
      }
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updatePayment(PaymentEntity payment) async {
    try {
      if (await networkInfo.isConnected) {
        await dataSource.updatePayment(PaymentModel(
          id: payment.id,
          eventId: payment.eventId,
          eventName: payment.eventName,
          clientName: payment.clientName,
          amount: payment.amount,
          paymentDate: payment.paymentDate,
          paymentMethod: payment.paymentMethod,
          status: payment.status,
          notes: payment.notes,
          createdAt: payment.createdAt,
        ));
        return const Right(null);
      } else {
        return Left(NetworkFailure());
      }
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deletePayment(String paymentId) async {
    try {
      if (await networkInfo.isConnected) {
        await dataSource.deletePayment(paymentId);
        return const Right(null);
      } else {
        return Left(NetworkFailure());
      }
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, PaymentStatsEntity>> getPaymentStats() async {
    try {
      if (await networkInfo.isConnected) {
        final stats = await dataSource.getPaymentStats();
        return Right(stats);
      } else {
        return Left(NetworkFailure());
      }
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<PaymentEntity>>> getPaymentsByEvent(String eventId) async {
    try {
      if (await networkInfo.isConnected) {
        final allPayments = await dataSource.getPayments();
        final eventPayments = allPayments.where((p) => p.eventId == eventId).toList();
        return Right(eventPayments);
      } else {
        return Left(NetworkFailure());
      }
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
// features/payments/presentation/cubit/payment_state.dart
part of 'payment_cubit.dart';

@immutable
abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentLoaded extends PaymentState {
  final List<PaymentEntity> payments;
  final PaymentStatsEntity? stats;

  PaymentLoaded(this.payments, [this.stats]);
}

class PaymentError extends PaymentState {
  final String message;

  PaymentError(this.message);
}
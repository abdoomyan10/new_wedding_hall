// features/payments/presentation/cubit/payment_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

// استيرادات Use Cases المطلوبة

import '../../domain/usecases/add_payment_usecase.dart';
import '../../domain/usecases/get_payment_usecase.dart';
import '../../domain/usecases/get_payments_stats_usecase.dart';
import '../../domain/usecases/update_payment_usecase.dart';
import '../../domain/usecases/delete_payment_usecase.dart';

// استيرادات الكيانات
import '../../domain/entities/payment_entity.dart';
import '../../domain/entities/payment_state_entity.dart';

part 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final GetPaymentsUseCase getPaymentsUseCase;
  final AddPaymentUseCase addPaymentUseCase;
  final UpdatePaymentUseCase updatePaymentUseCase;
  final DeletePaymentUseCase deletePaymentUseCase;
  final GetPaymentStatsUseCase getPaymentStatsUseCase;

  PaymentCubit({
    required this.getPaymentsUseCase,
    required this.addPaymentUseCase,
    required this.updatePaymentUseCase,
    required this.deletePaymentUseCase,
    required this.getPaymentStatsUseCase,
  }) : super(PaymentInitial());

  void loadPayments() async {
    emit(PaymentLoading());
    final paymentsResult = await getPaymentsUseCase();
    final statsResult = await getPaymentStatsUseCase();

    paymentsResult.fold(
          (failure) => emit(PaymentError(failure.toString())),
          (payments) {
        statsResult.fold(
              (failure) => emit(PaymentLoaded(payments)),
              (stats) => emit(PaymentLoaded(payments, stats)),
        );
      },
    );
  }

  void addPayment(PaymentEntity payment) async {
    final result = await addPaymentUseCase(payment);
    result.fold(
          (failure) => emit(PaymentError(failure.toString())),
          (_) => loadPayments(), // يعيد التحميل تلقائياً بعد الإضافة
    );
  }

  void updatePayment(PaymentEntity payment) async {
    final result = await updatePaymentUseCase(payment);
    result.fold(
          (failure) => emit(PaymentError(failure.toString())),
          (_) => loadPayments(), // يعيد التحميل تلقائياً بعد التحديث
    );
  }

  void deletePayment(String paymentId) async {
    final result = await deletePaymentUseCase(paymentId);
    result.fold(
          (failure) => emit(PaymentError(failure.toString())),
          (_) => loadPayments(), // يعيد التحميل تلقائياً بعد الحذف
    );
  }

  void  searchPayments(String value) {}
}
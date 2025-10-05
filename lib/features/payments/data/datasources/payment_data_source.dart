// features/payments/data/datasources/payment_data_source.dart
import '../../domain/entities/payment_state_entity.dart';
import '../models/payment_model.dart';


abstract class PaymentDataSource {
  Future<List<PaymentModel>> getPayments();
  Future<void> addPayment(PaymentModel payment);
  Future<void> updatePayment(PaymentModel payment);
  Future<void> deletePayment(String paymentId);
  Future<PaymentStatsEntity> getPaymentStats();
}

class PaymentLocalDataSource implements PaymentDataSource {
  static final List<PaymentModel> _payments = [
    PaymentModel(
      id: '1',
      eventId: 'event1',
      eventName: 'زفاف أحمد وفاطمة',
      clientName: 'أحمد محمد',
      amount: 5000.0,
      paymentDate: DateTime.now().subtract(Duration(days: 5)),
      paymentMethod: 'cash',
      status: 'completed',
      notes: 'دفعة أولى',
      createdAt: DateTime.now().subtract(Duration(days: 10)),
    ),
    PaymentModel(
      id: '2',
      eventId: 'event2',
      eventName: 'خطوبة محمد وسارة',
      clientName: 'محمد علي',
      amount: 3000.0,
      paymentDate: DateTime.now().subtract(Duration(days: 2)),
      paymentMethod: 'bank_transfer',
      status: 'completed',
      notes: 'عربون',
      createdAt: DateTime.now().subtract(Duration(days: 7)),
    ),
    PaymentModel(
      id: '3',
      eventId: 'event1',
      eventName: 'زفاف أحمد وفاطمة',
      clientName: 'أحمد محمد',
      amount: 7000.0,
      paymentDate: DateTime.now().add(Duration(days: 5)),
      paymentMethod: 'cash',
      status: 'pending',
      notes: 'دفعة ثانية مستحقة',
      createdAt: DateTime.now().subtract(Duration(days: 5)),
    ),
  ];

  @override
  Future<List<PaymentModel>> getPayments() async {
    await Future.delayed(Duration(milliseconds: 500));
    return List.from(_payments);
  }

  @override
  Future<void> addPayment(PaymentModel payment) async {
    await Future.delayed(Duration(milliseconds: 300));
    _payments.add(payment);
  }

  @override
  Future<void> updatePayment(PaymentModel payment) async {
    await Future.delayed(Duration(milliseconds: 300));
    final index = _payments.indexWhere((p) => p.id == payment.id);
    if (index != -1) {
      _payments[index] = payment;
    }
  }

  @override
  Future<void> deletePayment(String paymentId) async {
    await Future.delayed(Duration(milliseconds: 300));
    _payments.removeWhere((p) => p.id == paymentId);
  }

  @override
  Future<PaymentStatsEntity> getPaymentStats() async {
    await Future.delayed(Duration(milliseconds: 400));

    final completed = _payments.where((p) => p.status == 'completed').toList();
    final pending = _payments.where((p) => p.status == 'pending').toList();

    final totalReceived = completed.fold(0.0, (sum, p) => sum + p.amount);
    final totalPending = pending.fold(0.0, (sum, p) => sum + p.amount);
    final totalAmount = totalReceived + totalPending;

    final monthlyRevenue = {
      'يناير': 15000.0,
      'فبراير': 18000.0,
      'مارس': 22000.0,
      'أبريل': 19000.0,
    };

    return PaymentStatsEntity(
      totalReceived: totalReceived,
      totalPending: totalPending,
      completedPayments: completed.length,
      pendingPayments: pending.length,
      monthlyRevenue: monthlyRevenue,
      totalAmount: totalAmount,
    );
  }
}
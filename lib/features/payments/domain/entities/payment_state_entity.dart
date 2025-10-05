// features/payments/domain/entities/payment_stats_entity.dart
class PaymentStatsEntity {
  final double totalReceived;
  final double totalPending;
  final int completedPayments;
  final int pendingPayments;
  final Map<String, double> monthlyRevenue;
  final double totalAmount;

  const PaymentStatsEntity({
    required this.totalReceived,
    required this.totalPending,
    required this.completedPayments,
    required this.pendingPayments,
    required this.monthlyRevenue,
    required this.totalAmount,
  });

  double get totalExpected => totalReceived + totalPending;
}
// features/payments/domain/entities/payment_stats_entity.dart
import 'package:equatable/equatable.dart';

class PaymentStatsEntity extends Equatable {
  final double totalReceived;
  final double totalPending;
  final int completedPayments;
  final int pendingPayments;
  final int failedPayments;
  final Map<String, double> monthlyRevenue;
  final double totalAmount;

  const PaymentStatsEntity({
    required this.totalReceived,
    required this.totalPending,
    required this.completedPayments,
    required this.pendingPayments,
    required this.failedPayments,
    required this.monthlyRevenue,
    required this.totalAmount,
  });

  double get totalExpected => totalReceived + totalPending;

  double get successRate {
    final total = completedPayments + pendingPayments + failedPayments;
    return total > 0 ? (completedPayments / total) * 100 : 0;
  }

  double get completionRate {
    final total = completedPayments + pendingPayments + failedPayments;
    return total > 0 ? (completedPayments / total) * 100 : 0;
  }

  double get pendingRate {
    final total = completedPayments + pendingPayments + failedPayments;
    return total > 0 ? (pendingPayments / total) * 100 : 0;
  }

  double get failureRate {
    final total = completedPayments + pendingPayments + failedPayments;
    return total > 0 ? (failedPayments / total) * 100 : 0;
  }

  @override
  List<Object> get props {
    return [
      totalReceived,
      totalPending,
      completedPayments,
      pendingPayments,
      failedPayments,
      monthlyRevenue,
      totalAmount,
    ];
  }

  PaymentStatsEntity copyWith({
    double? totalReceived,
    double? totalPending,
    int? completedPayments,
    int? pendingPayments,
    int? failedPayments,
    Map<String, double>? monthlyRevenue,
    double? totalAmount,
  }) {
    return PaymentStatsEntity(
      totalReceived: totalReceived ?? this.totalReceived,
      totalPending: totalPending ?? this.totalPending,
      completedPayments: completedPayments ?? this.completedPayments,
      pendingPayments: pendingPayments ?? this.pendingPayments,
      failedPayments: failedPayments ?? this.failedPayments,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}
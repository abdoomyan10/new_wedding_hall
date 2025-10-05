// features/expenses/domain/entities/profit_entity.dart
import 'package:equatable/equatable.dart';

class ProfitEntity extends Equatable {
  final double totalRevenue;
  final double totalExpenses;
  final double profit;
  final bool isProfit;

  const ProfitEntity({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.profit,
    required this.isProfit,
  });

  // constructor مساعد لحساب profit تلقائياً
  factory ProfitEntity.calculate({
    required double totalRevenue,
    required double totalExpenses,
  }) {
    final profit = totalRevenue - totalExpenses;
    return ProfitEntity(
      totalRevenue: totalRevenue,
      totalExpenses: totalExpenses,
      profit: profit,
      isProfit: profit >= 0,
    );
  }

  @override
  List<Object?> get props => [
    totalRevenue,
    totalExpenses,
    profit,
    isProfit,
  ];
}
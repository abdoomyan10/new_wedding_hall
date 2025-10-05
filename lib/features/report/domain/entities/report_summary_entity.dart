// features/reports/domain/entities/report_summary.dart
class ReportSummaryEntity {
  final double totalRevenue;
  final double totalExpenses;
  final double netProfit;
  final double totalPayments;
  final int totalEvents;
  final double profitMargin;

  const ReportSummaryEntity({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
    required this.totalPayments,
    required this.totalEvents,
    required this.profitMargin,
  });

  // إنشاء نسخة من الكائن مع تحديث بعض الخصائص
  ReportSummaryEntity copyWith({
    double? totalRevenue,
    double? totalExpenses,
    double? netProfit,
    double? totalPayments,
    int? totalEvents,
    double? profitMargin,
  }) {
    return ReportSummaryEntity(
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      netProfit: netProfit ?? this.netProfit,
      totalPayments: totalPayments ?? this.totalPayments,
      totalEvents: totalEvents ?? this.totalEvents,
      profitMargin: profitMargin ?? this.profitMargin,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReportSummaryEntity &&
        other.totalRevenue == totalRevenue &&
        other.totalExpenses == totalExpenses &&
        other.netProfit == netProfit &&
        other.totalPayments == totalPayments &&
        other.totalEvents == totalEvents &&
        other.profitMargin == profitMargin;
  }

  @override
  int get hashCode {
    return totalRevenue.hashCode ^
    totalExpenses.hashCode ^
    netProfit.hashCode ^
    totalPayments.hashCode ^
    totalEvents.hashCode ^
    profitMargin.hashCode;
  }

  @override
  String toString() {
    return 'ReportSummary(totalRevenue: $totalRevenue, totalExpenses: $totalExpenses, netProfit: $netProfit, totalPayments: $totalPayments, totalEvents: $totalEvents, profitMargin: $profitMargin%)';
  }
}
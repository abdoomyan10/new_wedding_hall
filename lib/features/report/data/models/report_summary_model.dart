// features/reports/data/models/report_summary_model.dart

import 'package:new_wedding_hall/features/report/domain/entities/report_summary_entity.dart';

class ReportSummaryModel extends ReportSummaryEntity {
  const ReportSummaryModel({
    required double totalRevenue,
    required double totalExpenses,
    required double netProfit,
    required double totalPayments,
    required int totalEvents,
    required double profitMargin,
  }) : super(
         totalRevenue: totalRevenue,
         totalExpenses: totalExpenses,
         netProfit: netProfit,
         totalPayments: totalPayments,
         totalEvents: totalEvents,
         profitMargin: profitMargin,
       );

  factory ReportSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReportSummaryModel(
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      totalExpenses: (json['totalExpenses'] ?? 0).toDouble(),
      netProfit: (json['netProfit'] ?? 0).toDouble(),
      totalPayments: (json['totalPayments'] ?? 0).toDouble(),
      totalEvents: json['totalEvents'] ?? 0,
      profitMargin: (json['profitMargin'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRevenue': totalRevenue,
      'totalExpenses': totalExpenses,
      'netProfit': netProfit,
      'totalPayments': totalPayments,
      'totalEvents': totalEvents,
      'profitMargin': profitMargin,
    };
  }

  // تحويل من Entity إلى Model
  factory ReportSummaryModel.fromEntity(ReportSummaryEntity entity) {
    return ReportSummaryModel(
      totalRevenue: entity.totalRevenue,
      totalExpenses: entity.totalExpenses,
      netProfit: entity.netProfit,
      totalPayments: entity.totalPayments,
      totalEvents: entity.totalEvents,
      profitMargin: entity.profitMargin,
    );
  }

  // نسخ النموذج مع تحديث بعض الخصائص
  ReportSummaryModel copyWith({
    double? totalRevenue,
    double? totalExpenses,
    double? netProfit,
    double? totalPayments,
    int? totalEvents,
    double? profitMargin,
  }) {
    return ReportSummaryModel(
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

    return other is ReportSummaryModel &&
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
    return 'ReportSummaryModel(totalRevenue: $totalRevenue, totalExpenses: $totalExpenses, netProfit: $netProfit, totalPayments: $totalPayments, totalEvents: $totalEvents, profitMargin: $profitMargin%)';
  }
}


// features/reports/data/models/report_model.dart
import '../../domain/entities/report_entity.dart';

class ReportModel extends ReportEntity {
  const ReportModel({
    required String id,
    required String period,
    required DateTime date,
    required double totalRevenue,
    required double totalPayments,
    required int eventsCount,
    required double expenses,
    required double netProfit,
    required double profitMargin,
  }) : super(
    id: id,
    period: period,
    date: date,
    totalRevenue: totalRevenue,
    totalPayments: totalPayments,
    eventsCount: eventsCount,
    expenses: expenses,
    netProfit: netProfit,
    profitMargin: profitMargin,
  );

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    // حساب هامش الربح إذا لم يكن موجوداً في JSON
    final totalRevenue = (json['totalRevenue'] ?? 0).toDouble();
    final netProfit = (json['netProfit'] ?? 0).toDouble();
    final profitMargin = totalRevenue > 0 ? (netProfit / totalRevenue) * 100 : 0;

    return ReportModel(
      id: json['id'] ?? _generateId(json),
      period: json['period'] ?? 'daily',
      date: DateTime.parse(json['date']),
      totalRevenue: totalRevenue,
      totalPayments: (json['totalPayments'] ?? 0).toDouble(),
      eventsCount: json['eventsCount'] ?? 0,
      expenses: (json['expenses'] ?? 0).toDouble(),
      netProfit: netProfit,
      profitMargin: (json['profitMargin'] ?? profitMargin).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'period': period,
      'date': date.toIso8601String(),
      'totalRevenue': totalRevenue,
      'totalPayments': totalPayments,
      'eventsCount': eventsCount,
      'expenses': expenses,
      'netProfit': netProfit,
      'profitMargin': profitMargin,
    };
  }

  // إنشاء ID فريد إذا لم يكن موجوداً
  static String _generateId(Map<String, dynamic> json) {
    final date = DateTime.parse(json['date']);
    final period = json['period'] ?? 'daily';
    return '${date.toIso8601String()}_$period';
  }

  // تحويل من Entity إلى Model
  factory ReportModel.fromEntity(ReportEntity entity) {
    return ReportModel(
      id: entity.id,
      period: entity.period,
      date: entity.date,
      totalRevenue: entity.totalRevenue,
      totalPayments: entity.totalPayments,
      eventsCount: entity.eventsCount,
      expenses: entity.expenses,
      netProfit: entity.netProfit,
      profitMargin: entity.profitMargin,
    );
  }

  // نسخ النموذج مع تحديث بعض الخصائص
  ReportModel copyWith({
    String? id,
    String? period,
    DateTime? date,
    double? totalRevenue,
    double? totalPayments,
    int? eventsCount,
    double? expenses,
    double? netProfit,
    double? profitMargin,
  }) {
    return ReportModel(
      id: id ?? this.id,
      period: period ?? this.period,
      date: date ?? this.date,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalPayments: totalPayments ?? this.totalPayments,
      eventsCount: eventsCount ?? this.eventsCount,
      expenses: expenses ?? this.expenses,
      netProfit: netProfit ?? this.netProfit,
      profitMargin: profitMargin ?? this.profitMargin,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReportModel &&
        other.id == id &&
        other.date == date &&
        other.period == period &&
        other.totalRevenue == totalRevenue &&
        other.expenses == expenses &&
        other.netProfit == netProfit &&
        other.totalPayments == totalPayments &&
        other.eventsCount == eventsCount &&
        other.profitMargin == profitMargin;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    date.hashCode ^
    period.hashCode ^
    totalRevenue.hashCode ^
    expenses.hashCode ^
    netProfit.hashCode ^
    totalPayments.hashCode ^
    eventsCount.hashCode ^
    profitMargin.hashCode;
  }

  @override
  String toString() {
    return 'ReportModel(id: $id, period: $period, date: $date, totalRevenue: $totalRevenue, expenses: $expenses, netProfit: $netProfit, totalPayments: $totalPayments, eventsCount: $eventsCount, profitMargin: $profitMargin%)';
  }
}
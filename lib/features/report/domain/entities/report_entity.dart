// features/reports/domain/entities/report_entity.dart
import 'package:intl/intl.dart';

class ReportEntity {
  final String id;
  final DateTime date;
  final String period;
  final double totalRevenue;
  final double expenses;
  final double netProfit;
  final double totalPayments;
  final int eventsCount;
  final double profitMargin;

  const ReportEntity({
    required this.id,
    required this.date,
    required this.period,
    required this.totalRevenue,
    required this.expenses,
    required this.netProfit,
    required this.totalPayments,
    required this.eventsCount,
    required this.profitMargin,
  });

  // إنشاء نسخة من الكائن مع تحديث بعض الخصائص
  ReportEntity copyWith({
    String? id,
    DateTime? date,
    String? period,
    double? totalRevenue,
    double? expenses,
    double? netProfit,
    double? totalPayments,
    int? eventsCount,
    double? profitMargin,
  }) {
    return ReportEntity(
      id: id ?? this.id,
      date: date ?? this.date,
      period: period ?? this.period,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      expenses: expenses ?? this.expenses,
      netProfit: netProfit ?? this.netProfit,
      totalPayments: totalPayments ?? this.totalPayments,
      eventsCount: eventsCount ?? this.eventsCount,
      profitMargin: profitMargin ?? this.profitMargin,
    );
  }

  // تحويل الكائن إلى Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'period': period,
      'totalRevenue': totalRevenue,
      'expenses': expenses,
      'netProfit': netProfit,
      'totalPayments': totalPayments,
      'eventsCount': eventsCount,
      'profitMargin': profitMargin,
    };
  }

  // إنشاء كائن من Map
  factory ReportEntity.fromMap(Map<String, dynamic> map) {
    return ReportEntity(
      id: map['id'] ?? '',
      date: DateFormat('yyyy-MM-dd').parse(map['date']),
      period: map['period'] ?? '',
      totalRevenue: (map['totalRevenue'] ?? 0).toDouble(),
      expenses: (map['expenses'] ?? 0).toDouble(),
      netProfit: (map['netProfit'] ?? 0).toDouble(),
      totalPayments: (map['totalPayments'] ?? 0).toDouble(),
      eventsCount: map['eventsCount'] ?? 0,
      profitMargin: (map['profitMargin'] ?? 0).toDouble(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReportEntity &&
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
    return 'ReportEntity(id: $id, date: $date, period: $period, totalRevenue: $totalRevenue, expenses: $expenses, netProfit: $netProfit, totalPayments: $totalPayments, eventsCount: $eventsCount, profitMargin: $profitMargin)';
  }
}
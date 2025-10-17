// features/expenses/domain/entities/expense_stats_entity.dart
class ExpenseStatsEntity {
  final double totalExpenses;
  final int expenseCount;
  final double averageExpense;
  final double todayExpenses;
  final double monthlyExpenses;

  const ExpenseStatsEntity({
    required this.totalExpenses,
    required this.expenseCount,
    required this.averageExpense,
    this.todayExpenses = 0,
    this.monthlyExpenses = 0,
  });

  // named constructor للبيانات الأساسية فقط
  const ExpenseStatsEntity.basic({
    required this.totalExpenses,
    required this.expenseCount,
    required this.averageExpense,
  }) : todayExpenses = 0,
        monthlyExpenses = 0;

  // copyWith method لإمكانية تحديث القيم
  ExpenseStatsEntity copyWith({
    double? totalExpenses,
    int? expenseCount,
    double? averageExpense,
    double? todayExpenses,
    double? monthlyExpenses,
  }) {
    return ExpenseStatsEntity(
      totalExpenses: totalExpenses ?? this.totalExpenses,
      expenseCount: expenseCount ?? this.expenseCount,
      averageExpense: averageExpense ?? this.averageExpense,
      todayExpenses: todayExpenses ?? this.todayExpenses,
      monthlyExpenses: monthlyExpenses ?? this.monthlyExpenses,
    );
  }

  // toMap method للتحويل إلى Map
  Map<String, dynamic> toMap() {
    return {
      'totalExpenses': totalExpenses,
      'expenseCount': expenseCount,
      'averageExpense': averageExpense,
      'todayExpenses': todayExpenses,
      'monthlyExpenses': monthlyExpenses,
    };
  }

  // fromMap method للتحويل من Map
  factory ExpenseStatsEntity.fromMap(Map<String, dynamic> map) {
    return ExpenseStatsEntity(
      totalExpenses: map['totalExpenses'] ?? 0.0,
      expenseCount: map['expenseCount'] ?? 0,
      averageExpense: map['averageExpense'] ?? 0.0,
      todayExpenses: map['todayExpenses'] ?? 0.0,
      monthlyExpenses: map['monthlyExpenses'] ?? 0.0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExpenseStatsEntity &&
        other.totalExpenses == totalExpenses &&
        other.expenseCount == expenseCount &&
        other.averageExpense == averageExpense &&
        other.todayExpenses == todayExpenses &&
        other.monthlyExpenses == monthlyExpenses;
  }

  @override
  int get hashCode {
    return Object.hash(
      totalExpenses,
      expenseCount,
      averageExpense,
      todayExpenses,
      monthlyExpenses,
    );
  }

  @override
  String toString() {
    return 'ExpenseStatsEntity('
        'totalExpenses: $totalExpenses, '
        'expenseCount: $expenseCount, '
        'averageExpense: $averageExpense, '
        'todayExpenses: $todayExpenses, '
        'monthlyExpenses: $monthlyExpenses)';
  }
}
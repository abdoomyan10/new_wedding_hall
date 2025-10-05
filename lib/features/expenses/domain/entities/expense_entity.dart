
class ExpenseEntity {
  final String id;
  final String title;
  final String description;
  final double amount;
  final DateTime date;
  final String workerName;
  final String category;
  final DateTime createdAt;

  const ExpenseEntity({
    required this.title,
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.workerName,
    required this.category,
    required this.createdAt,
  });
}
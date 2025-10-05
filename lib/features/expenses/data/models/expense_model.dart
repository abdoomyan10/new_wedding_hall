import '../../domain/entities/expense_entity.dart';

class ExpenseModel extends ExpenseEntity {
  ExpenseModel({
    required String id,
    required String title,
    required String description,
    required double amount,
    required DateTime date,
    required String workerName,
    required String category,
    required DateTime createdAt,
  }) : super(
    title: title,
    id: id,
    description: description,
    amount: amount,
    date: date,
    workerName: workerName,
    category: category,
    createdAt: createdAt,
  );

  // إنشاء ExpenseModel من ExpenseEntity
  factory ExpenseModel.fromEntity(ExpenseEntity entity) {
    return ExpenseModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      amount: entity.amount,
      date: entity.date,
      workerName: entity.workerName,
      category: entity.category,
      createdAt: entity.createdAt,
    );
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      title: json['title'],
      id: json['id'],
      description: json['description'],
      amount: json['amount'].toDouble(),
      date: DateTime.parse(json['date']),
      workerName: json['workerName'],
      category: json['category'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'workerName': workerName,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
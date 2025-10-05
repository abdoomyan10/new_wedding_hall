// features/expenses/domain/repositories/expense_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/expense_entity.dart';
import '../entities/expense_stats_entity.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, void>> addExpense(ExpenseEntity expense);
  Future<Either<Failure, List<ExpenseEntity>>> getExpenses();
  Future<Either<Failure, void>> deleteExpense(String expenseId);
  Future<Either<Failure, void>> deleteMultipleExpenses(List<String> expenseIds);
  Future<Either<Failure, ExpenseStatsEntity>> getExpenseStats();
  Future<bool> expenseExists(String expenseId);
}
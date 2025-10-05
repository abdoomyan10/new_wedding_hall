// features/expenses/domain/usecases/get_expense_stats_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/expense_stats_entity.dart';
import '../repositories/expense_ropsitory.dart';

class GetExpenseStatsUseCase {
  final ExpenseRepository repository;

  GetExpenseStatsUseCase(this.repository);

  Future<Either<Failure, ExpenseStatsEntity>> call() async {
    return await repository.getExpenseStats();
  }
}
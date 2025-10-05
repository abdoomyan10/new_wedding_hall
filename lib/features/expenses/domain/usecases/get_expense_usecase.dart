// features/expenses/domain/usecases/get_expense_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

class GetExpensesUseCase {
  final ExpenseRepository repository;

  GetExpensesUseCase(this.repository);

  Future<Either<Failure, List<ExpenseEntity>>> call() async {
    return await repository.getExpenses();
  }
}

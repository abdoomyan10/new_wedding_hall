// features/expenses/domain/usecases/add_expense_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/expense_entity.dart';
import '../repositories/expense_ropsitory.dart';


class AddExpenseUseCase {
  final ExpenseRepository repository;

  AddExpenseUseCase(this.repository);

  Future<Either<Failure, void>> call(ExpenseEntity expense) async {
    return await repository.addExpense(expense);
  }
}
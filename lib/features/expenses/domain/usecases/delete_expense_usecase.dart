// features/expenses/domain/usecases/delete_expense_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/expense_repository.dart';

class DeleteExpenseUseCase {
  final ExpenseRepository repository;

  DeleteExpenseUseCase(this.repository);

  Future<Either<Failure, void>> call(String expenseId) async {
    try {
      if (expenseId.isEmpty) {
        return Left(InvalidInputFailure('معرف التكلفة لا يمكن أن يكون فارغاً'));
      }

      return await repository.deleteExpense(expenseId);
    } catch (e) {
      return Left(UnknownFailure('فشل في حذف التكلفة: $e'));
    }
  }

  Future<Either<Failure, void>> deleteMultiple(List<String> expenseIds) async {
    try {
      if (expenseIds.isEmpty) {
        return Left(InvalidInputFailure('قائمة المعرفات فارغة'));
      }

      for (final id in expenseIds) {
        if (id.isEmpty) {
          return Left(InvalidInputFailure('يوجد معرفات فارغة في القائمة'));
        }
      }

      return await repository.deleteMultipleExpenses(expenseIds);
    } catch (e) {
      return Left(UnknownFailure('فشل في حذف التكاليف المتعددة: $e'));
    }
  }

  Future<bool> canDelete(String expenseId) async {
    try {
      return expenseId.isNotEmpty && await repository.expenseExists(expenseId);
    } catch (e) {
      return false;
    }
  }
}

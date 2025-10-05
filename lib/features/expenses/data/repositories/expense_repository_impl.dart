// features/expenses/data/repositories/expense_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_data_source.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/entities/expense_stats_entity.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseDataSource dataSource;
  final NetworkInfo networkInfo;

  ExpenseRepositoryImpl({required this.dataSource, required this.networkInfo});

  @override
  Future<Either<Failure, void>> addExpense(ExpenseEntity expense) async {
    try {
      // في حالة المصدر المحلي، لا نحتاج للتحقق من الشبكة
      // ولكن نتركه للاتساق مع الواجهة
      if (await networkInfo.isConnected) {
        await dataSource.addExpense(expense);
        return const Right(null);
      } else {
        // حتى بدون اتصال، نسمح بالإضافة في المصدر المحلي
        await dataSource.addExpense(expense);
        return const Right(null);
      }
    } on Exception catch (e) {
      return Left(CacheFailure('فشل في إضافة التكلفة: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ExpenseEntity>>> getExpenses() async {
    try {
      // في المصدر المحلي، نعود البيانات حتى بدون اتصال
      if (await networkInfo.isConnected || true) {
        final expenses = await dataSource.getExpenses();

        // إذا كانت القائمة فارغة، نضيف بعض البيانات التجريبية
        if (expenses.isEmpty) {
          // يمكن إضافة بيانات تجريبية هنا إذا لزم الأمر
          print('لا توجد تكاليف في قاعدة البيانات');
        }

        return Right(expenses);
      } else {
        // حتى بدون اتصال، نعود البيانات المحلية
        final expenses = await dataSource.getExpenses();
        return Right(expenses);
      }
    } on Exception catch (e) {
      print('خطأ في جلب التكاليف: $e');
      return Left(CacheFailure('فشل في جلب التكاليف: $e'));
    }
  }

  @override
  Future<Either<Failure, ExpenseStatsEntity>> getExpenseStats() async {
    try {
      if (await networkInfo.isConnected || true) {
        final stats = await dataSource.getExpenseStats();
        return Right(stats);
      } else {
        final stats = await dataSource.getExpenseStats();
        return Right(stats);
      }
    } on Exception catch (e) {
      return Left(CacheFailure('فشل في جلب إحصائيات التكاليف: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String expenseId) async {
    try {
      if (await networkInfo.isConnected || true) {
        // التحقق من وجود التكلفة قبل الحذف
        final expenses = await dataSource.getExpenses();
        final expenseExists = expenses.any(
          (expense) => expense.id == expenseId,
        );

        if (!expenseExists) {
          return Left(NotFoundFailure('التكلفة غير موجودة'));
        }

        await dataSource.deleteExpense(expenseId);
        return const Right(null);
      } else {
        await dataSource.deleteExpense(expenseId);
        return const Right(null);
      }
    } on Exception catch (e) {
      return Left(CacheFailure('فشل في حذف التكلفة: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMultipleExpenses(
    List<String> expenseIds,
  ) async {
    try {
      if (await networkInfo.isConnected || true) {
        final expenses = await dataSource.getExpenses();

        // التحقق من وجود جميع التكاليف قبل الحذف
        for (final expenseId in expenseIds) {
          final expenseExists = expenses.any(
            (expense) => expense.id == expenseId,
          );
          if (!expenseExists) {
            return Left(
              NotFoundFailure('التكلفة بالمعرف $expenseId غير موجودة'),
            );
          }
        }

        // حذف جميع التكاليف
        for (final expenseId in expenseIds) {
          await dataSource.deleteExpense(expenseId);
        }

        return const Right(null);
      } else {
        for (final expenseId in expenseIds) {
          await dataSource.deleteExpense(expenseId);
        }
        return const Right(null);
      }
    } on Exception catch (e) {
      return Left(CacheFailure('فشل في حذف التكاليف: $e'));
    }
  }

  @override
  Future<bool> expenseExists(String expenseId) async {
    try {
      final expenses = await dataSource.getExpenses();
      return expenses.any((expense) => expense.id == expenseId);
    } catch (e) {
      return false;
    }
  }
}

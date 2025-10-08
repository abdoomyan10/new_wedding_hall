import 'package:get_it/get_it.dart';
import 'package:new_wedding_hall/core/network/network_info.dart';
import 'package:new_wedding_hall/core/services/dependencies.dart';
import 'package:new_wedding_hall/features/expenses/data/datasources/expense_data_source.dart';
import 'package:new_wedding_hall/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:new_wedding_hall/features/expenses/domain/usecases/add_expense_usecase.dart';
import 'package:new_wedding_hall/features/expenses/domain/usecases/delete_expense_usecase.dart';
import 'package:new_wedding_hall/features/expenses/domain/usecases/get_expense_stats_usecase.dart';
import 'package:new_wedding_hall/features/expenses/domain/usecases/get_expense_usecase.dart';
import 'package:new_wedding_hall/features/expenses/presentation/cubit/expense_cubit.dart';

// استيرادات HOME الصحيحة
import 'package:new_wedding_hall/features/home/data/datasources/home_local_data_source.dart';
import 'package:new_wedding_hall/features/home/data/repositories/home_repository_impl.dart';
import 'package:new_wedding_hall/features/home/domain/repositories/home_repository.dart';
import 'package:new_wedding_hall/features/home/domain/usecases/get_home_data_usecase.dart'; // إزالة hide

import 'package:new_wedding_hall/features/home/presentation/cubit/home_cubit.dart';

import 'package:new_wedding_hall/features/payments/data/datasources/payment_data_source.dart';
import 'package:new_wedding_hall/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:new_wedding_hall/features/payments/domain/repositories/payment_repository.dart';
import 'package:new_wedding_hall/features/payments/domain/usecases/add_payment_usecase.dart';
import 'package:new_wedding_hall/features/payments/domain/usecases/get_payment_usecase.dart';
import 'package:new_wedding_hall/features/payments/domain/usecases/get_payments_stats_usecase.dart';
import 'package:new_wedding_hall/features/payments/presentation/cubit/payment_cubit.dart';

import 'features/expenses/domain/repositories/expense_repository.dart';
import 'features/payments/domain/usecases/delete_payment_usecase.dart';
import 'features/payments/domain/usecases/update_payment_usecase.dart';
import 'features/report/data/datasources/report_data_source.dart';
import 'features/report/data/datasources/report_local_data_source.dart';
import 'features/report/data/repositories/report_repository_impl.dart';
import 'features/report/domain/repositories/report_repository.dart';
import 'features/report/domain/usecases/export_reports_usecase.dart';
import 'features/report/domain/usecases/get_daily_reports_usecase.dart';
import 'features/report/domain/usecases/get_monthly_reports_usecase.dart';
import 'features/report/domain/usecases/get_report_summary_usecase.dart';
import 'features/report/domain/usecases/get_weekly_reports_usecase.dart';
import 'features/report/domain/usecases/get_yearly_reports_usecase.dart';
import 'features/report/presentation/cubit/report_cubit.dart';

Future<void> init() async {
  // إعادة تعيين GetIt
  await getIt.reset();

  // ========== CORE DEPENDENCIES ==========
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // ========== HOME FEATURE DEPENDENCIES ==========
  getIt.registerLazySingleton<HomeDataSource>(() => HomeLocalDataSource());
  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(dataSource: getIt(), networkInfo: getIt()),
  );

  // Home Use Cases - التسجيل الصحيح
  getIt.registerLazySingleton<GetHomeDataUseCase>(
    () => GetHomeDataUseCase(getIt()),
  );
  getIt.registerLazySingleton<SearchUseCase>(() => SearchUseCase(getIt()));
  getIt.registerLazySingleton<RefreshHomeDataUseCase>(
    () => RefreshHomeDataUseCase(getIt()),
  );
  // Home Cubit - بدون RefreshHomeDataUseCase
  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(
      refreshHomeDataUseCase: getIt(),
      getHomeDataUseCase: getIt(),
      searchUseCase: getIt(),
    ),
  );

  // ... باقي الكود بدون تغيير
  // ========== PAYMENTS FEATURE DEPENDENCIES ==========
  getIt.registerLazySingleton<PaymentDataSource>(
    () => PaymentLocalDataSource(),
  );
  getIt.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(dataSource: getIt(), networkInfo: getIt()),
  );

  // Use Cases - تسجيل صريح مع أنواع محددة
  getIt.registerLazySingleton<GetPaymentsUseCase>(
    () => GetPaymentsUseCase(getIt<PaymentRepository>()),
  );
  getIt.registerLazySingleton<AddPaymentUseCase>(
    () => AddPaymentUseCase(getIt<PaymentRepository>()),
  );
  getIt.registerLazySingleton<UpdatePaymentUseCase>(
    () => UpdatePaymentUseCase(getIt<PaymentRepository>()),
  );
  getIt.registerLazySingleton<DeletePaymentUseCase>(
    () => DeletePaymentUseCase(getIt<PaymentRepository>()),
  );
  getIt.registerLazySingleton<GetPaymentStatsUseCase>(
    () => GetPaymentStatsUseCase(getIt<PaymentRepository>()),
  );

  // Cubits
  getIt.registerFactory<PaymentCubit>(
    () => PaymentCubit(
      getPaymentsUseCase: getIt<GetPaymentsUseCase>(),
      addPaymentUseCase: getIt<AddPaymentUseCase>(),
      updatePaymentUseCase: getIt<UpdatePaymentUseCase>(),
      deletePaymentUseCase: getIt<DeletePaymentUseCase>(),
      getPaymentStatsUseCase: getIt<GetPaymentStatsUseCase>(),
    ),
  );

  // ========== EXPENSES FEATURE DEPENDENCIES ==========
  getIt.registerLazySingleton<ExpenseDataSource>(
    () => ExpenseLocalDataSource(),
  );
  getIt.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(dataSource: getIt(), networkInfo: getIt()),
  );
  getIt.registerLazySingleton<GetExpensesUseCase>(
    () => GetExpensesUseCase(getIt<ExpenseRepository>()),
  );
  getIt.registerLazySingleton<AddExpenseUseCase>(
    () => AddExpenseUseCase(getIt<ExpenseRepository>()),
  );
  getIt.registerLazySingleton<DeleteExpenseUseCase>(
    () => DeleteExpenseUseCase(getIt<ExpenseRepository>()),
  );
  getIt.registerLazySingleton<GetExpenseStatsUseCase>(
    () => GetExpenseStatsUseCase(getIt<ExpenseRepository>()),
  );
  getIt.registerFactory<ExpenseCubit>(
    () => ExpenseCubit(
      getExpensesUseCase: getIt<GetExpensesUseCase>(),
      addExpenseUseCase: getIt<AddExpenseUseCase>(),
      deleteExpenseUseCase: getIt<DeleteExpenseUseCase>(),
      getExpenseStatsUseCase: getIt<GetExpenseStatsUseCase>(),
    ),
  );

  // ========== REPORTS FEATURE DEPENDENCIES ==========
  getIt.registerLazySingleton<ReportDataSource>(
    () => ReportLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(dataSource: getIt(), networkInfo: getIt()),
  );
  getIt.registerLazySingleton<GetDailyReportsUseCase>(
    () => GetDailyReportsUseCase(getIt<ReportRepository>()),
  );
  getIt.registerLazySingleton<GetWeeklyReportsUseCase>(
    () => GetWeeklyReportsUseCase(getIt<ReportRepository>()),
  );
  getIt.registerLazySingleton<GetMonthlyReportsUseCase>(
    () => GetMonthlyReportsUseCase(getIt<ReportRepository>()),
  );
  getIt.registerLazySingleton<GetYearlyReportsUseCase>(
    () => GetYearlyReportsUseCase(getIt<ReportRepository>()),
  );
  getIt.registerLazySingleton<GetReportSummaryUseCase>(
    () => GetReportSummaryUseCase(getIt<ReportRepository>()),
  );
  getIt.registerLazySingleton<ExportReportsUseCase>(
    () => ExportReportsUseCase(getIt<ReportRepository>()),
  );
  getIt.registerFactory<ReportCubit>(
    () => ReportCubit(
      getDailyReportsUseCase: getIt<GetDailyReportsUseCase>(),
      getWeeklyReportsUseCase: getIt<GetWeeklyReportsUseCase>(),
      getMonthlyReportsUseCase: getIt<GetMonthlyReportsUseCase>(),
      getYearlyReportsUseCase: getIt<GetYearlyReportsUseCase>(),
      getReportSummaryUseCase: getIt<GetReportSummaryUseCase>(),
      exportReportsUseCase: getIt<ExportReportsUseCase>(),
    ),
  );

  print('✅ All dependencies registered successfully');
}

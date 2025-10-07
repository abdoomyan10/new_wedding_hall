import 'package:get_it/get_it.dart';
import 'package:new_wedding_hall/core/network/network_info.dart';
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

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // إعادة تعيين GetIt
  await sl.reset();

  // ========== CORE DEPENDENCIES ==========
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // ========== HOME FEATURE DEPENDENCIES ==========
  sl.registerLazySingleton<HomeDataSource>(() => HomeLocalDataSource());
  sl.registerLazySingleton<HomeRepository>(
        () => HomeRepositoryImpl(dataSource: sl(), networkInfo: sl()),
  );

  // Home Use Cases - التسجيل الصحيح
  sl.registerLazySingleton<GetHomeDataUseCase>(() => GetHomeDataUseCase(sl()));
  sl.registerLazySingleton<SearchUseCase>(() => SearchUseCase(sl()));
  sl.registerLazySingleton<RefreshHomeDataUseCase>(() => RefreshHomeDataUseCase(sl()));
  // Home Cubit - بدون RefreshHomeDataUseCase
  sl.registerFactory<HomeCubit>(
        () => HomeCubit(
          refreshHomeDataUseCase: sl(),
      getHomeDataUseCase: sl(),
      searchUseCase: sl(),
    ),
  );

  // ... باقي الكود بدون تغيير
  // ========== PAYMENTS FEATURE DEPENDENCIES ==========
  sl.registerLazySingleton<PaymentDataSource>(() => PaymentLocalDataSource());
  sl.registerLazySingleton<PaymentRepository>(
        () => PaymentRepositoryImpl(dataSource: sl(), networkInfo: sl()),
  );

  // Use Cases - تسجيل صريح مع أنواع محددة
  sl.registerLazySingleton<GetPaymentsUseCase>(() => GetPaymentsUseCase(sl<PaymentRepository>()));
  sl.registerLazySingleton<AddPaymentUseCase>(() => AddPaymentUseCase(sl<PaymentRepository>()));
  sl.registerLazySingleton<UpdatePaymentUseCase>(() => UpdatePaymentUseCase(sl<PaymentRepository>()));
  sl.registerLazySingleton<DeletePaymentUseCase>(() => DeletePaymentUseCase(sl<PaymentRepository>()));
  sl.registerLazySingleton<GetPaymentStatsUseCase>(() => GetPaymentStatsUseCase(sl<PaymentRepository>()));

  // Cubits
  sl.registerFactory<PaymentCubit>(
        () => PaymentCubit(
      getPaymentsUseCase: sl<GetPaymentsUseCase>(),
      addPaymentUseCase: sl<AddPaymentUseCase>(),
      updatePaymentUseCase: sl<UpdatePaymentUseCase>(),
      deletePaymentUseCase: sl<DeletePaymentUseCase>(),
      getPaymentStatsUseCase: sl<GetPaymentStatsUseCase>(),
    ),
  );

  // ========== EXPENSES FEATURE DEPENDENCIES ==========
  sl.registerLazySingleton<ExpenseDataSource>(() => ExpenseLocalDataSource());
  sl.registerLazySingleton<ExpenseRepository>(
        () => ExpenseRepositoryImpl(dataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<GetExpensesUseCase>(() => GetExpensesUseCase(sl<ExpenseRepository>()));
  sl.registerLazySingleton<AddExpenseUseCase>(() => AddExpenseUseCase(sl<ExpenseRepository>()));
  sl.registerLazySingleton<DeleteExpenseUseCase>(() => DeleteExpenseUseCase(sl<ExpenseRepository>()));
  sl.registerLazySingleton<GetExpenseStatsUseCase>(() => GetExpenseStatsUseCase(sl<ExpenseRepository>()));
  sl.registerFactory<ExpenseCubit>(
        () => ExpenseCubit(
      getExpensesUseCase: sl<GetExpensesUseCase>(),
      addExpenseUseCase: sl<AddExpenseUseCase>(),
      deleteExpenseUseCase: sl<DeleteExpenseUseCase>(),
      getExpenseStatsUseCase: sl<GetExpenseStatsUseCase>(),
    ),
  );

  // ========== REPORTS FEATURE DEPENDENCIES ==========
  sl.registerLazySingleton<ReportDataSource>(() => ReportLocalDataSourceImpl());
  sl.registerLazySingleton<ReportRepository>(
        () => ReportRepositoryImpl(dataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<GetDailyReportsUseCase>(() => GetDailyReportsUseCase(sl<ReportRepository>()));
  sl.registerLazySingleton<GetWeeklyReportsUseCase>(() => GetWeeklyReportsUseCase(sl<ReportRepository>()));
  sl.registerLazySingleton<GetMonthlyReportsUseCase>(() => GetMonthlyReportsUseCase(sl<ReportRepository>()));
  sl.registerLazySingleton<GetYearlyReportsUseCase>(() => GetYearlyReportsUseCase(sl<ReportRepository>()));
  sl.registerLazySingleton<GetReportSummaryUseCase>(() => GetReportSummaryUseCase(sl<ReportRepository>()));
  sl.registerLazySingleton<ExportReportsUseCase>(() => ExportReportsUseCase(sl<ReportRepository>()));
  sl.registerFactory<ReportCubit>(
        () => ReportCubit(
      getDailyReportsUseCase: sl<GetDailyReportsUseCase>(),
      getWeeklyReportsUseCase: sl<GetWeeklyReportsUseCase>(),
      getMonthlyReportsUseCase: sl<GetMonthlyReportsUseCase>(),
      getYearlyReportsUseCase: sl<GetYearlyReportsUseCase>(),
      getReportSummaryUseCase: sl<GetReportSummaryUseCase>(),
      exportReportsUseCase: sl<ExportReportsUseCase>(),
    ),
  );

  print('✅ All dependencies registered successfully');
}
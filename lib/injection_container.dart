import 'package:get_it/get_it.dart';
import 'package:new_wedding_hall/core/network/network_info.dart';
import 'package:new_wedding_hall/features/expenses/data/datasources/expense_data_source.dart';
import 'package:new_wedding_hall/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:new_wedding_hall/features/expenses/domain/usecases/add_expense_usecase.dart';
import 'package:new_wedding_hall/features/expenses/domain/usecases/delete_expense_usecase.dart';
import 'package:new_wedding_hall/features/expenses/domain/usecases/get_expense_stats_usecase.dart';
import 'package:new_wedding_hall/features/expenses/domain/usecases/get_expense_usecase.dart';
import 'package:new_wedding_hall/features/expenses/presentation/cubit/expense_cubit.dart';
import 'package:new_wedding_hall/features/home/data/datasources/home_local_data_source.dart';
import 'package:new_wedding_hall/features/home/data/models/search_use_case.dart';
import 'package:new_wedding_hall/features/home/domain/repositories/home_repository.dart';
import 'package:new_wedding_hall/features/home/domain/usecases/get_home_data_usecase.dart'
    hide SearchUseCase;
import 'package:new_wedding_hall/features/home/presentation/cubit/home_cubit.dart';
import 'package:new_wedding_hall/features/payments/data/datasources/payment_data_source.dart';
import 'package:new_wedding_hall/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:new_wedding_hall/features/payments/domain/repositories/payment_repository.dart';
import 'package:new_wedding_hall/features/payments/domain/usecases/Delete_Payment_UseCase.dart';
import 'package:new_wedding_hall/features/payments/domain/usecases/Update_Payment_UseCase.dart';
import 'package:new_wedding_hall/features/payments/domain/usecases/add_payment_usecase.dart';
import 'package:new_wedding_hall/features/payments/domain/usecases/get_payment_usecase.dart';
import 'package:new_wedding_hall/features/payments/domain/usecases/get_payments_stats_usecase.dart';
import 'package:new_wedding_hall/features/payments/presentation/cubit/payment_cubit.dart';
import 'features/expenses/domain/repositories/expense_repository.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
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

// Reports feature imports

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Firebase should be initialized in main (with platform options).
  // e.g. in main(): await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ========== CORE DEPENDENCIES ==========
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // ========== HOME FEATURE DEPENDENCIES ==========

  // Data Sources
  sl.registerLazySingleton<HomeDataSource>(() => HomeLocalDataSource());

  // Repositories
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(dataSource: sl(), networkInfo: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetHomeDataUseCase(sl()));
  sl.registerLazySingleton(() => RefreshHomeDataUseCase(sl()));
  sl.registerLazySingleton(() => SearchUseCase(sl()));

  // Cubits
  sl.registerFactory(
    () => HomeCubit(
      getHomeDataUseCase: sl(),
      refreshHomeDataUseCase: sl(),
      searchUseCase: sl(),
    ),
  );

  // ========== PAYMENTS FEATURE DEPENDENCIES ==========

  // Data Sources
  sl.registerLazySingleton<PaymentDataSource>(() => PaymentLocalDataSource());

  // Repositories
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(dataSource: sl(), networkInfo: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetPaymentsUseCase(sl()));
  sl.registerLazySingleton(() => AddPaymentUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePaymentUseCase(sl()));
  sl.registerLazySingleton(() => DeletePaymentUseCase(sl()));
  sl.registerLazySingleton(() => GetPaymentStatsUseCase(sl()));

  // Cubits
  sl.registerFactory(
    () => PaymentCubit(
      getPaymentsUseCase: sl(),
      addPaymentUseCase: sl(),
      updatePaymentUseCase: sl(),
      deletePaymentUseCase: sl(),
      getPaymentStatsUseCase: sl(),
    ),
  );

  // ========== EXPENSES FEATURE DEPENDENCIES ==========

  // Data Sources
  sl.registerLazySingleton<ExpenseDataSource>(() => ExpenseLocalDataSource());

  // Repositories
  sl.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(dataSource: sl(), networkInfo: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetExpensesUseCase(sl()));
  sl.registerLazySingleton(() => AddExpenseUseCase(sl()));
  sl.registerLazySingleton(() => DeleteExpenseUseCase(sl()));
  sl.registerLazySingleton(() => GetExpenseStatsUseCase(sl()));

  // Cubits
  sl.registerFactory(
    () => ExpenseCubit(
      getExpensesUseCase: sl(),
      addExpenseUseCase: sl(),
      deleteExpenseUseCase: sl(),
      getExpenseStatsUseCase: sl(),
    ),
  );

  // ========== REPORTS FEATURE DEPENDENCIES ==========

  // Data Sources
  sl.registerLazySingleton<ReportDataSource>(() => ReportLocalDataSourceImpl());

  // Repositories
  sl.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(dataSource: sl(), networkInfo: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetDailyReportsUseCase(sl()));
  sl.registerLazySingleton(() => GetWeeklyReportsUseCase(sl()));
  sl.registerLazySingleton(() => GetMonthlyReportsUseCase(sl()));
  sl.registerLazySingleton(() => GetYearlyReportsUseCase(sl()));
  sl.registerLazySingleton(() => GetReportSummaryUseCase(sl()));
  sl.registerLazySingleton(() => ExportReportsUseCase(sl()));

  // Cubits
  sl.registerFactory(
    () => ReportCubit(
      getDailyReportsUseCase: sl(),
      getWeeklyReportsUseCase: sl(),
      getMonthlyReportsUseCase: sl(),
      getYearlyReportsUseCase: sl(),
      getReportSummaryUseCase: sl(),
      exportReportsUseCase: sl(),
    ),
  );
}

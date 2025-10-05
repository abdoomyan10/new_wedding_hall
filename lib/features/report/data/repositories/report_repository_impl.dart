// features/reports/data/repositories/report_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:wedding_hall/core/error/failure.dart';
import 'package:wedding_hall/core/network/network_info.dart';
import '../../domain/entities/report_entity.dart';
import '../../domain/entities/report_summary_entity.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/usecases/export_reports_usecase.dart';
import '../datasources/report_data_source.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportDataSource dataSource;
  final NetworkInfo networkInfo;

  ReportRepositoryImpl({
    required this.dataSource,
    required this.networkInfo,
  });

  // ✅ إضافة تطبيق دالة getYearlyReports
  @override
  Future<Either<Failure, List<ReportEntity>>> getYearlyReports() async {
    try {
      final reports = await dataSource.getYearlyReports();
      return Right(reports);
    } catch (e) {
      return Left(CacheFailure('فشل في تحميل التقارير السنوية'));
    }
  }

  @override
  Future<Either<Failure, List<ReportEntity>>> getDailyReports() async {
    try {
      final reports = await dataSource.getDailyReports();
      return Right(reports);
    } catch (e) {
      return Left(CacheFailure('فشل في تحميل التقارير اليومية'));
    }
  }

  @override
  Future<Either<Failure, List<ReportEntity>>> getWeeklyReports() async {
    try {
      final reports = await dataSource.getWeeklyReports();
      return Right(reports);
    } catch (e) {
      return Left(CacheFailure('فشل في تحميل التقارير الأسبوعية'));
    }
  }

  @override
  Future<Either<Failure, List<ReportEntity>>> getMonthlyReports() async {
    try {
      final reports = await dataSource.getMonthlyReports();
      return Right(reports);
    } catch (e) {
      return Left(CacheFailure('فشل في تحميل التقارير الشهرية'));
    }
  }

  @override
  Future<Either<Failure, ReportSummaryEntity>> getReportSummary(String period) async {
    try {
      final summary = await dataSource.getReportSummary(period);
      return Right(summary);
    } catch (e) {
      return Left(CacheFailure('فشل في تحميل ملخص التقرير'));
    }
  }

  @override
  Future<Either<Failure, String>> exportReports({
    required List<ReportEntity> reports,
    required ExportFormat format,
    required String period,
  }) async {
    try {
      final filePath = await dataSource.exportReports(
        reports: reports,
        format: format == ExportFormat.pdf ? 'pdf' : 'xlsx',
        period: period,
      );
      return Right(filePath);
    } catch (e) {
      return Left(CacheFailure('فشل في تصدير التقارير'));
    }
  }
}
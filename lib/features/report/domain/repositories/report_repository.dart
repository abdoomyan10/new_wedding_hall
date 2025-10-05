// features/reports/domain/repositories/report_repository.dart
import 'package:dartz/dartz.dart';
import 'package:new_wedding_hall/core/error/failure.dart';

import '../entities/report_entity.dart';
import '../entities/report_summary_entity.dart';
import '../usecases/export_reports_usecase.dart';

abstract class ReportRepository {
  Future<Either<Failure, List<ReportEntity>>> getDailyReports();
  Future<Either<Failure, List<ReportEntity>>> getWeeklyReports();
  Future<Either<Failure, List<ReportEntity>>> getMonthlyReports();
  Future<Either<Failure, List<ReportEntity>>>
  getYearlyReports(); // ✅ إضافة التقرير السنوي
  Future<Either<Failure, ReportSummaryEntity>> getReportSummary(String period);
  Future<Either<Failure, String>> exportReports({
    required List<ReportEntity> reports,
    required ExportFormat format,
    required String period,
  });
}

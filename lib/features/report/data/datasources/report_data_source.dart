
import '../../domain/entities/report_entity.dart';
import '../../domain/entities/report_summary_entity.dart';

abstract class ReportDataSource {
  Future<List<ReportEntity>> getDailyReports();
  Future<List<ReportEntity>> getWeeklyReports();
  Future<List<ReportEntity>> getMonthlyReports();
  Future<List<ReportEntity>> getYearlyReports(); // ✅ إضافة التقرير السنوي
  Future<ReportSummaryEntity> getReportSummary(String period);
  Future<String> exportReports({
    required List<ReportEntity> reports,
    required String format,
    required String period,
  });
}
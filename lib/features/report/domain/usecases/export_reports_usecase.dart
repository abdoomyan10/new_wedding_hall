// features/reports/domain/usecases/export_reports_usecase.dart
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/report_entity.dart';
import '../repositories/report_repository.dart';

enum ExportFormat { pdf, excel }

class ExportReportsParams {
  final List<ReportEntity> reports;
  final ExportFormat format;
  final String period;

  const ExportReportsParams({
    required this.reports,
    required this.format,
    required this.period,
  });
}

class ExportReportsUseCase {
  final ReportRepository repository;

  ExportReportsUseCase(this.repository);

  Future<Either<Failure, String>> call(ExportReportsParams params) async {
    return await repository.exportReports(
      reports: params.reports,
      format: params.format,
      period: params.period,
    );
  }
}